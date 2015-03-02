module BitcoinNodeAPI
    extend self
    ROOT = "http://insight.auroracoin.io/api/"

    # string address
    # response float
    def get_balance(address)
        res = get("addr/"+address+"?noCache=1")
        (res['balance'] + res['unconfirmedBalance']).to_BTCFloat
    end

    # string[] addresses
    # response hash or nil
    def multi_addr(addresses)
        get("addr/"+addresses.join(",")+"/balance?noCache=1")
    end

    # string[] addresses
    # unspents[] or nil
    def unspent(addresses)
        get("addr/"+addresses.join(",")+"/utxo?noCache=1")
    end

    def get_tx(tx_hash)
        get("tx/"+tx_hash)
    end

    def push_tx(hex)
        payload = {
          :rawtx => hex
        }
        post("tx/send", payload)
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
        ap res
        raise PushTransactionFailed.new(res.body, options.merge!({"status" => res.code})) if res.code >= 400
        res.body
    end

    # Have to do this cos blockchain info API is crappy
    def error?(res)
        res.code >= 400 || JSON.parse(res.body)["error"]
    end

    class PushTransactionFailed < CriticalError; end
end