require 'spec_helper'

describe "Rouding" do

  # Real value
  let(:nSatoshis) { 3133700 }
  let(:nMillbit) { 3134 }

  # Not real value, representations
  let(:nStr) { "0.031337" }
  let(:nStrAlt) { ".031337" }
  let(:nFloat) { 0.031337 }

  # Other
  let(:nStrBad) { ".0.31337" }

  it "should convert nStr to nSatoshis" do
    expect(nStr.to_satoshis).to eq(nSatoshis)
  end

  it "should convert nStr to nSatoshis" do
    expect(nStr.to_millibit_satoshis).to eq(nMillbit)
  end

  it "should convert nStrAlt to nSatoshis" do
    expect(nStrAlt.to_millibit_satoshis).to eq(nMillbit)
  end

  it "should convert nFloat to nSatoshis" do
    expect(nFloat.to_satoshis).to eq(nSatoshis)
  end

  it "should convert satoshis to nFloat" do
    expect(nSatoshis.to_BTCFloat).to eq(nFloat)
  end

  it "should not convert nStrBad" do
    expect(nStrBad.to_satoshis).to eq(0)
  end
end
