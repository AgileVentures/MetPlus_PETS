describe('Agency People', function () {
  beforeEach(function () {
    loadFixtures('agency_people/agency_people.html');
  });
  describe('toggle job seeker information', function () {
    beforeEach(function () {
      $('#assign_jd').click(AssignAgencyPerson.assign_action);
    });
    it('toggles the display of job seeker info', function() {
      spyOn($, 'ajax');
      $('#assign_jd').trigger('click');
      expect($.ajax).toHaveBeenCalled();
    });
  });
});
