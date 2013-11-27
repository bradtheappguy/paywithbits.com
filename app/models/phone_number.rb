class PhoneNumber < ActiveRecord::Base

  attr_accessible :number, :bitcoin_address
  before_validation :normalize_number
  validates_presence_of :number
  before_create :generate_bitcoin_address

  def generate_bitcoin_address
    unless self.bitcoin_address
      self.uuid = UUID.new.generate      
      self.bitcoin_address = $bitcoin.getnewaddress(self.uuid)
    end
  end

  def normalize_number
    self.number.phony_formatted!(:normalize => :US, :format => :international, :spaces => '')
  end

  def self.normalize_and_find_by_number!(number)
    number.phony_formatted!(:normalize => :US, :format => :international, :spaces => '')
    self.find_by_number!(number)
  end

  def account
    $bitcoin.getaccount(self.bitcoin_address)
  end

  def balance
     $bitcoin.getbalance(self.account,1)
  end

  def send_bitcoin(recipient, amount, comment)
    if self.balance < (amount + 0.0001) || self.balance < 0
      raise "Insufficient funds."
    else
      $bitcoin.sendfrom(self.account, recipient.bitcoin_address, amount, 0, comment, comment) 
    end
  end
end
