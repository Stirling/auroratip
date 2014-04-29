module HelloBlockLabs
  extend self

  BASE_URL = "https://#{ENV["BLOCKCHAIN_MODE"]}-helloblock-txs-staging.herokuapp.com"

  def register_address(opts = {})
    p opts
    HTTParty.post(BASE_URL + "/cosign/addresses", body: {
      redeemScript: opts[:redeem_script]
    })
  end

  def cosign_propagate(opts = {})
    HTTParty.post(BASE_URL + "/cosign", body: {
      partialTxHex: opts[:partial_tx_hex]
    })
  end

  def get_pubkey
    HTTParty.get(BASE_URL + "/cosign/pubkeys")
  end
end

