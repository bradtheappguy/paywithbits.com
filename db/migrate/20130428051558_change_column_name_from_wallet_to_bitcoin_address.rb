class ChangeColumnNameFromWalletToBitcoinAddress < ActiveRecord::Migration
  def change
    rename_column :phone_numbers, :wallet, :bitcoin_address
  end
end
