module TipperClient
  extend self

  def search_user(screen_name)
    # Cache TTL should be 1 week
    Rails.cache.fetch(screen_name, expires_in: 1.week) do
      user = TWITTER_CLIENT.user(screen_name)

      {
        screenName: user.screen_name,
        name: user.name,
        description: user.description,
        avatarLarge: user.profile_image_url_https.to_s.gsub("_normal", ""),
        avatarSmall: user.profile_image_url_https.to_s,
        uid: user.id.to_s
      }
    end
  end

  # Returns: Array of tweets
  def mentions
    TWITTER_CLIENT.mentions(count: 200).map(&:attrs)
  end

  # Returns: Array of tweets
  def hashtags
    TWITTER_CLIENT.search("#auroratip").attrs[:statuses]
  end

  def uncaught_mentions
    tweets = mentions + hashtags

    uncaught = tweets.select do |tweet|
      tweet unless TweetTip.find_by(api_tweet_id_str: tweet[:id].to_s)
    end

    uncaught.map do |tweet|
      { content: tweet[:text],
        screen_name: tweet[:user][:screen_name],
        api_tweet_id_str: tweet[:id].to_s
      }
    end
  end

  def save_uncaught_mentions
    uncaught_mentions.each do |tweet|
      TweetTip.create(tweet)
    end
  end

  def delete_all_statuses
    TWITTER_CLIENT.home_timeline.each do |t|
      TWITTER_CLIENT.destroy_status(t.id)
    end
  end

end
