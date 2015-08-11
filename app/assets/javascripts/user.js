/**
 * Created by joaopereira on 8/5/15.
 */
$(document).ready(function(){
    $(document).bind('ajaxError', 'form#new_job_seeker', function(event, jqxhr, settings, exception){
        // note: jqxhr.responseJSON undefined, parsing responseText instead
        $(event.data).render_form_errors( $.parseJSON(jqxhr.responseText) );
    });
    ajaxLoadingScreen('form#new_job_seeker');
});

(function($) {

    $.fn.render_form_errors = function(errors){

        $form = this;
        this.clear_previous_errors();
        model = this.data('model');
        // show error messages in input form-group help-block
        $.each(errors, function(field, messages){
            $input = $('input[name="' + model + '[' + field + ']"]');
            $block = $input.closest('.form_field').addClass('has-error').find('.help-block');
            for(idx in messages) {
                $block.append( '<span class="tag label label-danger label-important">' + messages[idx] + '</span> ' );
            }
        });

    };

    $.fn.clear_previous_errors = function(){
        $('.form_field.has-error', this).each(function(){
            $('.help-block', $(this)).html('');
            $(this).removeClass('has-error');
        });
    }

}(jQuery));