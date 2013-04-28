class PhoneNumber < ActiveRecord::Base
  attr_accessible :number, :bitcoin_address

  validates_presence_of :number

  #validates :balance, :numericality => { :greater_than => 0.0 }
  before_create :generate_bitcoin_address

  def generate_bitcoin_address
    unless self.bitcoin_address
      self.uuid = UUID.new.generate      
      self.bitcoin_address = $bitcoin.getnewaddress(self.uuid)
    end
  end

  def balance
     WalletThang.get_balance(self.bitcon_address)
  end
end
