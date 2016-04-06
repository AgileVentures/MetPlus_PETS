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
                $("#assignTaskModal").modal('hide');
            },
            error: function (xhrObj, status, exception) {
                noty({text: xhrObj['message'],
                     theme: 'bootstrapTheme',
                    layout: 'bottomRight',
                      type: 'error'});
            }
        });
    },
    wip_task: function() {
        var url = $(this).data("url");
        $.ajax({type: 'PATCH',
            url: url,
            data: {},
            timeout: 5000,
            success: function (){
                noty({text: 'Work on the task started',
                    theme: 'bootstrapTheme',
                    layout: 'bottomRight',
                    type: 'success'});
            },
            error: function (xhrObj, status, exception) {
                noty({text: xhrObj['message'],
                    theme: 'bootstrapTheme',
                    layout: 'bottomRight',
                    type: 'error'});
            }
        });
    },
    done_task: function() {
        var url = $(this).data("url");
        $.ajax({type: 'PATCH',
            url: url,
            data: {},
            timeout: 5000,
            success: function (){
                noty({text: 'Work on the task is done',
                    theme: 'bootstrapTheme',
                    layout: 'bottomRight',
                    type: 'success'});
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
        console.log('load_tasks()');
        $("#tasks").html("Page is loading...");
        $.ajax({type: 'GET',
            url: this.href,
            data: {},
            timeout: 5000,
            success: function (data){
                $("#tasks").html(data);
                TaskManager.setup();
                console.log('updated tasks()');
            },
            error: function (xhrObj, status, exception) {
                noty({text: 'Unable to retrieve the tasks for the user',
                    theme: 'bootstrapTheme',
                    layout: 'bottomRight',
                    type: 'error'});
            }
        });
        console.log('end load_tasks()');
        return false;
    },
    setup: function() {
        $(".assign_button").click(TaskManager.load_assign_modal);
        $(".wip_button").click(TaskManager.wip_task);
        $(".done_button").click(TaskManager.done_task);
        $("#assignTaskModal_button").click(TaskManager.assign_user);
        $("#assignTaskModal").modal('hide');
        $("#tasks > .pagination a").click(TaskManager.load_tasks);
    }
};

$(TaskManager.setup);