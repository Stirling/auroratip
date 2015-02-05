if ENV["BLOCKCHAIN_MODE"] === "mainnet"
  Bitcoin.network = :auroracoin
end

if ENV["BLOCKCHAIN_MODE"] === "testnet"
  Bitcoin.network = :testnet3
end
