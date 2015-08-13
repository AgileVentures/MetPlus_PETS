#
# Created by joaopereira on 8/5/15.
#
$ ->
  $(document).bind('ajaxError', 'form#new_job_seeker', ( (event, jqxhr, settings, exception) ->
    $(event.data).render_form_errors( $.parseJSON(jqxhr.responseText) )
  ))
  $(document).bind('ajaxSuccess', 'form#new_job_seeker', ( (event, jqxhr, settings, exception) ->
    location.href = $.parseJSON(jqxhr.responseText)["url"]))
  ajaxLoadingScreen('form#new_job_seeker');

$.fn.render_form_errors = (errors) ->
  $form = this;
  $.rails.enableFormElements($($.rails.formSubmitSelector));
  this.clear_previous_errors()
  model = this.data('model')
  $.each(errors, ((field, messages) ->
    $input = $('input[name="' + model + '[' + field + ']"]')
    $block = $input.closest('.form_field').addClass('has-error').find('.help-block')
    for idx of messages
      $block.append( '<span class="tag label label-danger label-important">' + messages[idx] + '</span> ' )
  ))

$.fn.clear_previous_errors = ->
  $('.form_field.has-error', this).each( ->
      $('.help-block', $(this)).html('')
      $(this).removeClass('has-error')
  )
