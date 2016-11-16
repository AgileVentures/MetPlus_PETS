# Using a constant instead of a CruncherService class var since
# Rails reloads all classes for each request in development mode
CRUNCHER_URL = ENV['CRUNCHER_SERVICE_URL'] ||
                   'http://localhost:8443/api/v99999'

# To enable the RestClient logger, export this env var at the
# command line (before starting rails server), e.g.:
# export RESTCLIENT_LOG_FILE='log/RestClient.log'
RestClient.log = ENV['RESTCLIENT_LOG_FILE']
