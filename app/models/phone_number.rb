class PhoneNumber < ActiveRecord::Base
  attr_accessible :number, :bitcoin_address

  #phony_normalize :number, :default_country_code => 'US', :format => :international

  validates_presence_of :number

  #validates :balance, :numericality => { :greater_than => 0.0 }
  before_create :generate_bitcoin_address
  before_validation :normalize_number

  def generate_bitcoin_address
    unless self.bitcoin_address
      self.bitcoin_address = WalletThang.generate_address
    end
  end

  def normalize_number
    self.number.phony_formatted!(:normalize => :US, :format => :international, :spaces => '')
  end

  def self.normalize_and_find_by_number!(number)
    number.phony_formatted!(:normalize => :US, :format => :international, :spaces => '')
    self.find_by_number!(number)
  end

  def balance
     WalletThang.get_balance(self.bitcon_address)
  end
end
