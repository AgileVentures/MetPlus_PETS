/**
 * Created by joao on 4/19/16.
 */
describe('Jobs', function () {
    var paginationManager = PaginationManager("/jobs/list/", '.jobs-view', 'job-type');
    beforeEach(function () {
        loadFixtures('jobs/all_list.html');
        spyOn(paginationManager, 'refresh_div');
        paginationManager.setup();
        paginationManager.init($('.jobs-view'), 0);
    });
    describe("Retrieve jobs using ajax call", function () {
        var request;
        beforeEach(function(){
            jasmine.Ajax.install();
            $('#next-page').trigger('click');
            spyOn(Notification, 'error_notification');
            console.log(paginationManager);
            request = jasmine.Ajax.requests.mostRecent();
            expect(request.url).toMatch(/\/jobs\/list\/my-company-all\?jobs_page=2/);
            expect(request.method).toBe('GET');
        });
        afterEach(function(){
            jasmine.Ajax.uninstall();
        });
        it('success', function () {
            request.respondWith(TestResponses.jobs.paginate.success);
            expect(paginationManager.refresh_div).toHaveBeenCalledTimes(1);
            expect(Notification.error_notification).not.toHaveBeenCalled();
        });
    });
});
