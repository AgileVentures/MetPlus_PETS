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
            // Get the data entered by the user in the dialog box
            data: post_data,
            timeout: 5000,
            success: function (data, status, xhrObject){
                alert('success');
            },
            error: function (xhrObj, status, exception) {
                alert(xhrObject)
            }
        });
    },
    setup: function() {
        $(".assign_button").click(TaskManager.load_assign_modal);
        $("#assignTaskModal_button").click(TaskManager.assign_user);
        $("#assignTaskModal").modal('hide');
    }
};

$(TaskManager.setup);