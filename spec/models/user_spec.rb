require 'spec_helper'

describe User, 'associations' do
  it { expect(subject).to have_many(:tips_received) }
  it { expect(subject).to have_many(:tips_given) }
  it { expect(subject).to have_many(:addresses) }
end

describe User, 'validations' do
  it { expect(subject).to validate_presence_of(:screen_name) }
  it { expect(subject).to validate_uniqueness_of(:screen_name) }
end

describe User, '.unauthenticated' do
  it 'returns unauthenticated users' do
    authenticated = create(:user, authenticated: true)
    unauthenticated = create(:user, authenticated: false)

    unauthenticated_users = subject.class.unauthenticated

    expect(unauthenticated_users).to include unauthenticated
    expect(unauthenticated_users).to_not include authenticated
  end
end

describe User, '#reminded_recently?' do
  it 'returns true for users that have been reminded less than 3 days ago' do
    recently_reminded = create(:user, reminded_at: 2.days.ago)
    not_recently_reminded = create(:user, reminded_at: 4.days.ago)

    expect(recently_reminded.reminded_recently?).to eq true
    expect(not_recently_reminded.reminded_recently?).to eq false
  end
end

describe User, '#all_tips' do
  it 'returns all tips received and given for a user' do
    user = create(:user)
    sent = create(:tweet_tip, sender: user)
    received = create(:tweet_tip, recipient: user)
    excluded = create(:tweet_tip)

    all_tweet_tips = user.all_tips

    expect(all_tweet_tips).to include sent
    expect(all_tweet_tips).to include received
    expect(all_tweet_tips).to_not include excluded
  end
end

describe User, '.find_profile' do
  it 'returns the user for a given screen name' do
    user = create(:user, screen_name: 'BiTcOiNmAfIa')
    address = create(:address, user: user)

    found_users = subject.class.find_profile('bitcoinmafia')

    expect(found_users).to eq user
  end

  it 'returns nil if the user found has no addresses' do
    user = create(:user, screen_name: 'BiTcOiNmAfIa')

    found_users = subject.class.find_profile('bitcoinmafia')

    expect(found_users).to be_nil
  end

  it 'returns nil if no user is found' do
    found_users = subject.class.find_profile('bitcoinmafia')

    expect(found_users).to be_nil
  end
end

describe User, '.create_profile' do
  before :each do
    BitcoinUtils.stub(:generate_address)
  end

  it 'creates a user with a slug and address if a user does not exist' do
    profile = subject.class.create_profile('bitcoinmafia')

    expect(profile).to be_persisted
    expect(profile.slug).to be_present
    expect(profile.addresses).to be_present
    expect(BitcoinUtils).to have_received(:generate_address)
  end

  it 'finds a user and assigns a slug and address if they do not exist' do
    user = create(:user, screen_name: 'bitcoinmafia', addresses: [], slug: nil)

    profile = subject.class.create_profile('bitcoinmafia')

    expect(profile).to eq user
    expect(profile.slug).to be_present
    expect(profile.addresses).to be_present
    expect(BitcoinUtils).to have_received(:generate_address)
  end

  it 'finds a user and returns without overwriting attributes if they exist' do
    user = create(:user, screen_name: 'bitcoinmafia', slug: SecureRandom.hex(64))
    address = create(:address, user: user)

    profile = subject.class.create_profile('bitcoinmafia')

    expect(profile).to eq user
    expect(profile.slug).to eq user.slug
    expect(profile.addresses).to include address
    expect(BitcoinUtils).to have_received(:generate_address)
  end

  it 'returns nil if passed nil' do
    profile = subject.class.create_profile(nil)

    expect(profile).to be_nil
  end
end

describe User, '#current_address' do
  let!(:user) { create(:user) }
  let(:hex) { SecureRandom.hex(4) }
  let(:attrs) {
    { address: SecureRandom.hex(8),
      encrypted_private_key: SecureRandom.hex(),
      public_key: SecureRandom.hex(64),
      user: user
    }
  }

  it 'returns the most recently created addresses' do
    first_address = create(:address,
      address: SecureRandom.hex(64),
      encrypted_private_key: SecureRandom.hex(64),
      public_key: SecureRandom.hex(64),
      user: user
    )
    last_address = create(:address,
      address: SecureRandom.hex(64),
      encrypted_private_key: SecureRandom.hex(64),
      public_key: SecureRandom.hex(64),
      user: user
    )

    expect(user.current_address).to eq last_address.address
  end
end

# describe User, '#get_balance' do
#   it 'returns the balance from the Bitcoin API' do
#     BitcoinUtils.stub(:get_info).and_return({ 'final_balance' => 200 })
#     user = create(:user)
#     address = create(:address, user: user)

#     balance = user.get_balance

#     expect(balance).to eq 200
#     expect(BitcoinUtils).to have_received(:get_info).with(user.current_address)
#   end
# end

describe User, '#likely_missing_fee?' do
  let!(:user) { create(:user) }

  before :each do
    user.stub(:get_balance).and_return(100_000)
  end

  it 'is true if the user has insufficient funds to cover the miner fee' do
    expect(user.likely_missing_fee?(100_000)).to eq true
  end

  it 'is false if the amount is nil' do
    expect(user.likely_missing_fee?(nil)).to eq false
  end

  it 'is false if the user has sufficient funds to cover the miner fee' do
    expect(user.likely_missing_fee?(50_000)).to eq false
  end
end

describe User, '#enough_balance?' do
  it 'returns true if the amount plus the miner fee is less than the balance' do
    user = create(:user)
    user.stub(:get_balance).and_return(100_000)

    expect(user.enough_balance?(10_000)).to eq true
    expect(user.enough_balance?(90_001)).to eq false
    expect(user.enough_balance?(200_000)).to eq false
    expect(user.enough_balance?(nil)).to eq false
  end
end

describe User, '#enough_confirmed_unspents?' do
  it 'gets unspents from the Bitcoin API' do
    BitcoinUtils.stub(:get_unspents)
    user = create(:user)
    address = create(:address, user: user)

    user.enough_confirmed_unspents?(100_000)

    expect(BitcoinUtils).to have_received(:get_unspents).with(
      user.current_address, 110_000
    )
  end
end

describe User, '#withdraw' do
  it 'sends the current address, to address, and amount to the Bitcoin API' do
    user = create(:user)
    from_address = create(:address,
      address: SecureRandom.hex(64),
      encrypted_private_key: SecureRandom.hex(64),
      public_key: SecureRandom.hex(64),
      user: user
    )
    to_address = create(:address,
      address: SecureRandom.hex(64),
      encrypted_private_key: SecureRandom.hex(64),
      public_key: SecureRandom.hex(64),
    )
    BitcoinUtils.stub(:send_tx)

    user.withdraw(100_000, to_address)

    expect(BitcoinUtils).to have_received(:send_tx).with(
      from_address, to_address, 100_000
    )
  end
end

describe User, '.unauthenticated_with_tips' do
  it 'returns unauthenticated users with more than zero valid tips received' do
    valid_user = create(:user, authenticated: false)
    valid_user.tips_received << create(:tweet_tip)
    invalid_user = create(:user, authenticated: false)
    invalid_user.tips_received << create(:tweet_tip, satoshis: nil)

    users = subject.class.unauthenticated_with_tips

    expect(users).to include valid_user
    expect(users).to_not include invalid_user
  end
end
