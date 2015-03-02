module Tweet::Message

  module Valid
    extend self

    def recipient(recipient, sender, amount)
      link = "www.auroratip.com/#/profile/#{recipient}?direct=true&r=#{Helper.rand()}"
      "@#{recipient}, @#{sender} just tipped you #{amount.to_BTCStr} BTC! "\
      "See it here #{link}"
    end
  end

  module Invalid
    extend self

    def unauthenticated(sender)
      link = "www.auroratip.com/auth/twitter?r=#{Helper.rand()}"
      "@#{sender}, to start tipping, please authenticate via twitter "\
      "and make a deposit. Thanks! #{link}"
    end

    def direct_tweet(sender)
      "@#{sender}, I'm just a bot, a humble servant bot. Please tweet @ScottyLi to talk to a human!"
    end

    def likely_missing_fee(sender)
      "@#{sender}, oops, please lower your amount by 0.01 AUR so we can cover miner fees. Or, top up your account :)"
    end

    def likely_forgot_symbol(sender)
      link = "www.auroratip.com/#/how-it-works?r=#{Helper.rand()}"
      "@#{sender}, apologies human, I cannot compute your tweet :( Please see #{link}"
    end

    # TODO: Include link with amount
    def not_enough_balance(sender)
      link = "www.auroratip.com/auth/twitter?r=#{Helper.rand()}"
      "@#{sender}, please top up on your account before sending this tip. #{link}"
    end

    def enough_confirmed_unspents(sender)
      link = "www.auroratip.com/#/account/deposit?r=#{Helper.rand()}"
      "@#{sender}, you don't have enough confirmed unspents, pls wait for a few mins! #{link}"
    end

    def min_output(sender)
      link = "www.auroratip.com/#/documentation?r=#{Helper.rand()}"
      "@#{sender}, amount must be 0.01 AUR or above #{link}"
    end

    def zero_amount(sender)
      link = "www.auroratip.com/#/how-it-works?r=#{Helper.rand()}"
      "@#{sender}, please tip 0.01 AUR or more. Refer to #{link}"
    end

    def unknown(sender)
      link = "www.auroratip.com/#/how-it-works?r=#{Helper.rand()}"
      "@#{sender}, sorry, I'm not sure what you meant :s. Please refer to #{link}"
    end

  end

  module Pending
    extend self

    def reminder(recipient, amount)
      link = "www.auroratip.com/#/profile/#{recipient}?direct=true"
      # sendersStr = sendersArr.map {|s| "@#{s}"}.join(", ")

      "@#{recipient}, you have #{amount} AUR pending in tips! "\
      "They'll be refunded unless you authenticate within 1 day. "\
      "#{link}"

    end

    def refund

    end
  end

  module Helper
    extend self

    def rand(limit: 2)
      SecureRandom.urlsafe_base64[0..limit]
    end
  end

end
