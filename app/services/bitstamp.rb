module Bitstamp
  extend self

  def latest
    response = HTTParty.get("http://api.cryptocoincharts.info/tradingPair/aur_usd")
    response["price"].to_f
  end
end
