# # Place all the behaviors and hooks related to the matching controller here.
# # All this logic will automatically be available in application.js.
# # You can use CoffeeScript in this file: http://coffeescript.org/
# $ ->
#   $(document).bind('ajaxError', 'form#login_form', ( (event, jqxhr, settings, exception) ->
#     $(event.data).render_form_errors( $.parseJSON(jqxhr.responseText) )
#     to_render($(event.data), $.parseJSON(jqxhr.responseText))
#   ))
#   $(document).bind('ajaxSuccess', 'form#login_form', ( (event, jqxhr, settings, exception) ->
#     location.href = $.parseJSON(jqxhr.responseText)["url"]))
#   ajaxLoadingScreen('form#login_form');

# to_render = (form, errors) ->
#   $.rails.enableFormElements($($.rails.formSubmitSelector));
#   clean_errors(form)
#   form.find('.help-block').append('<span class="tag label label-danger label-important">' + errors['errors'] + '</span> ')

# clean_errors = (form) ->
#   $('.help-block', form).html('')
#   form.removeClass('has-error')
