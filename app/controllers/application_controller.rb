class ApplicationController < ActionController::Base
  def inbound
    message = params[:Body].downcase
    raise "Body missing" unless message

    from = params[:From]
    raise "From missing" unless from

    parts = message.split(" ")
    mega_from = "+14156751348"

    unknown_command_message = "Unknown Command."
    unknown_request_message = "Unknown Request."
    syntax_message = "Invalid Syntax."
    same_person_message = "Same Person."
    help_message = "See: http://paywithbits.com/help"

    commands = {"signup" => "signup"}
    begin
      case parts.first
        when "signup"
          raise syntax_message unless parts.length == 1

          new_number = PhoneNumber.new(:number => from)
          new_number.save!

          $twilio_client.account.sms.messages.create(:from => mega_from, :to => from, :body => "Thank you for signing up! " + help_message)

        when "send"
          raise syntax_message unless parts.length == 6

          amount = parts[1]
          to = parts[3]
          thing = parts[5]
          from_number = PhoneNumber.normalize_and_find_by_number!(from)
          to_number = PhoneNumber.normalize_and_find_by_number!(to)

          raise same_person_message if from_number.number == to_number.number

          from_number.send_bitcoin(to_number, amount.to_f, thing)

          $twilio_client.account.sms.messages.create(:from => mega_from, :to => from_number.number, :body => "You gave #{to_number.number}  #{amount}.")
          $twilio_client.account.sms.messages.create(:from => mega_from, :to => to_number.number, :body => "#{from_number.number} gave you #{amount}.")

        when "balance"
          raise syntax_message unless parts.length == 1

          from_number = PhoneNumber.normalize_and_find_by_number!(from)
          $twilio_client.account.sms.messages.create(:from => mega_from, :to => from_number.number, :body => "You have #{from_number.balance}BTC.")

        when "request"
          raise syntax_message unless parts.length == 6

          amount = parts[1]
          to = parts[3]
          thing = parts[5]
          from_number = PhoneNumber.normalize_and_find_by_number!(from)
          to_number = PhoneNumber.normalize_and_find_by_number!(to)

          raise same_person_message if from_number.number == to_number.number

          new_request = Request.new
          new_request.from_phone_number = from_number
          new_request.to_phone_number = to_number
          new_request.amount = amount
          new_request.thing = thing
          new_request.save!

          $twilio_client.account.sms.messages.create(:from => mega_from, :to => from_number.number, :body => "You are requesting #{amount} from #{to_number.number} for #{thing}.")
          $twilio_client.account.sms.messages.create(:from => mega_from, :to => to_number.number, :body => "#{from_number.number} is requesting #{amount} for #{thing}. Confirm or Deny?")

        when "ok", "yes", "confirm"
          raise syntax_message unless parts.length == 1

          from_number = PhoneNumber.normalize_and_find_by_number!(from)
          latest_request = Request.where(:to_id => from_number.id).order("created_at DESC").limit(1).first

          raise unknown_request_message unless latest_request

          from_number.send_bitcoin(latest_request.from_phone_number, latest_request.amount.to_f, latest_request.thing)

          $twilio_client.account.sms.messages.create(
            :from => mega_from,
            :to => latest_request.to_phone_number.number,
            :body => "You have sent #{latest_request.amount} to #{latest_request.from_phone_number.number} for #{latest_request.thing}"
          )

          $twilio_client.account.sms.messages.create(
            :from => mega_from,
            :to => latest_request.from_phone_number.number,
            :body => "#{latest_request.to_phone_number.number} has accepted your #{latest_request.amount} request for #{latest_request.thing}"
          )

          Request.where(:to_id => from_number.id).destroy_all

        when "no", "deny"
          raise syntax_message unless parts.length == 1

          from_number = PhoneNumber.normalize_and_find_by_number!(from)
          latest_request = Request.where(:to_id => from_number.id).order("created_at DESC").limit(1).first

          raise "Unknown Request." unless latest_request

          $twilio_client.account.sms.messages.create(
              :from => mega_from,
              :to => latest_request.to_phone_number.number,
              :body => "You have denied sending #{latest_request.amount} to #{latest_request.from_phone_number.number} for #{latest_request.thing}"
          )

          $twilio_client.account.sms.messages.create(
              :from => mega_from,
              :to => latest_request.from_phone_number.number,
              :body => "#{latest_request.to_phone_number.number} has denied your request of #{latest_request.amount} for #{latest_request.thing}"
          )

          Request.where(:to_id => from_number.id).destroy_all
       when "help"
         help = {
                 "signup"  => "command: send <amount> to <phone number> for <note>",
                 "balance" => "command: balance <amount> to <phone number> for <note>",
                 "send"    => "command: send <amount> to <phone number> for <note>",
                 "request" => "command: request <amount> from <phone number> for <note>"
                }
         msg = help[parts[1]]
         $twilio_client.account.sms.messages.create(
              :from => mega_from,
              :to => from,
              :body => msg
         )



      else
        raise unknown_command_message
      end
    rescue => e
      $twilio_client.account.sms.messages.create(:from => mega_from, :to => from, :body => e.message + " " + help_message)
      raise e
    end

    head :ok
  end
end
