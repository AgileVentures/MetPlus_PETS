  // https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
describe('Convert UTC to local Time', function () {
  beforeEach(function () {
    loadFixtures('utc_to_local/utc_time.html');
    utcToLocal.setup();
    jasmine.clock().install();
  });

  afterEach(function() {
   jasmine.clock().uninstall();
  });

  it('should return the utc local time for New York', function () {
    expect($('#.utc_to_local_time')).toHaveBeenCalled();
    jasmine.clock().mockDate(utcToLocal);
    moment.tz.guess('America/New_York');
    jasmine.clock().tick(-5);
    expect($('#.utc_to_local_time').calls.count()).toEqual(-5);
  });


});
//     // set local timezone so "moment.tz.guess()"" will detect that, or,
//     // stub "moment.tz.guess()" function to return a specific timezone string
//     // (see timezone strings in above link)
//     // here. we want to use timezone 'America/New_York'
//
//     utcToLocal.setup();  // convert UTC time to local time in the DOM
//     ele = $('.utc_to_local_time')[0]  // Get the converted span element
//
//     // test that timezone in the DOM is equal to expected timezone
//     // hint: use $('ele').text()
//   });
//
//   it('Johannesburg', function () {
//     // tz = 'Africa/Johannesburg'
//
//   });
//
//   it('London', function () {
//     // tz = 'Europe/London'
//   });
// });
// Contact GitHub API Training Shop Blog About

// it('should return the utc local time for Johannesburg', function () {
//   var baseTime = new Date(2013, 9, 23);
//   jasmine.clock().mockDate(baseTime);
//
//   jasmine.clock().tick(50);
//   expect(new Date().getTime()).toEqual(baseTime.getTime() + 50);
// });
//
// it('should return the utc local time for London', function () {
//   var baseTime = new Date(2013, 9, 23);
//   jasmine.clock().mockDate(baseTime);
//
//   jasmine.clock().tick(50);
//   expect(new Date().getTime()).toEqual(baseTime.getTime() + 50);
// });
//
// it('should return the utc local time for China', function () {
//   var baseTime = new Date(2013, 9, 23);
//   jasmine.clock().mockDate(baseTime);
//
//   jasmine.clock().tick(50);
//   expect(new Date().getTime()).toEqual(baseTime.getTime() + 50);
// });
//
// it('should return the utc local time for Australia', function () {
//   var baseTime = new Date(2013, 9, 23);
//   jasmine.clock().mockDate(baseTime);
//
//   jasmine.clock().tick(50);
//   expect(new Date().getTime()).toEqual(baseTime.getTime() + 50);
// });
