# 1 Bitcoin equals X
SATOSHIS = 100_000_000
MILLIBIT = 1000

FEE = 0.1
MINIMUM_DEPOSIT = 1

class Numeric
	def to_satoshis
		(self * SATOSHIS).round.to_i
	end

  def to_BTCFloat
    self.to_f.round(8)
  end

  def to_BTCStr
    self.to_f.round(8).to_s
  end

	def to_millibit_float
		(self * MILLIBIT).round(8)
	end
end


class String
  def to_satoshis
    (self.to_f * SATOSHIS).round.to_i
  end

  def to_BTCFloat
    self.to_f.round(8)
  end

  def to_millibit_float
    (self.to_f * MILLIBIT).round(8)
  end
end
