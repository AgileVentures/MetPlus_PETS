# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.coffee.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  $("#registration_button").click ->
    ajaxRequest($(this), modalLaunch, alertMe)
    false
  $("#login_button").click ->
    ajaxRequest($(this), modalLaunch, alertMe)
    false
  $("#logout_button").click ->
    ajaxRequest($(this), pageReload, alertMe)
    false

pageReload = (data) ->
  $('#loading').hide();
  window.location.reload()
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
  $('.content').prepend("""
<div class='row' id='messages'>
  <div class ='container'>
    <div class='alert alert-danger'>
      Some problem happened trying to get your request, please try again later
    </div>
  </div>
</div>
""")
  postponeMessageRemoval(5000)


modalLaunch = (data) ->
  $('#modal').remove()
  $('.content').append(data)
  $('#modal').modal("show")
  submit = $('#modal').find(".form_div").find(':submit')
  $(document).bind('ajaxError', $('#modal').closest('form').val(), ( (event, jqxhr, settings, exception) ->
    $(event.data).render_form_errors( $.parseJSON(jqxhr.responseText) )
    $('#modal').find(".form_div").find(':submit').prop("disabled", false)))
  $(document).bind('ajaxSuccess', $('#modal').closest('form').val(), ( (event, jqxhr, settings, exception) ->
    location.href = $.parseJSON(jqxhr.responseText)["url"]))
  $(document).bind('ajaxStart', $('#modal').closest('form').val(), ( (event, jqxhr, settings, exception) ->
    $('#modal').find(".form_div").find(':submit').prop("disabled", true)))