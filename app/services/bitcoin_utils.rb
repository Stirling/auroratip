module BitcoinUtils
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

  def send_tx(from_address, to_address, amount, fee = FEE)
    hex = BitcoinUtils.construct_tx(from_address, to_address, amount, fee)
    begin
      res = HelloBlock::Transaction.propagate({
        rawTxHex: hex
      })

      return res["txHash"]
    rescue => e
      ap e
    end
  end

  def construct_tx(from_address, to_address, amount, fee)
    user_address = Address.where(address: from_address)[0]
    privkey = AES.decrypt(user_address.encrypted_private_key, ENV["DECRYPTION_KEY"])
    key = Bitcoin::Key.new(privkey, nil, false)

    unspents = HelloBlock::Address.get_unspents(from_address, {
      value: amount + fee
    })

    new_tx = build_tx do |t|
      unspents.each do |unspent|
        t.input do |i|
          i.prev_out unspent["txHash"]
          i.prev_out_index unspent["index"]
          i.prev_out_script [unspent["scriptPubKey"]].pack("H*")
          i.signature_key(key)
        end
      end

      t.output do |o|
        o.value(amount)
        o.script {|s| s.recipient(to_address) }
      end

      # now deal with change
      unspent_value = unspents.inject(0) {|sum, e| sum += e["value"] }
      change_value = unspent_value - (amount+fee)

      # Min Output accepted
      if change_value >= 5500
        t.output do |o|
          o.value(change_value)
          o.script {|s| s.recipient key.addr }
        end
      end
    end

    return new_tx.payload.unpack("H*")[0]
  end

end
