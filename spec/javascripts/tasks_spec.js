describe('Tasks', function () {
    var taskManager = TaskManagerHolder('mine-open-tasks', 'mine-open');
    beforeEach(function () {
        loadFixtures('tasks/task_list.html');
        taskManager.init();
        TaskModal.setup();
    });
    describe("Check pagination", function () {
        it('calls ajax to add job category', function () {
            spyOn($, 'ajax');
            $('#next-page').triggerHandler('click');
            expect($.ajax).toHaveBeenCalled();
            expect($.ajax.calls.mostRecent().args[0]["url"]).toEqual("http://localhost:8888/task/tasks/mine-open?tasks_page=2");
        });
    });
    describe("Assigned to in progress", function () {
        var request;
        beforeEach(function(){
            jasmine.Ajax.install();
            $('.wip_button').trigger('click');
            spyOn(taskManager, 'success_notification');
            spyOn(taskManager, 'error_notification');
            spyOn(taskManager, 'refresh_tasks');
            request = jasmine.Ajax.requests.mostRecent();
            expect(request.url).toBe('/task/2/in_progress');
            expect(request.method).toBe('PATCH');
        });
        afterEach(function(){
            jasmine.Ajax.uninstall();
        });
        it('success', function () {
            request.respondWith(TestResponses.tasks.wip.success);
            expect(taskManager.success_notification).toHaveBeenCalledWith('Work on the task started');
            expect(taskManager.refresh_tasks).toHaveBeenCalled();
            expect(taskManager.error_notification).not.toHaveBeenCalled();
        });
        it('task not found', function () {
            request.respondWith(TestResponses.tasks.wip.task_not_found);
            expect(taskManager.success_notification).not.toHaveBeenCalled();
            expect(taskManager.refresh_tasks).not.toHaveBeenCalled();
            expect(taskManager.error_notification).toHaveBeenCalledWith('Cannot find the task!');
        });
        it('error', function () {
            request.respondWith(TestResponses.tasks.wip.error_assigning);
            expect(taskManager.success_notification).not.toHaveBeenCalled();
            expect(taskManager.refresh_tasks).not.toHaveBeenCalled();
            expect(taskManager.error_notification).toHaveBeenCalledWith('Error message');
        });
    });
    describe("In progress to done", function () {
        var request;
        beforeEach(function(){
            jasmine.Ajax.install();
            $('.done_button').trigger('click');
            spyOn(taskManager, 'success_notification');
            spyOn(taskManager, 'error_notification');
            spyOn(taskManager, 'refresh_tasks');
            request = jasmine.Ajax.requests.mostRecent();
            expect(request.url).toBe('/task/3/done');
            expect(request.method).toBe('PATCH');
        });
        afterEach(function(){
            jasmine.Ajax.uninstall();
        });
        it('success', function () {
            request.respondWith(TestResponses.tasks.wip.success);
            expect(taskManager.success_notification).toHaveBeenCalledWith('Work on the task is done');
            expect(taskManager.refresh_tasks).toHaveBeenCalled();
            expect(taskManager.error_notification).not.toHaveBeenCalled();
        });
        it('task not found', function () {
            request.respondWith(TestResponses.tasks.wip.task_not_found);
            expect(taskManager.success_notification).not.toHaveBeenCalled();
            expect(taskManager.refresh_tasks).not.toHaveBeenCalled();
            expect(taskManager.error_notification).toHaveBeenCalledWith('Cannot find the task!');
        });
        it('error', function () {
            request.respondWith(TestResponses.tasks.wip.error_assigning);
            expect(taskManager.success_notification).not.toHaveBeenCalled();
            expect(taskManager.refresh_tasks).not.toHaveBeenCalled();
            expect(taskManager.error_notification).toHaveBeenCalledWith('Error message');
        });
    });
});