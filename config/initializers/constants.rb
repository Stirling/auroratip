# 1 Bitcoin equals X
SATOSHIS = 100_000_000
MILLIBIT = 1000

FEE = 10000
MINIMUM_DEPOSIT = 20000

class Numeric
	def to_satoshis
		(self * SATOSHIS).round.to_i
	end

  def to_BTCFloat
    (self.to_f / SATOSHIS).round(8)
  end

	def to_millibit_satoshis
		(self * SATOSHIS / MILLIBIT).round.to_i
	end
end


class String
  def to_satoshis
    to_f.to_satoshis
  end

  def to_millibit_satoshis
    to_f.to_millibit_satoshis
  end
end
