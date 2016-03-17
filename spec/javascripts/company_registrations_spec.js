describe('Company Registration', function () {
  describe("Clicking 'Send email' button", function () {
    beforeEach(function () {
      loadFixtures('company_registration.html');
      expect($('#send_button')).toBeVisible();
      // the line below is a work-around due to loading HTML fixture after
      // document 'ready' events have occurred (hence event won't be bound to
      //  this button otherwise)
      // (http://stackoverflow.com/questions/17800388/
      // best-practice-for-binding-event-handlers-in-
      // jasmine-tests-that-use-fixtures)
      $('#send_button').click(RegistrationDeny.deny_action);
      // Confirm binding just to be sure ...
      expect($('#send_button')).toHandleWith('click', RegistrationDeny.deny_action);
    });
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
