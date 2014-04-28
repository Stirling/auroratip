module HelloBlockLabs
  extend self

  BASE_URL = "https://#{ENV["BLOCKCHAIN_MODE"]}-helloblock-txs-staging.herokuapp.com"

  def get_redeem_script(pubkey)
    HTTParty.get(BASE_URL + "/cosign")
  end

  # pubkeys Array
  def get_address(pubkeys)
    HTTParty.post(BASE_URL + "/cosign/register", {
      pubkeys: pubkeys
    })
  end

  def p2sh_propagate()
    HTTParty.post(BASE_URL + "/cosign", {

    })
  end
end

