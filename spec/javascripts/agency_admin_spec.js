describe('Job Categories', function () {
  describe("Add job category", function () {
    beforeEach(function () {
      loadFixtures('job_categories.html');
      $('#add_category_button').click(AgencyData.add_job_category);
      // Confirm binding just to be sure ...
      expect($('#add_category_button')).toHandleWith('click',
                                      AgencyData.add_job_category);
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
      loadFixtures('job_categories.html');
      $('#job_categories_table').on('click',
                    "a[href^='/job_categories/'][href$='edit']",
                                  AgencyData.edit_job_category);
      // Confirm binding just to be sure ...
      expect($('#job_categories_table')).toHandleWith('click',
                                  AgencyData.edit_job_category);
    });
  });
});
