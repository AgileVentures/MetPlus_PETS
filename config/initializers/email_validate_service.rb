EMAIL_VALIDATE_URL = 'api.mailgun.net/v3'

MAILGUN_PUBLIC_KEY = 'pubkey-0188160a7f79dbc9c673c5c251915dcf'

ENV['MAILGUN_EMAIL_VALIDATION'] = nil
# If the above env key is not defined, or is set to any value other than 'yes',
# email validation via mailgun will not occur

# To enable the RestClient logger, export this env var at the
# command line (before starting rails server), e.g.:
# export RESTCLIENT_LOG_FILE='log/RestClient_email_validate.log'
RestClient.log = ENV['RESTCLIENT_LOG_FILE']
