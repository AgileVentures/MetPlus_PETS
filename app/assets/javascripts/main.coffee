# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  $("#registration_button").click ->
    ajaxRequest($(this), modalLaunch, alertMe)
    false
  $("#login_button").click ->
    ajaxRequest($(this), modalLaunch, alertMe)
    false


ajaxRequest = (link, onSuccess, onError) ->
  url = link.attr('href')
  $.ajax
      url: url,
      dataType: "html",
      success: (data) ->
        onSuccess(data)
        $('#loading').hide();
      error: (data) ->
        onError(data)
        $('#loading').hide();

alertMe = (data) ->
  alert "bamm -> #{data}"

modalLaunch = (data) ->
  $('#modal').remove()
  $('.content').append(data)
  $('#modal').modal("show")