require 'spec_helper'

describe Address, 'associations' do
  it { expect(subject).to belong_to(:user) }
end

describe Address, 'validations' do
  it { expect(subject).to validate_presence_of(:encrypted_private_key) }
  it { expect(subject).to validate_uniqueness_of(:encrypted_private_key) }
  it { expect(subject).to validate_presence_of(:public_key) }
  it { expect(subject).to validate_uniqueness_of(:public_key) }
  it { expect(subject).to validate_presence_of(:user_id) }
end

describe Address do
	it "decrypts private key" do
		payload = BitcoinUtils.generate_address()
		decrypted_key = AES.decrypt(payload[:encrypted_private_key], ENV["DECRYPTION_KEY"])
		address = Address.new(payload.merge(:user_id => 1))
		address.save
		address.reload
		address.decrypt()
		address.private_key.should eq(decrypted_key)
	end
end

