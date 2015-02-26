module Bitstamp
  extend self

  def latest
    response = HTTParty.get("https://www.cryptonator.com/api/ticker/aur-usd")
    response["ticker"]["price"].to_f
  end
end
