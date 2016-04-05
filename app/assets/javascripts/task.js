var TaskManager = {
    load_assign_modal: function (event) {
        var task_id = $(this).data("task-id");
        $("#task_assign_select").select2({
            placeholder: "Select the user",
            ajax: {
                url: "task/" + task_id + "/list_owners",
                dataType: 'json',
                type: "GET",
                delay: 250,
                data: function (term, page) {
                    return {
                        q: term, // search term
                        col: 'vdn'
                    };
                },
                dropdownAutoWidth : true,
                cache: true
            }
        });
        $('#task_assign_select').closest('form').attr('action','/task/' + task_id + '/assign');
    },
    assign_user: function() {
        if( $("#task_assign_select").val() === null) {
            return;
        }
        var url = $('#task_assign_select').closest('form').attr('action');
        var post_data = {to: $("#task_assign_select").val()};
        $.ajax({type: 'PATCH',
            url: url,
            data: post_data,
            timeout: 5000,
            success: function (){
                noty({text: 'Task assigned',
                     theme: 'bootstrapTheme',
                    layout: 'bottomRight',
                      type: 'success'});
                TaskManager.load_tasks();
            },
            error: function (xhrObj, status, exception) {
                noty({text: xhrObj['message'],
                     theme: 'bootstrapTheme',
                    layout: 'bottomRight',
                      type: 'error'});
            }
        });
    },
    load_tasks: function() {

    },
    setup: function() {
        $(".assign_button").click(TaskManager.load_assign_modal);
        $("#assignTaskModal_button").click(TaskManager.assign_user);
        $("#assignTaskModal").modal('hide');
    }
};

$(TaskManager.setup);