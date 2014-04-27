if Rails.env.production?
  Bitcoin.network = :bitcoin
  HelloBlock.configure do |config|
    config.network = :mainnet
  end
end

if !Rails.env.production?
  Bitcoin.network = :testnet3
  HelloBlock.configure do |config|
    config.network = :testnet
  end
end
