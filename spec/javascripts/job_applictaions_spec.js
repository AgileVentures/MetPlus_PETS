describe('Job Applications', function() {
	var paginationHandler = PaginationHandler("jobs/applied_job_list", '.pagination-div');
	beforeEach( function() {
		loadFixtures('job_applications/job_application.html');
		spyOn(paginationHandler, 'refresh_div');
		spyOn(paginationHandler, 'spinner').and.returnValue(jasmine.createSpyObj('spinner', ['start', 'stop']));

		paginationHandler.setup();
		paginationHandler.init($('.pagination-div'), 0);

	});
	describe('Retrieve job applications using ajax call', function() {
		var request;
		beforeEach( function(){
			jasmine.Ajax.install();
			$('#next-page').trigger('click');
			spyOn(Notification, 'error_notification');
			console.log(paginationHandler);
			request = jasmine.Ajax.requests.mostRecent();
			expect(request.url).toMatch(/\/applied_job_list\/job-applied\?applications_page=2/);
			expect(request.method).toBe('GET');

		});

		afterEach(function() {
			jasmine.Ajax.uninstall();
		});

		it('success', function() {
			request.respondWith(TestResponses.job_applications.paginate.success);
			expect(paginationHandler.refresh_div).toHaveBeenCalledTimes(1);
			expect(Notification.error_notification).not.toHaveBeenCalled();
		});

		it('error', function() {
			request.respondWith(TestResponses.job_applications.paginate.error);
			expect(paginationHandler.refresh_div).toHaveBeenCalledTimes(1);
			expect(Notification.error_notification).toHaveBeenCalledTimes(1);
		});
	});
	describe('Apply application', function() {
		var request;
		beforeEach( function() {
			appendLoadFixtures('job_applications/apply.html');

		});

		afterEach( function() {
		});

		describe('application preview', function() {
			beforeEach( function() {
				jasmine.Ajax.install();
				spyOn(Notification, 'error_notification');
				spyOn(dataHandler, 'load_form');
				handlers.setup();
				$('#jdApplyJobModal').trigger('shown.bs.modal');
				expect('#jdApplyJobModal_button').toBeVisible();

			});
			afterEach( function() {
				jasmine.Ajax.uninstall();
			});

			it('success', function() {
				spyOn($.fn, 'val').and.returnValue(9999);
				$('#jdApplyJobModal_button').trigger('click');
				request = jasmine.Ajax.requests.mostRecent();
				request.respondWith(TestResponses.job_applications.apply.success);
				expect(request.method).toBe('GET');
				expect(Notification.error_notification).not.toHaveBeenCalled();
			});

			it('error', function() {
				spyOn($.fn, 'val').and.returnValue(9999);
				$('#jdApplyJobModal_button').trigger('click');
				request = jasmine.Ajax.requests.mostRecent();
				request.respondWith(TestResponses.job_applications.apply.error);
				expect(request.method).toBe('GET');
				expect(Notification.error_notification).toHaveBeenCalled();
			});

			it('will not load if job seeker is empty', function() {
				spyOn($.fn, 'val').and.returnValue(null);
				spyOn(dataHandler, 'load_preview');
				$('#jdApplyJobModal_button').trigger('click');
				expect(dataHandler.load_preview).not.toHaveBeenCalled();
			});
		});



		describe('application select form', function() {
			beforeEach( function() {
				jasmine.Ajax.install();
				spyOn(dataHandler, 'load_form');
				handlers.setup();
				$("#jd-apply-button").trigger('click');
			});
			afterEach( function() {
				jasmine.Ajax.uninstall();
			});

			it('loads application select form', function() {
				expect(dataHandler.load_form).toHaveBeenCalled();
				expect(request.method).toBe('GET');
			});
		});
	});

	describe('Reject application', function() {
		var request;
		beforeEach( function() {
			appendLoadFixtures('job_applications/reject.html');
			jasmine.Ajax.install();
			$('#confirm_reject').click(RejectAppln.reject_action);
			$('#confirm_reject').trigger('click');
			spyOn(Notification, 'success_notification');
			spyOn(Notification, 'alert_notification');
			request = jasmine.Ajax.requests.mostRecent();
			request.respondWith(TestResponses.job_applications.reject.success);
			expect(request.method).toBe('PATCH');
			nestedRequest = jasmine.Ajax.requests.mostRecent();
			nestedRequest.respondWith(TestResponses.job_applications.reject.success);
			expect(nestedRequest.method).toBe('GET');
		});

		afterEach(function() {
			jasmine.Ajax.uninstall();
		});

		it('calls ajax to reject applications', function() {
			expect(request.status).toEqual(TestResponses.job_applications.reject.success.status);
			expect(Notification.success_notification).toHaveBeenCalled();
		});


		it('submits with reason', function() {
			$('#job_reject_errors').hide();
			expect('#job_reject_errors').not.toBeVisible();
			expect(Notification.alert_notification).not.toHaveBeenCalled();
		});

		it('wont submit without reason', function() {
			$('#reason_text').html('');
			$('#confirm_reject').trigger('click');
			expect('#job_reject_errors').toBeVisible();
			expect($('#job_reject_errors').html()).toBe(
					'Please enter a reason for rejecting this application.');
		}); 
	});	
});
