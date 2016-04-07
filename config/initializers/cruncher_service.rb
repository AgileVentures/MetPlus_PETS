CruncherService.service_url = ENV['CRUNCHER_SERVICE_URL'] ||
                              'http://localhost:8443/api/v1'

# To enable the RestClient logger, export this env var at the
# command line (before starting rails server), e.g.:
# export RESTCLIENT_LOG_FILE='log/RestClient.log'
RestClient.log = ENV['RESTCLIENT_LOG_FILE']
