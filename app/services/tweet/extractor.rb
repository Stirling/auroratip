module Tweet::Extractor
  module Mentions
    extend self

    # Accept: String
    # Returns: Array or Strings, or nil
    def parse(content)
      usernames = content.scan(/@(\w+)/).flatten
      return [nil] if usernames.blank?
      return usernames
    end

  end

  module Amounts
    extend self

    ### Supported Currency Symbols:
    ### Order matters, higher means more priority
    SYMBOLS = [
      {
        name: :mBTC_SUFFIX,
        regex: /\s(\d*.?\d*)\s?mAUR/i,
        satoshify: Proc.new {|nStr| nStr.to_millibit_satoshis }
      },
      {
        name: :mBTC_PREFIX,
        regex: /mAUR\s?(\d*.?\d*)/i,
        satoshify: Proc.new {|nStr| nStr.to_millibit_satoshis }
      },
      {
        name: :BTC_SUFFIX,
        regex: /\s(\d*.?\d*)\s?AUR/i,
        satoshify: Proc.new {|nStr| nStr.to_satoshis }
      },
      {
        name: :bitcoin_SUFFIX,
        regex: /\s(\d*.?\d*)\s?auroracoin/i,
        satoshify: Proc.new {|nStr| nStr.to_satoshis }
      },
      {
        name: :BTC_SIGN,
        regex: /ᚠ\s?(\d*.?\d*)/i,
        satoshify: Proc.new {|nStr| nStr.to_satoshis }
      },
      {
        name: :BTC_PREFIX,
        regex: /AUR\s?(\d*.?\d*)/i,
        satoshify: Proc.new {|nStr| nStr.to_satoshis }
      },
      {
        name: :USD,
        regex: /\s(\d*.?\d*)\s?USD/i,
        satoshify: Proc.new {|nStr| (nStr.to_f / Bitstamp.latest).to_satoshis }
      },
      {
        name: :dollar,
        regex: /\s(\d*.?\d*)\s?dollar/i,
        satoshify: Proc.new {|nStr| (nStr.to_f / Bitstamp.latest).to_satoshis }
      },
      {
        name: :USD_SIGN,
        regex: /\$\s?(\d*.?\d*)/i,
        satoshify: Proc.new {|nStr| (nStr.to_f / Bitstamp.latest).to_satoshis }
      },
      {
        name: :beer,
        regex: /\s(\d*.?\d*)\s?beer/i,
        satoshify: Proc.new {|nStr| (nStr.to_f * 4 / Bitstamp.latest).to_satoshis }
      },
      {
        name: :coffee,
        regex: /\s(\d*.?\d*)\s?coffee/i,
        satoshify: Proc.new {|nStr| (nStr.to_f * 3 / Bitstamp.latest).to_satoshis }
      },
      {
        name: :internet,
        regex: /\s(\d*.?\d*)\s?internet/i,
        satoshify: Proc.new {|nStr| (nStr.to_f * 0.001337).to_satoshis }
      },
      {
        name: :shatner,
        regex: /\s(\d*.?\d*)\s?shatner/i,
        satoshify: Proc.new {|nStr| (nStr.to_f * 0.001701).to_satoshis}
      }
    ]

    # Accept: String
    # Returns: Hash
    def parse(content)
      parse_all(content).each do |p|
        next if p.blank?

        p.each do |x|
          return x unless x[:satoshis].nil?
        end
      end

      return {
        satoshis: nil,
        units: nil,
        symbol: nil
      }
    end

    # Accept: String
    # Returns: Array of arrays
    def parse_all(content)
      SYMBOLS.map do |sym|
        raw = content.scan(sym[:regex]).flatten
        raw.map do |r|
          satoshis = sym[:satoshify].call(r) if r.is_number?
          {
            satoshis: satoshis,
            units: r.strip.to_f,
            symbol: sym[:name]
          }
        end
      end
    end

  end
end
