describe('Job Categories', function () {
  beforeEach(function () {
    loadFixtures('agency_admin/job_categories.html');
  });
  describe("Add job category", function () {
    beforeEach(function () {
      $('#add_job_category_button').click(AgencyData.add_job_category);
    });
    it('calls ajax to add job category', function() {
      spyOn($, 'ajax');
      $('#add_job_category_button').trigger('click');
      expect($.ajax).toHaveBeenCalled();
    });
    it('retrieves data fields from modal', function () {
      // Populate data fields in modal
      $('#add_job_category_attr1').val('New Category');
      $('#add_job_category_attr2').val('New Category Description');

      var user_data = {'job_category[name]': 'New Category',
                       'job_category[description]': 'New Category Description'};

      spyOn($, 'ajax').and.callFake(function(ajaxArgs) {
        expect(ajaxArgs.data).toEqual(user_data);
      });
      $('#add_job_category_button').trigger('click');
      expect($.ajax).toHaveBeenCalled();
    });
    it('ajax success: calls function to add category to page', function () {
      spyOn(AgencyData, 'change_job_property_success');
      spyOn($, 'ajax').and.callFake(function(ajaxArgs) {
        ajaxArgs.success('data', '200');
      });
      $('#add_job_category_button').trigger('click');
      expect(AgencyData.change_job_property_success).toHaveBeenCalled();
    });
    it('ajax error: calls function to handle errors', function () {
      spyOn(ManageData, 'change_data_error');
      spyOn($, 'ajax').and.callFake(function(ajaxArgs) {
        ajaxArgs.error('xhrObj', 'error', 'Unprocessable Entity');
      });
      $('#add_job_category_button').trigger('click');
      expect(ManageData.change_data_error).toHaveBeenCalled();
    });
  });
  describe('Edit job category', function () {
    beforeEach(function () {
      $('#job_categories_table').on('click',
                    "a[href^='/job_categories/'][data-method='edit']",
                                  AgencyData.edit_job_category);
    });
    it('retrieves job_category attributes via ajax', function () {
      spyOn($, 'ajax');
      $("a[href^='/job_categories/'][data-method='edit']").trigger('click');
      expect($.ajax).toHaveBeenCalled();
    });
  });
  describe('Update job category', function () {
    beforeEach(function () {
      $('#update_job_category_button').click(AgencyData.update_job_category);
    });
    it('calls ajax to update job category', function() {
      spyOn($, 'ajax');
      $('#update_job_category_button').trigger('click');
      expect($.ajax).toHaveBeenCalled();
    });
    it('retrieves data fields from modal', function () {
      // Populate data fields in modal
      $('#update_job_category_attr1').val('Updated Category');
      $('#update_job_category_attr2').val('Updated Category Description');

      var user_data = {'job_category[name]': 'Updated Category',
                       'job_category[description]': 'Updated Category Description'};

      spyOn($, 'ajax').and.callFake(function(ajaxArgs) {
        expect(ajaxArgs.data).toEqual(user_data);
      });
      $('#update_job_category_button').trigger('click');
      expect($.ajax).toHaveBeenCalled();
    });
    it('ajax success: calls function to update category on page', function () {
      spyOn(AgencyData, 'change_job_property_success');
      spyOn($, 'ajax').and.callFake(function(ajaxArgs) {
        ajaxArgs.success('data', '200');
      });
      $('#update_job_category_button').trigger('click');
      expect(AgencyData.change_job_property_success).toHaveBeenCalled();
    });
    it('ajax error: calls function to handle errors', function () {
      spyOn(ManageData, 'change_data_error');
      spyOn($, 'ajax').and.callFake(function(ajaxArgs) {
        ajaxArgs.error('xhrObj', 'error', 'Unprocessable Entity');
      });
      $('#update_job_category_button').trigger('click');
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
                           toEqual('/job_categories/5');
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
describe('Skills', function () {
  beforeEach(function () {
    loadFixtures('agency_admin/skills.html');
  });
  describe("Add skill", function () {
    beforeEach(function () {
      $('#add_skill_button').click(AgencyData.add_skill);
    });
    it('calls ajax to add skill', function() {
      spyOn($, 'ajax');
      $('#add_skill_button').trigger('click');
      expect($.ajax).toHaveBeenCalled();
    });
    it('retrieves data fields from modal', function () {
      // Populate data fields in modal
      $('#add_skill_attr1').val('New Skill');
      $('#add_skill_attr2').val('New Skill Description');

      var user_data = {'skill[name]': 'New Skill',
                       'skill[description]': 'New Skill Description'};

      spyOn($, 'ajax').and.callFake(function(ajaxArgs) {
        expect(ajaxArgs.data).toEqual(user_data);
      });
      $('#add_skill_button').trigger('click');
      expect($.ajax).toHaveBeenCalled();
    });
    it('ajax success: calls function to add skill to page', function () {
      spyOn(AgencyData, 'change_job_property_success');
      spyOn($, 'ajax').and.callFake(function(ajaxArgs) {
        ajaxArgs.success('data', '200');
      });
      $('#add_skill_button').trigger('click');
      expect(AgencyData.change_job_property_success).toHaveBeenCalled();
    });
    it('ajax error: calls function to handle errors', function () {
      spyOn(ManageData, 'change_data_error');
      spyOn($, 'ajax').and.callFake(function(ajaxArgs) {
        ajaxArgs.error('xhrObj', 'error', 'Unprocessable Entity');
      });
      $('#add_skill_button').trigger('click');
      expect(ManageData.change_data_error).toHaveBeenCalled();
    });
  });
  describe('Edit skill', function () {
    beforeEach(function () {
      $('#skills_table').on('click',
                    "a[href^='/skills/'][data-method='edit']",
                                  AgencyData.edit_skill);
    });
    it('retrieves skill attributes via ajax', function () {
      spyOn($, 'ajax');
      $("a[href^='/skills/'][data-method='edit']").trigger('click');
      expect($.ajax).toHaveBeenCalled();
    });
  });
  describe('Update skill', function () {
    beforeEach(function () {
      $('#update_skill_button').click(AgencyData.update_skill);
    });
    it('calls ajax to update skill', function() {
      spyOn($, 'ajax');
      $('#update_skill_button').trigger('click');
      expect($.ajax).toHaveBeenCalled();
    });
    it('retrieves data fields from modal', function () {
      // Populate data fields in modal
      $('#update_skill_attr1').val('Updated Skill');
      $('#update_skill_attr2').val('Updated Skill Description');

      var user_data = {'skill[name]': 'Updated Skill',
                       'skill[description]': 'Updated Skill Description'};

      spyOn($, 'ajax').and.callFake(function(ajaxArgs) {
        expect(ajaxArgs.data).toEqual(user_data);
      });
      $('#update_skill_button').trigger('click');
      expect($.ajax).toHaveBeenCalled();
    });
    it('ajax success: calls function to update skill on page', function () {
      spyOn(AgencyData, 'change_job_property_success');
      spyOn($, 'ajax').and.callFake(function(ajaxArgs) {
        ajaxArgs.success('data', '200');
      });
      $('#update_skill_button').trigger('click');
      expect(AgencyData.change_job_property_success).toHaveBeenCalled();
    });
    it('ajax error: calls function to handle errors', function () {
      spyOn(ManageData, 'change_data_error');
      spyOn($, 'ajax').and.callFake(function(ajaxArgs) {
        ajaxArgs.error('xhrObj', 'error', 'Unprocessable Entity');
      });
      $('#update_skill_button').trigger('click');
      expect(ManageData.change_data_error).toHaveBeenCalled();
    });
  });
  describe('delete skill', function () {
    beforeEach(function () {
      $('#skills_table').on('click',
                    "a[data-method='delete']",
                                  AgencyData.delete_skill);
    });
    it('calls ajax to delete skill', function() {
      spyOn($, 'ajax');
      $("a[data-method='delete']").trigger('click');
      expect($.ajax).toHaveBeenCalled();
    });
    it('uses correct URL in ajax call', function() {
      spyOn($, 'ajax');
      $("a[data-method='delete']").trigger('click');
      expect($.ajax).toHaveBeenCalled();
      expect($.ajax.calls.mostRecent().args[0]['url']).
                           toEqual('/skills/2');
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
