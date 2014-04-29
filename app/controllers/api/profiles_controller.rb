class Api::ProfilesController < ActionController::Base

  def build

    # TODO: No user?
    params[:screen_name] ||= User.find_by(slug: session[:slug]).screen_name

    @user = User.find_profile(params[:screen_name])
    @twitter_user = TipperClient.search_user(params[:screen_name])

    total_satoshis_given = 0
    total_satoshis_received = 0

    @tips = @user.all_tips[0..9].map do |tip|

      # Cached
      begin
        sender = TipperClient.search_user(tip.sender.screen_name)
        recipient = TipperClient.search_user(tip.recipient.screen_name)

      rescue Exception => e
        ap e.inspect
        ap e.backtrace
        next
      end

      # Count tips
      giving = tip.sender.screen_name == @user.screen_name
      total_satoshis_given += tip.satoshis if giving
      total_satoshis_received += tip.satoshis if !giving

      # Other
      t = Tweet::Parser.new(tip.content, tip.screen_name)
      other = if [:beer, :coffee, :internet, :shatner].include?(t.symbol)
        {
          presence: true,
          units: t.units,
          symbol: t.units > 1 ? t.symbol.to_s.pluralize : t.symbol.to_s
        }
      else
        {
          presence: false
        }
      end

      {
        sender: {
          screenName: sender[:screenName],
          avatarSmall: sender[:avatarSmall],
          css: giving ? "yellow" : "default"
        },
        recipient: {
          screenName: recipient[:screenName],
          avatarSmall: recipient[:avatarSmall],
          css: giving ? "default" : "yellow"
        },
        txDirection:  giving ? "primary" : "success",
        txHash: tip.tx_hash,
        tweetLink: tip.build_link,
        amount: tip.satoshis.to_BTCFloat,
        other: other
      }
    end.compact

    @profile = {
      screenName: @twitter_user[:screenName],
      description: @twitter_user[:description],
      avatarLarge: @twitter_user[:avatarLarge],
      uid: @user.uid,
      authenticated: @user.authenticated,
      totalTipsGiven: total_satoshis_given.to_BTCFloat,
      totalTipsReceived: total_satoshis_received.to_BTCFloat,
      address: @user.addresses.last.address,
      tips: @tips
    }


    render json: @profile
  end

end
