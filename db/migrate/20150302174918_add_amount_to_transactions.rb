class AddAmountToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :amount, :decimal, precision: 16, scale: 8
  end
end
