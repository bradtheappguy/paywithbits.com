class Request < ActiveRecord::Base
  belongs_to :from_phone_number, :foreign_key => :from_id, :class_name => "PhoneNumber"
  belongs_to :to_phone_number, :foreign_key => :to_id, :class_name => "PhoneNumber"
  validates_presence_of :amount
  validates_presence_of :thing
  validates :amount, :numericality => { :greater_than => 0.0 }
end
