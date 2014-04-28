module HelloBlockLabs
  extend self

  BASE_URL = "https://#{ENV["BLOCKCHAIN_MODE"]}-helloblock-txs-staging.herokuapp.com"

  def get_pubkey
    HTTParty.get(BASE_URL + "/cosign/pubkeys")
  end

  # pubkeys Array
  def register_address(opts = {})
    HTTParty.post(BASE_URL + "/cosign/addresses", {
      redeem_script: opts[:redeem_script]
    })
  end

  def propagate(opts = {})
    HTTParty.post(BASE_URL + "/cosign", {
      rawTxHex: opts[:rawTxHex]
    })
  end
end

