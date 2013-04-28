class WalletThang

  @@client = client = Bitcoin::Client.new('bitcoinrpc','Afc3Ydn2NuLi5W2iJrSMGhKbikj9VwiCFBmEMeGTb2vt')

  def self.generate_address
    @@client.getnewaddress
  end


  def initialize(from_wallet)
  end

  def transfer(to_wallet, amount, thing)
  end
end
