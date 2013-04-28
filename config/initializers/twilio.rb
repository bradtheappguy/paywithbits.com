require 'twilio-ruby'

# put your own credentials here
account_sid = 'AC4eef0df1f4ec82e99e03b03061361b70'
auth_token = '98e85ab7abdc0eee38ace029766c64ae'

# set up a client to talk to the Twilio REST API
$twilio_client = Twilio::REST::Client.new account_sid, auth_token
