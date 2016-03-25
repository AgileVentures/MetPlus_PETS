describe('Receive and process events', function () {
  beforeEach(PusherControl.setup());
  describe('Job Seeker registered', function () {
    it('calls correct URL with ajax', function () {
      spyOn($, 'ajax');
      $('#send_button').trigger('click');
      expect($.ajax).toHaveBeenCalled();
      expect($.ajax.calls.mostRecent().args[0]['url']).
                      toEqual('/admin/company_registrations/1/deny');
    });
    it('updates company status', function() {
      return_val = readFixtures('registration_denied.html');
      spyOn($, 'ajax').and.callFake(function(ajaxArgs) {
        // The 'fake' function has access to all arguments specified to $.ajax(),
        // so ajax argument values can be specified here.

        // Call the 'success' function (ajax callback) with the expected
        // returned data (return_val) and 'OK' HTTP status
        ajaxArgs.success(return_val, '200');
      });

      $('#send_button').trigger('click');
      expect($.ajax).toHaveBeenCalled();
      expect($('#company_status').html()).toContain('Registration Denied');
    });
  });
});
