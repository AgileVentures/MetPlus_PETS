# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
#
# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# compiled file.
#
# Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
# about supported directives.

#= require jquery2
#= require jquery.turbolinks
#= require jquery_ujs
#= require turbolinks
#= require js.cookie
#= require_self
#= require_tree .

# @ajaxLoadingScreen = (formName) ->
#   $(document).bind('ajaxStart', formName, ( (event, jqxhr, settings, exception) ->
#     $('#loading').show()
#     $(formName).find('.submit-button').attr('disabled', 'true')
#   ))
#   $(document).bind('ajaxComplete', formName, ( ->
#     $('#loading').hide() ))

# @postponeMessageRemoval = (timeout) ->
#   setTimeout ( -> $('#messages').remove()),timeout

# $ ->
#   postponeMessageRemoval(5000)
