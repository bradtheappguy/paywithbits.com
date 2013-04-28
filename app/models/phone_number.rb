class PhoneNumber < ActiveRecord::Base
  attr_accessible :number, :wallet

  validates_presence_of :number
  validates_presence_of :wallet

  #validates :balance, :numericality => { :greater_than => 0.0 }

end
