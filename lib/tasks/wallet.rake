namespace :wallet do
  desc "TODO"
  task :balance => :environment do

    Bitcoin.network = :bitcoin

    store = Bitcoin::Storage.sequel(:db => "sqlite://bitcoin.db")

    address = "1cqnHsAFdBNUSnbr5e3kjcojvnjbYNgDC"

    raise "invalid wallet address" unless Bitcoin.valid_address?(address)

    puts "legit"

    hash160 = Bitcoin.hash160_from_address(address)
    balance = store.get_balance(hash160)

    puts balance.inspect

    txins = store.get_txouts_for_address(address)

    puts txins.inspect

  end
end
