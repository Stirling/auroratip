module Tweet::Runner
  extend self

  RETWEET = /(^|\s)RT\s/

  def execute(content: nil, sender: nil, status_id: nil)
    return if sender =~ /auroratip/i
    # TODO: Handle Spammers
    # return if sender =~ /maximillion50/i

    return ap "Retweet ... " if content =~ RETWEET


    ap 'handling ...'
    handler = Tweet::Handler.new(
      content: content,
      sender: sender,
      status_id: status_id
    )

    ap 'saving tweet ...'
    handler.save_tweet_tip

    ap 'checking validity ...'
    handler.check_validity


    if !handler.valid
      if handler.state == :unknown
        ap 'invalid, and unknown, not replying ...'
        return
      end

      ap 'invalid, buildling/deliver reply ...'
      handler.reply_build
      handler.reply_deliver
      return
    end

    ap 'sending tx ...'
    handler.send_tx

    ap 'building/delivering reply ...'
    handler.reply_build
    handler.reply_deliver

  end

end
