describe('Tasks', function () {
  beforeEach(function () {
      loadFixtures('tasks/task_list.html');
      TaskManagerHolder('mine-open-tasks', 'mine-open')
  });
  describe("Check pagination", function () {
      it('calls ajax to add job category', function () {
          spyOn($, 'ajax');
          $('#add_job_category_button').trigger('click');
          expect($.ajax).toHaveBeenCalled();
      });
  });
});