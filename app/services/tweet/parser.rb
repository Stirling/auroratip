require 'csv'

class Tweet::Parser

  attr_accessor :content, :sender, :info, :mentions, :amount,
  :satoshis, :units, :symbol, :recipient

  BOT = "auroratip"

  def initialize(content, sender)
    @content = content
    @sender = sender

    @mentions = Tweet::Extractor::Mentions.parse(@content)
    @amount = Tweet::Extractor::Amounts.parse(@content)

    @recipient = @mentions.first
    @satoshis = @amount[:satoshis]
    @units = @amount[:units]
    @symbol = @amount[:symbol]
  end

  def valid?
    return false if direct_tweet?
    return false if @recipient.blank?
    return false if @satoshis.blank? || @satoshis.zero?
    return false if @units.blank?
    return false if @symbol.blank?
    return false if @sender == BOT

    return true
  end

  def likely_forgot_symbol?
    number_exists = @content =~ /\s\d?+.?\d+/ ? true : false
    !valid? && number_exists
  end

  def direct_tweet?
    @mentions.first == BOT && @content[0] == "@"
  end

  def multiple_recipients?
    @mentions.count > 2 # actual recipient + BOT
  end


end
