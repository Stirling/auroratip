require 'spec_helper'

describe BitcoinUtils do
	before(:all) do
		unspents = {
			"privateKeyWIF"=>"91rVKXwKyY3mJtqtznhzAXHvq5LbquHavqV3r5rXuf9yu8tjoHg",
		  "privateKeyHex"=>"235b7e1eb2de4fc1a9c83c4f6026d3f3d579acd6c7310ae7017b01f39fb33e0a",
		  "address"=>"mpJ8kCLsjSxDveS4a3EUmta2HmppqLW3WL"
		}

		unspents = HelloBlock::Faucet.unspents({type: 1})

		addr = {
			encrypted_private_key: AES.encrypt(unspents["privateKeyHex"], ENV["DECRYPTION_KEY"]),
			address: unspents["address"],
			public_key: "mock",
			user_id: 999,
		}

		@address = Address.create(addr)
	end

	after(:all) do
		Address.delete_all
	end

	it "should construct tx" do
		to_address = "mvaRDyLUeF4CP7Lu9umbU3FxehyC5nUz3L"
		hex = BitcoinUtils.construct_tx(@address.address, to_address, 10_000, 10_000)
		p hex
		expect(hex).to match(/^\h+$/)
	end

	it "should send tx" do
		to_address = "mvaRDyLUeF4CP7Lu9umbU3FxehyC5nUz3L"
		hash = BitcoinUtils.send_tx(@address.address, to_address, 10_000, 10_000)
		p hash
		expect(hash).to match(/^\h+$/)
	end

end
