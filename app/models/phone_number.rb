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

  def account
    $bitcoin.getaccount(self.bitcoin_address)
  end

  def balance
     $bitcoin.getbalance(self.account,0)
  end

  #def sendfrom(fromaccount, tobitcoinaddress, amount, minconf = 1, comment = nil, comment_to = nil)
  
  def send_bitcoin(recipient, amount, comment)
    $bitcoin.sendfrom(self.account, recipient.bitcoin_address, amount, 0, comment, comment) unless self.balance < (amount + 0.001) || self.balance < 0
  end
end
