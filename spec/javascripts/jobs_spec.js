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
