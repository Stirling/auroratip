module Pending
  extend self

  def reminders(dry: true)
    count = 0
    recipients = User.unauthenticated_with_tips

    recipients.each do |recipient|
      begin
        next if recipient.reminded_recently(less_than: 7.days)

        unclaimed = recipient.tips_received.unclaimed(has_been: 20.days)
        next if unclaimed.blank?

        senders = unclaimed.map {|u| u.sender }
        # senders_names = senders.map {|s| s.screen_name}
        senders_amount = unclaimed.sum(:satoshis).to_BTCFloat

        message = Tweet::Message::Pending.reminder(
          recipient.screen_name,
          senders_amount
        )

        ap message

        if !dry
          TWITTER_CLIENT.update(message,
            in_reply_to_status_id: unclaimed.first.api_tweet_id_str)

          recipient.reminded_at = Time.now
          recipient.save
        end

        count += 1
        ap "##{count}"

      rescue Exception => e
        ap e.inspect
        ap e.backtrace

        CriticalError.new("Error in reminders: #{e.inspect}", {
          inspect: e.inspect,
          backtrace: e.backtrace
        })

        next
      end

      sleep 10 if !dry
    end

    return false
  end

  def refunds(dry: true)
    count = 0
    recipients = User.unauthenticated_with_tips

    recipients.each do |recipient|
      begin
        # next if recipient.reminded_at.nil?

        unclaimed = recipient.tips_received.unclaimed(has_been: 21.days)
        unclaimed.each do |tip|
          refund_amount = tip.satoshis - FEE

          next if refund_amount < (10_000 + 5500)

          ap tip.content
          ap tip.satoshis
          ap refund_amount

          if !dry
            tx = BitcoinAPI.send_tx(
              recipient.addresses.last,
              tip.sender.addresses.last.address,
              refund_amount)

            tip.tx_hash_refund = tx

            tip.save
          end

          count += 1
          ap "##{count}"

          sleep 10 if !dry
        end
      rescue Exception => e
        ap e.inspect
        ap e.backtrace

        CriticalError.new("Error in refunds: #{e.inspect}", {
          inspect: e.inspect,
          backtrace: e.backtrace
        })

        next
      end

    end

    return false
  end
end
