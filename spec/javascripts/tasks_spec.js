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
    describe("Work In progress logic", function () {
        beforeEach(function(){
            taskManager.init();
        });
        it('Change job to work in progress', function (done) {
            spyOn($, 'ajax');
            console.log($('.wip_button'));
            console.log($($('.wip_button')[0]));
            $('.wip_button').triggerHandler('click');
            expect($.ajax).toHaveBeenCalled();
            expect($.ajax.calls.mostRecent().args[0]["url"]).toEqual("/task/2/in_progress");
        });
    });
});