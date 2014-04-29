if ENV["BLOCKCHAIN_MODE"] === "mainnet"
  Bitcoin.network = :bitcoin
  HelloBlock.configure do |config|
    config.network = :mainnet
  end
end

if ENV["BLOCKCHAIN_MODE"] === "testnet"
  Bitcoin.network = :testnet3
  HelloBlock.configure do |config|
    config.network = :testnet
  end
end
