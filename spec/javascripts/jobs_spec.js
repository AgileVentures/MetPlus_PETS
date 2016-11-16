/**
 * Created by joao on 4/19/16.
 */
describe('Jobs', function () {
    var paginationHandler = PaginationHandler("/jobs/list/my-company-all", '.pagination-div');
    beforeEach(function () {
        loadFixtures('jobs/all_list.html');
        spyOn(paginationHandler, 'refresh_div');
        spyOn(paginationHandler, 'spinner').and.returnValue(jasmine.createSpyObj('spinner', ['start', 'stop']));
        paginationHandler.setup();
        paginationHandler.init($('.pagination-div'), 0);
    });
    describe("Retrieve jobs using ajax call", function () {
        var request;
        beforeEach(function(){
            jasmine.Ajax.install();
            $('#next-page').trigger('click');
            spyOn(Notification, 'error_notification');
            console.log(paginationHandler);
            request = jasmine.Ajax.requests.mostRecent();
            expect(request.url).toMatch(/\/jobs\/list\/my-company-all\?jobs_page=2/);
            expect(request.method).toBe('GET');
        });
        afterEach(function(){
            jasmine.Ajax.uninstall();
        });
        it('success', function () {
            request.respondWith(TestResponses.jobs.paginate.success);
            expect(paginationHandler.refresh_div).toHaveBeenCalledTimes(1);
            expect(Notification.error_notification).not.toHaveBeenCalled();
        });
        it('error', function () {
            request.respondWith(TestResponses.jobs.paginate.error);
            expect(paginationHandler.refresh_div).toHaveBeenCalledTimes(1);
            expect(Notification.error_notification).toHaveBeenCalledTimes(1);
        });
    });
});

describe('Match resume and job', function() {
  beforeEach(function () {
    loadFixtures('jobs/job_show.html');
    JobAndResume.match();
    spyOn(window, 'confirm').and.returnValue(true);
    spyOn(PETS, 'spinner').and
      .returnValue(jasmine.createSpyObj('spinner', ['start', 'stop']));
  });

  it('confirms user intent to perform match', function() {
    spyOn($, 'ajax');
    $('#match_my_resume').trigger('click');
    expect(window.confirm).toHaveBeenCalled();
  });

  it('calls ajax for matching function', function() {
    spyOn($, 'ajax');
    $('#match_my_resume').trigger('click');
    expect($.ajax).toHaveBeenCalled();
  });

  it('calls correct URL with ajax', function () {
    spyOn($, 'ajax');
    $('#match_my_resume').trigger('click');
    expect($.ajax).toHaveBeenCalled();
    expect($.ajax.calls.mostRecent().args[0]['url']).
                    toEqual('/jobs/152/match_resume?job_seeker_id=201');
  });

  it('shows error message if resource not found', function () {
    spyOn(Notification, 'error_notification');
    spyOn($, 'ajax').and.callFake(function(ajaxArgs) {
      var data = {'status': 404, 'message': 'cannot find resource'};
      ajaxArgs.success(data);
    });
    $('#match_my_resume').trigger('click');
    expect(Notification.error_notification).
            toHaveBeenCalledWith('An error occurred: cannot find resource');
  });
});
