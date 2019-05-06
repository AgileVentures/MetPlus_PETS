var TaskManager = function (holder_id, task_type) {

    var self = this;

    this.load_assign_modal = function (event) {
		    $('#task_assign_select').val('');
        var task_id = $(this).data("task-id");
        $("#task_assign_select").select2({
            placeholder: "Select the user",
            ajax: {
                url: "/tasks/" + task_id + "/list_owners",
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
        $('#task_assign_select').closest('form').attr('action','/tasks/' + task_id + '/assign');
        $('#assignTaskModal_button').data('location',self.holder_id);
    };
    this.refresh_tasks = function () {
        self.unsetTaskHolder();
        $("#" + self.holder_id).trigger('pagination:reload');
    };
    this.refresh_all_task_lists = function() {
      for (var taskManager in __TaskManagerHolder) {
        TaskManagerHolder(taskManager).refresh_tasks();
      }
    };
    this.wip_task = function(event) {
        event.preventDefault();
        var url = $(this).data("url");
        $.ajax({type: 'PATCH',
            url: url,
            data: {},
            timeout: 5000,
            success: function (){
                Notification.success_notification('Work on the task started');
                self.refresh_all_task_lists();
            },
            error: function (xhrObj, status, exception) {
                Notification.error_notification(xhrObj.responseJSON['message']);
            }
        });
    };
    this.done_task = function() {
        var url = $(this).data("url");
        $.ajax({type: 'PATCH',
            url: url,
            data: {},
            timeout: 5000,
            success: function (){
                Notification.success_notification('Work on the task is done');
                self.refresh_all_task_lists();
            },
            error: function (xhrObj, status, exception) {
                Notification.error_notification(xhrObj.responseJSON['message']);
            }
        });
        return false;
    };
    this.holder_id = holder_id;

    this.unsetTaskHolder = function () {
        delete __TaskManagerHolder[self.holder_id];
    };

    this.init = function() {
        var obj = $("#" + self.holder_id);
        obj.find(".assign_button").off('click').click(self.load_assign_modal);
        obj.find(".wip_button").off('click').click(self.wip_task);
        obj.find(".done_button").off('click').click(self.done_task);
        PaginationFunctions.addFunction(self.holder_id, undefined, undefined, self.unsetTaskHolder);
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

var TaskModal = {
  setup: function() {
      $('#assignTaskModal').on('shown.bs.modal', function (e) {
          $('#assignTaskModal_button').off('click').click( function() {
              if ($("#task_assign_select").val() === null) {
                  return;
              }
              var url = $('#task_assign_select').closest('form').attr('action') + '/' + $("#task_assign_select").val();
              var post_data = {};

              $.ajax({
                  type: 'PATCH',
                  url: url,
                  data: post_data,
                  timeout: 5000,
                  success: function () {
                      Notification.success_notification('Task assigned');
                      TaskManagerHolder($('#assignTaskModal_button').data('location'), "").refresh_all_task_lists();
                      $("#assignTaskModal").modal('hide');
                  },
                  error: function (xhrObj, status, exception) {
                      Notification.error_notification(xhrObj.responseJSON['message']);
                  }
              });
              return false;
          });
      });
      $('#assignTaskModal').on('hidden.bs.modal', function (e) {
          $('#assignTaskModal_button').unbind('click');
      });
      try {
          $("#assignTaskModal").modal('hide');
      } catch(err) {}
  }
};

$( document ).on('turbolinks:load', function() {
    TaskModal.setup();
});