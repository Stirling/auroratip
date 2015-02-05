namespace :transactions do

  desc "Send a transactions"
  task :post => :environment do
    from_address = "19MQGYGvbecJKKcUoVovgRKGgDLAXWDt8z"
    to_address = "124Tk7NFXvci5eJYtWUjeDUELTUahUumXf"
    amount = 40_000
    fee = 10_000

    msg = BitcoinAPI.send_tx(from_address, to_address, amount, fee)
    ap msg
  end

end
