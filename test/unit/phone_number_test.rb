require 'test_helper'

class PhoneNumberTest < ActiveSupport::TestCase
  test "a new phone number has 0.0 balance" do
    new_number = PhoneNumber.new
    assert new_number.balance == 0.0
  end

  test "a phone numbers balance must be greater than zero" do
    new_number = PhoneNumber.new(:number => "something", :wallet => "else")
    new_number.balance = -1
    assert !new_number.valid?
  end

  test "a phone numbers balance must be updatable" do
    new_number = PhoneNumber.new(:number => "something", :wallet => "else")
    new_number.balance += 1.0
    assert new_number.balance == 1.0
    assert new_number.valid?
    assert new_number.save
    new_number.reload.balance == 1.0
  end

 
end
