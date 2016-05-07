describe('Tasks', function () {
    var taskManager = TaskManagerHolder('mine-open-tasks', 'mine-open');
    var paginationHandler = PaginationHandler("/jobs/list/my-company-all", '.pagination-div');
    beforeEach(function () {
        loadFixtures('tasks/task_list.html');
        taskManager.init();
        TaskModal.setup();
        spyOn(paginationHandler, 'refresh_div');
        spyOn(paginationHandler, 'spinner').and.returnValue(jasmine.createSpyObj('spinner', ['start', 'stop']));
        paginationHandler.setup();
        paginationHandler.init($('.pagination-div'), 0);
    });
    describe("Retrieve tasks using ajax call", function () {
        var request;
        beforeEach(function(){
            jasmine.Ajax.install();
            $('#next-page').trigger('click');
            spyOn(Notification, 'error_notification');
            spyOn(taskManager, 'init');
            request = jasmine.Ajax.requests.mostRecent();
            expect(request.url).toMatch(/\/tasks\/tasks\/mine-open\?tasks_page=2/);
            expect(request.method).toBe('GET');
        });
        afterEach(function(){
            jasmine.Ajax.uninstall();
        });
        it('success', function () {
            request.respondWith(TestResponses.tasks.paginate.success);
            expect(Notification.error_notification).not.toHaveBeenCalled();
        });
    });
    describe("Assigned to in progress", function () {
        var request;
        beforeEach(function(){
            jasmine.Ajax.install();
            $('.wip_button').trigger('click');
            spyOn(Notification, 'success_notification');
            spyOn(Notification, 'error_notification');
            spyOn(taskManager, 'refresh_tasks');
            request = jasmine.Ajax.requests.mostRecent();
            expect(request.url).toBe('/tasks/2/in_progress');
            expect(request.method).toBe('PATCH');
        });
        afterEach(function(){
            jasmine.Ajax.uninstall();
        });
        it('success', function () {
            request.respondWith(TestResponses.tasks.wip.success);
            expect(Notification.success_notification).toHaveBeenCalledWith('Work on the task started');
            expect(taskManager.refresh_tasks).toHaveBeenCalled();
            expect(Notification.error_notification).not.toHaveBeenCalled();
        });
        it('task not found', function () {
            request.respondWith(TestResponses.tasks.wip.task_not_found);
            expect(Notification.success_notification).not.toHaveBeenCalled();
            expect(taskManager.refresh_tasks).not.toHaveBeenCalled();
            expect(Notification.error_notification).toHaveBeenCalledWith('Cannot find the task!');
        });
        it('error', function () {
            request.respondWith(TestResponses.tasks.wip.error_assigning);
            expect(Notification.success_notification).not.toHaveBeenCalled();
            expect(taskManager.refresh_tasks).not.toHaveBeenCalled();
            expect(Notification.error_notification).toHaveBeenCalledWith('Error message');
        });
    });
    describe("In progress to done", function () {
        var request;
        beforeEach(function(){
            jasmine.Ajax.install();
            $('.done_button').trigger('click');
            spyOn(Notification, 'success_notification');
            spyOn(Notification, 'error_notification');
            spyOn(taskManager, 'refresh_tasks');
            request = jasmine.Ajax.requests.mostRecent();
            expect(request.url).toBe('/tasks/3/done');
            expect(request.method).toBe('PATCH');
        });
        afterEach(function(){
            jasmine.Ajax.uninstall();
        });
        it('success', function () {
            request.respondWith(TestResponses.tasks.wip.success);
            expect(Notification.success_notification).toHaveBeenCalledWith('Work on the task is done');
            expect(taskManager.refresh_tasks).toHaveBeenCalled();
            expect(Notification.error_notification).not.toHaveBeenCalled();
        });
        it('task not found', function () {
            request.respondWith(TestResponses.tasks.wip.task_not_found);
            expect(Notification.success_notification).not.toHaveBeenCalled();
            expect(taskManager.refresh_tasks).not.toHaveBeenCalled();
            expect(Notification.error_notification).toHaveBeenCalledWith('Cannot find the task!');
        });
        it('error', function () {
            request.respondWith(TestResponses.tasks.wip.error_assigning);
            expect(Notification.success_notification).not.toHaveBeenCalled();
            expect(taskManager.refresh_tasks).not.toHaveBeenCalled();
            expect(Notification.error_notification).toHaveBeenCalledWith('Error message');
        });
    });
});
