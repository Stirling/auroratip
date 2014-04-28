class AddColumnToAddress < ActiveRecord::Migration
  def change
    add_column :addresses, :redeem_script, :text
  end
end
