class Tweet::Handler

  attr_accessor :content, :sender, :recipient,
  :reply, :recipient_user, :sender_user,
  :status_id, :parsed_tweet, :valid, :state,
  :reply_id, :tweet_tip, :satoshis

  def initialize(content: nil, sender: nil, status_id: nil)
    @content = content
    @sender = sender
    @status_id = status_id
    @reply_id = status_id
    @parsed_tweet = Tweet::Parser.new(@content, @sender)
    @satoshis = @parsed_tweet.satoshis
    @recipient = @parsed_tweet.recipient
    @valid = false
    @sender_user = User.find_profile(@sender) || User.create_profile(@sender)
    @recipient_user = User.find_profile(@recipient) || User.create_profile(@recipient)
  end

  def save_tweet_tip
    @tweet_tip = @sender_user.tips_given.new({
      content: @content,
      screen_name: @sender,
      api_tweet_id_str: @status_id,
      recipient_id: @recipient_user.try(:id)
    })

    @tweet_tip.save
  end

  def check_validity
    @valid = false
    # @state represents what went wrong, and associated message method
    return @state = :unauthenticated if !@sender_user.authenticated
    return @state = :direct_tweet if @parsed_tweet.direct_tweet?
    return @state = :zero_amount if @satoshis && @satoshis.zero?
    return @state = :min_output if @satoshis && @satoshis < 5_550
    return @state = :likely_forgot_symbol if @parsed_tweet.likely_forgot_symbol?
    return @state = :unknown if !@parsed_tweet.valid? # Other Unknown Error
    return @state = :likely_missing_fee if @sender_user.likely_missing_fee?(@satoshis)
    return @state = :not_enough_balance if !@sender_user.enough_balance?(@satoshis)

    # we should have confirmed that there is enough balance now
    return @state = :enough_confirmed_unspents if !@sender_user.enough_confirmed_unspents?(@satoshis)
    @valid = true
  end

  def reply_build
    if @valid
      @reply = Tweet::Message::Valid.recipient(
        @recipient, @sender, @satoshis)
    else
      @reply = Tweet::Message::Invalid.send(@state, @sender)
      @reply_id = nil
    end
  end

  def reply_deliver
    TWITTER_CLIENT.update(@reply, in_reply_to_status_id: @reply_id)
  end

  def send_tx
    tx_hash = BitcoinAPI.send_tx(
      @sender_user.addresses.last,
      @recipient_user.addresses.last.address,
      @satoshis)

    @tweet_tip.tx_hash = tx_hash
    @tweet_tip.satoshis = @satoshis

    @tweet_tip.save
  end

end
