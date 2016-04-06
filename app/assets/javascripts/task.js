var TaskManager = function (holder_id, task_type) {

    var self = this;
    this.last_load_url = "/task/tasks/" + task_type;

    this.load_assign_modal = function (event) {
        console.log("load_assign_modal");
        var task_id = $(this).data("task-id");
        $("#task_assign_select").select2({
            placeholder: "Select the user",
            ajax: {
                url: "/task/" + task_id + "/list_owners",
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
        $('#assignTaskModal_button').data('location',self.holder_id);
    };

    this.load_tasks_from_url = function(url) {
        $("#" + this.holder_id).html("Page is loading...");
        self.last_load_url = url;
        $.ajax({type: 'GET',
            url: url,
            data: {},
            timeout: 5000,
            success: function (data){
                $("#" + self.holder_id).html(data);
                self.init();
                console.log('updated tasks()');
            },
            error: function (xhrObj, status, exception) {
                noty({text: 'Unable to retrieve the tasks for the user',
                    theme: 'bootstrapTheme',
                    layout: 'bottomRight',
                    type: 'error'});
            }
        });
    };
    this.refresh_tasks = function () {
        self.load_tasks_from_url(self.last_load_url);
    };
    this.load_tasks = function() {
        self.load_tasks_from_url(this.href);
        return false;
    };

    this.wip_task = function() {
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
                self.refresh_tasks();
            },
            error: function (xhrObj, status, exception) {
                noty({text: xhrObj['message'],
                    theme: 'bootstrapTheme',
                    layout: 'bottomRight',
                    type: 'error'});
            }
        });
        return false;
    };
    this.done_task = function() {
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
                self.refresh_tasks();
            },
            error: function (xhrObj, status, exception) {
                noty({text: xhrObj['message'],
                    theme: 'bootstrapTheme',
                    layout: 'bottomRight',
                    type: 'error'});
            }
        });
        return false;
    };
    this.holder_id = holder_id;

    this.init = function() {
        $("#" + self.holder_id).find(".assign_button").click(self.load_assign_modal);
        $("#" + self.holder_id).find(".wip_button").click(self.wip_task);
        $("#" + self.holder_id).find(".done_button").click(self.done_task);
        $("#" + self.holder_id).find(".pagination a").click(self.load_tasks);
    };
    this.init();
};


var __TaskManagerHolder = {};
var TaskManagerHolder = function(holder_id, task_type) {
    if(!__TaskManagerHolder.hasOwnProperty(holder_id)){
        __TaskManagerHolder[holder_id] = new TaskManager(holder_id, task_type);
    }
    return __TaskManagerHolder[holder_id];
};

$(document).ready( function() {
    $('#assignTaskModal').on('shown.bs.modal', function (e) {
        console.log("going to set the button option");
        $('#assignTaskModal_button').click( function() {
            if ($("#task_assign_select").val() === null) {
                return;
            }
            var url = $('#task_assign_select').closest('form').attr('action');
            var post_data = {to: $("#task_assign_select").val()};
            $.ajax({
                type: 'PATCH',
                url: url,
                data: post_data,
                timeout: 5000,
                success: function () {
                    noty({
                        text: 'Task assigned',
                        theme: 'bootstrapTheme',
                        layout: 'bottomRight',
                        type: 'success'
                    });
                    TaskManagerHolder($('#assignTaskModal_button').data('location'), "").refresh_tasks();
                    $("#assignTaskModal").modal('hide');
                },
                error: function (xhrObj, status, exception) {
                    noty({
                        text: xhrObj['message'],
                        theme: 'bootstrapTheme',
                        layout: 'bottomRight',
                        type: 'error'
                    });
                }
            });
            return false;
        });
    });
    $('#assignTaskModal').on('hidden.bs.modal', function (e) {
        $('#assignTaskModal_button').unbind('click');
    });

    $("#assignTaskModal").modal('hide');
});