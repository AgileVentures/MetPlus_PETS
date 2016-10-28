describe('Agency People', function () {
  beforeEach(function () {
    loadFixtures('agency_people/agency_people.html');
    AssignAgencyPerson.setup();
  });

  describe('toggle job seeker information', function () {
    beforeEach(function(done) {
      $('#toggle_info').click(ManageData.toggle);
      $('#toggle_info').trigger('click');
      setTimeout(function() {
        done();
      }, 1000);
    });
    it('hides and shows the job seeker info', function() {
      expect($('#info_table')).toBeHidden();
      $('#toggle_info').trigger('click');
      expect($('#info_table')).toBeVisible();
    });
  });

  describe ('assign job developer to job seeker', function() {
    it('calls ajax to perform assignment', function() {
      spyOn($, 'ajax')
      $('#assign_jd').trigger('click');
      expect($.ajax).toHaveBeenCalled();
    });
    it('ajax success: updates DOM', function () {
      spyOn($, 'ajax').and.callFake(function(ajaxArgs) {
        ajaxArgs.success('Job Developer', '200');
      });
      $('#assign_jd').trigger('click');
      expect($('#assigned_job_developer').text()).toBe('Job Developer');
    });
    it('ajax error: notification', function() {
      var err = {responseJSON: {message: 'Unknown agency role specified'}};

      spyOn(Notification, 'error_notification');
      spyOn($, 'ajax').and.callFake(function(ajaxArgs) {
        ajaxArgs.error(err, '400');
      });
      $('#assign_jd').trigger('click');
      expect(Notification.error_notification).
              toHaveBeenCalledWith('Unknown agency role specified');
    });
  });

  describe ('assign job developer to case manager', function() {
    it('calls ajax to perform assignment', function() {
      spyOn($, 'ajax')
      $('#assign_cm').trigger('click');
      expect($.ajax).toHaveBeenCalled();
    });
    it('ajax success: updates DOM', function () {
      spyOn($, 'ajax').and.callFake(function(ajaxArgs) {
        ajaxArgs.success('Case Manager', '200');
      });
      $('#assign_cm').trigger('click');
      expect($('#assigned_case_manager').text()).toBe('Case Manager');
    });
    it('ajax error: notification', function() {
      var err = {responseJSON: {message: 'Unknown agency role specified'}};

      spyOn(Notification, 'error_notification');
      spyOn($, 'ajax').and.callFake(function(ajaxArgs) {
        ajaxArgs.error(err, '400');
      });
      $('#assign_cm').trigger('click');
      expect(Notification.error_notification).
              toHaveBeenCalledWith('Unknown agency role specified');
    });
  });
});
