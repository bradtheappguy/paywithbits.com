class ApplicationController < ActionController::Base
  protect_from_forgery

  def inbound
    message = params[:body].downcase
    from = params[:from]
    parts = message.split(" ")
    mega_from = "+14156751348"

    begin
      case parts[0]
        when "signup"
          new_number = PhoneNumber.new(:number => from, :wallet => "123")
          new_number.save!

          $twilio_client.account.sms.messages.create(:from => mega_from, :to => from, :body => "thanks for signing up")

        when "send"
          raise "invalid syntax" unless parts.length == 6
          amount = parts[1]
          to = parts[3]
          thing = parts[6]

          from_number = PhoneNumber.find_by_number!(from)
          to_number = PhoneNumber.find_by_number!(to)

          from_wallet = WalletThang.new(from_number)
          to_wallet = WalletThang.new(to_number)

          from_wallet.transfer(to_wallet, amount, thing)

          $twilio_client.account.sms.messages.create(:from => mega_from, :to => from_number.number, :body => "You gave #{to_number.number} #{amount}")
          $twilio_client.account.sms.messages.create(:from => mega_from, :to => to_number.number, :body => "#{from_number.number} gave you #{amount}")
          
      else

      end
    rescue => e
      $twilio_client.account.sms.messages.create(:from => mega_from, :to => from, :body => e.message)
    end

    head :ok
  end
end
