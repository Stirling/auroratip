class AddAmountToTweetTips < ActiveRecord::Migration
  def change
    add_column :tweet_tips, :amount, :decimal, precision: 16, scale: 8
  end
end
