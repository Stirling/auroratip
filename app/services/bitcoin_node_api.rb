module BitcoinNodeAPI
    extend self
    ROOT = "http://chainz.cryptoid.info/aur/"

    # string address
    # response float
    def get_balance(address)
        get("api.dws?q=getbalance&a="+address, false).to_f.to_satoshis
    end

    # string[] addresses
    # response hash or nil
    def multi_addr(addresses)
        get("api.dws?q=multiaddr&active="+addresses.join("|"))
    end

    # string[] addresses
    # unspents[] or nil
    def unspent(addresses)
        get("api.dws?q=unspent&active="+addresses.join("|"))["unspent_outputs"]
    end

    def get_tx(tx_hash)
        res = HTTParty.get("https://chainz.cryptoid.info/explorer/tx.data.dws?coin=aur&id=#{tx_hash}")
        return nil if error?(res)
        JSON.parse(res.body)
    end

    def push_tx(hex, tx_hash)
        payload = {
          format: "plain",
          tx: hex,
          hash: tx_hash
        }
        post("pushtx", payload)
    end

    def get(url, isJSONResponse = true)
        res = HTTParty.get(ROOT + url)
        #return nil if error?(res)
        if isJSONResponse
            return JSON.parse(res.body)
        else
            return res.body
        end
    end

    # TODO construct error message
    def post(url, payload)
        options = {body: payload}
        res = HTTParty.post(ROOT + url, options)
        raise PushTransactionFailed.new(res.body, options.merge!({"status" => res.code})) if res.code >= 400
        res.body
    end

    # Have to do this cos blockchain info API is crappy
    def error?(res)
        res.code >= 400 || JSON.parse(res.body)["error"]
    end

    class PushTransactionFailed < CriticalError; end
end