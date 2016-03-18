describe('Job Categories', function () {
  beforeEach(function () {
    loadFixtures('job_categories.html');
  });
  describe("Add job category", function () {
    beforeEach(function () {
      $('#add_category_button').click(AgencyData.add_job_category);
    });
    it('calls ajax to add job category', function() {
      spyOn($, 'ajax');
      $('#add_category_button').trigger('click');
      expect($.ajax).toHaveBeenCalled();
    });
    it('retrieves data fields from modal', function () {
      // Populate data fields in modal
      $('#add_category_name').val('New Category');
      $('#add_category_desc').val('New Category Description');

      var user_data = {'job_category[name]': 'New Category',
                       'job_category[description]': 'New Category Description'};

      spyOn($, 'ajax').and.callFake(function(ajaxArgs) {
        expect(ajaxArgs.data).toEqual(user_data);
      });
      $('#add_category_button').trigger('click');
      expect($.ajax).toHaveBeenCalled();
    });
    it('ajax success: calls function to add category to page', function () {
      spyOn(AgencyData, 'change_job_category_success');
      spyOn($, 'ajax').and.callFake(function(ajaxArgs) {
        ajaxArgs.success('data', '200');
      });
      $('#add_category_button').trigger('click');
      expect(AgencyData.change_job_category_success).toHaveBeenCalled();
    });
    it('ajax error: calls function to handle errors', function () {
      spyOn(ManageData, 'change_data_error');
      spyOn($, 'ajax').and.callFake(function(ajaxArgs) {
        ajaxArgs.error('xhrObj', 'error', 'Unprocessable Entity');
      });
      $('#add_category_button').trigger('click');
      expect(ManageData.change_data_error).toHaveBeenCalled();
    });
  });
  describe('Edit job category', function () {
    beforeEach(function () {
      $('#job_categories_table').on('click',
                    "a[href^='/job_categories/'][href$='edit']",
                                  AgencyData.edit_job_category);
    });
    it('retrieves job_category attributes via ajax', function () {
      spyOn($, 'ajax');
      $("a[href^='/job_categories/'][href$='edit']").trigger('click');
      expect($.ajax).toHaveBeenCalled();
    });
  });
  describe('Update job category', function () {
    beforeEach(function () {
      $('#update_category_button').click(AgencyData.update_job_category);
    });
    it('calls ajax to update job category', function() {
      spyOn($, 'ajax');
      $('#update_category_button').trigger('click');
      expect($.ajax).toHaveBeenCalled();
    });
    it('retrieves data fields from modal', function () {
      // Populate data fields in modal
      $('#update_category_name').val('Updated Category');
      $('#update_category_desc').val('Updated Category Description');

      var user_data = {'job_category[name]': 'Updated Category',
                       'job_category[description]': 'Updated Category Description'};

      spyOn($, 'ajax').and.callFake(function(ajaxArgs) {
        expect(ajaxArgs.data).toEqual(user_data);
      });
      $('#update_category_button').trigger('click');
      expect($.ajax).toHaveBeenCalled();
    });
    it('ajax success: calls function to update category on page', function () {
      spyOn(AgencyData, 'change_job_category_success');
      spyOn($, 'ajax').and.callFake(function(ajaxArgs) {
        ajaxArgs.success('data', '200');
      });
      $('#update_category_button').trigger('click');
      expect(AgencyData.change_job_category_success).toHaveBeenCalled();
    });
    it('ajax error: calls function to handle errors', function () {
      spyOn(ManageData, 'change_data_error');
      spyOn($, 'ajax').and.callFake(function(ajaxArgs) {
        ajaxArgs.error('xhrObj', 'error', 'Unprocessable Entity');
      });
      $('#update_category_button').trigger('click');
      expect(ManageData.change_data_error).toHaveBeenCalled();
    });
  });
  describe('delete job category', function () {
    beforeEach(function () {
      $('#job_categories_table').on('click',
                    "a[data-method='delete']",
                                  AgencyData.delete_job_category);
    });
    it('calls ajax to delete job category', function() {
      spyOn($, 'ajax');
      $("a[data-method='delete']").trigger('click');
      expect($.ajax).toHaveBeenCalled();
    });
    it('uses correct URL in ajax call', function() {
      spyOn($, 'ajax');
      $("a[data-method='delete']").trigger('click');
      expect($.ajax).toHaveBeenCalled();
      expect($.ajax.calls.mostRecent().args[0]['url']).
                           toEqual('/job_categories/201');
    });
    it('ajax success: calls function to update page', function () {
      spyOn(ManageData, 'get_updated_data');
      spyOn($, 'ajax').and.callFake(function(ajaxArgs) {
        ajaxArgs.success('data', '200');
      });
      $("a[data-method='delete']").trigger('click');
      expect(ManageData.get_updated_data).toHaveBeenCalled();
    });
  });
});
