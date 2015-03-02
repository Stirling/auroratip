module BitcoinAPI
  extend self
  extend Bitcoin::Builder

  def generate_address()
    private_key, public_key = Bitcoin::generate_key
    address = Bitcoin::pubkey_to_address(public_key)
    encrypted_private_key = AES.encrypt(private_key, ENV["DECRYPTION_KEY"])
    {
      encrypted_private_key: encrypted_private_key,
      public_key: public_key,
      address: address
    }
  end

  # string address
  def get_balance(address)
    BitcoinNodeAPI.get_balance(address)
  end

  # obj address, int amount
  # returns httparty response obj
  # exception is raised, ensure to rescue
  # BitcoinAPI.send_tx(from_address, "15TLNJ24UFixU1Vn7eogJYvgaH324SocK4", 0.001.to_satoshi, FEE)
  def send_tx(from_address, to_address, amount, fee = FEE)
    raise AmountShouldBeFixnum if amount.class != Fixnum
    hex = construct_tx(from_address, to_address, amount, fee)
    ap hex
    #push_tx(hex)
    return hex
  end

  def construct_tx(from_address, to_address, amount, fee)
    unspents = get_unspents(from_address.address, amount + fee)
    prikey = AES.decrypt(from_address.encrypted_private_key, ENV["DECRYPTION_KEY"])
    key = Bitcoin::Key.new(prikey, nil, false)
    
    new_tx = build_tx do |t|
      unspents.each do |unspent|
        t.input do |i|
          i.prev_out unspent["txid"]
          i.prev_out_index unspent["vout"]
          i.prev_out_script [unspent["scriptPubKey"]].pack("H*")
          i.signature_key(key)
        end
      end

      t.output do |o|
        o.value(amount)
        o.script {|s| s.recipient(to_address) }
      end

      # now deal with change
      change_value = unspents.unspent_value - (amount+fee).to_BTCFloat
      ap unspents.unspent_value
      ap (amount+fee).to_BTCFloat
      if change_value > 0
        t.output do |o|
          o.value(change_value)
          o.script {|s| s.recipient from_address.address }
        end
      end      
    end

    return new_tx.payload.unpack("H*").first
  end

  def get_unspents(from_address, total_value)
    unspents = BitcoinNodeAPI.unspent([from_address])
    select_unspents(unspents, total_value)
  end

  def select_unspents(unspents, total_value)
    raise InsufficientAmount.new("Needed #{total_value.to_satoshis}, but only had #{unspents.unspent_value}. \nNote: Your unspents need to be confirmed first, maybe wait for another few minutes!") if unspents.unspent_value.to_satoshis < (total_value)
    selected_unspents = []
    unspents.each do |unspent|
      if unspent["amount"] >= total_value
        return [unspent]
      else
        selected_unspents << unspent
        return selected_unspents if selected_unspents.unspent_value >= total_value
      end
    end
  end

  def push_tx(hex)
    BitcoinNodeAPI.push_tx(hex)
  end

  class TxError < StandardError; end
  class InsufficientAmount < TxError; end
  class AmountShouldBeInteger < TxError; end

  class ::Array
    def unspent_value
      self.sum { |unspent| unspent["amount"] }
    end
  end

  class ::String
    def reverse_hex
      [self].pack('H*').reverse.unpack("H*").first
    end
  end
end