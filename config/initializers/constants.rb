# 1 Bitcoin equals X
SATOSHIS = 100_000_000
MILLIBIT = 1000

FEE = 1000000
MINIMUM_DEPOSIT = 100000000

class Numeric
	def to_satoshis
		(self * SATOSHIS).round.to_i
	end

  def to_BTCFloat
    (self.to_f / SATOSHIS).round(8)
  end

  def to_BTCStr
    (self.to_f / SATOSHIS).round(8).to_s
  end

	def to_millibit_satoshis
		(self * SATOSHIS / MILLIBIT).round.to_i
	end
end


class String
  def to_satoshis
    (self.to_f * SATOSHIS).round.to_i
  end

  def to_millibit_satoshis
    (self.to_f * SATOSHIS / MILLIBIT).round.to_i
  end
end
