# Pull production data, but switch addresses to testnet

Bitcoin.network = :testnet3

addresses = Address.all
addresses.each do |address|
  addr = BitcoinUtils.generate_address()
  address.public_key = addr[:public_key]
  address.encrypted_private_key = addr[:encrypted_private_key]
  address.address = addr[:address]
  address.save
end

