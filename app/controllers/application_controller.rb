class ApplicationController < ActionController::Base
  #protect_from_forgery

  def inbound
    message = params[:Body].downcase
    from = params[:From]
    parts = message.split(" ")
    mega_from = "+14156751348"

    begin
      case parts[0]
        when "signup"
          raise "invalid syntax" unless parts.length == 1

          new_number = PhoneNumber.new(:number => from, :wallet => "123")
          new_number.save!
          $twilio_client.account.sms.messages.create(:from => mega_from, :to => from, :body => "thanks for signing up")

        when "send"
          raise "invalid syntax" unless parts.length == 6

          amount = parts[1]
          to = parts[3]
          thing = parts[5]
          from_number = PhoneNumber.find_by_number!(from)
          to_number = PhoneNumber.find_by_number!(to)

          raise "same person" if from_number.number == to_number.number

          from_wallet = WalletThang.new(from_number)
          to_wallet = WalletThang.new(to_number)
          from_wallet.transfer(to_wallet, amount, thing)
          $twilio_client.account.sms.messages.create(:from => mega_from, :to => from_number.number, :body => "You gave #{to_number.number} #{amount}")
          $twilio_client.account.sms.messages.create(:from => mega_from, :to => to_number.number, :body => "#{from_number.number} gave you #{amount}")

        when "request"
          raise "invalid syntax" unless parts.length == 6

          amount = parts[1]
          to = parts[3]
          thing = parts[5]
          from_number = PhoneNumber.find_by_number!(from)
          to_number = PhoneNumber.find_by_number!(to)

          raise "same person" if from_number.number == to_number.number

          from_wallet = WalletThang.new(from_number)
          to_wallet = WalletThang.new(to_number)
          $twilio_client.account.sms.messages.create(:from => mega_from, :to => from_number.number, :body => "You are requesting #{amount} from #{to_number.number} for #{thing}")
          $twilio_client.account.sms.messages.create(:from => mega_from, :to => to_number.number, :body => "#{from_number.number} is requesting #{amount} for #{thing} ok?")

        when "balance"
          raise "invalid syntax" unless parts.length == 1

          from_number = PhoneNumber.find_by_number!(from)
          $twilio_client.account.sms.messages.create(:from => mega_from, :to => from_number.number, :body => "You have #{from_number.balance}BTC")

        when "ok"
          raise "invalid syntax" unless parts.length == 1

          from_number = PhoneNumber.find_by_number!(from)
          $twilio_client.account.sms.messages.create(:from => mega_from, :to => from_number.number, :body => "You have sent XXX to YYY for ZZZ")
          
      else
        raise "unknown command '#{message}'"
      end
    rescue => e
      $twilio_client.account.sms.messages.create(:from => mega_from, :to => from, :body => e.message)
    end

    head :ok
  end
end
