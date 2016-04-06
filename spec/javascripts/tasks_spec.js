describe('Tasks', function () {
  beforeEach(function () {
      loadFixtures('tasks/task_list.html');
      TaskManagerHolder('mine-open-tasks', 'mine-open');
      TaskModal.setup();
  });
  describe("Check pagination", function () {
    it('calls ajax to add job category', function () {
      spyOn($, 'ajax');
      $('#next-page').trigger('click');
      expect($.ajax).toHaveBeenCalled();
    });
  });
  describe("Work In progress logic", function () {
    it('calls ajax to add job category', function () {
      spyOn($, 'ajax').and.callFake(function(ajaxArgs) {
        expect(ajaxArgs.url).toEqual("/task/2/in_progress");
      }).and.callFake(function(ajaxArgs) {
        expect(ajaxArgs.url).toEqual("/task/2/in_progress");
      });
      $('.wip_button').trigger('click');
      expect($.ajax).toHaveBeenCalled();
    });
  });
});