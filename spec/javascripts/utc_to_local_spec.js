  // https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
describe('Convert UTC to local Time', function () {
  beforeEach(function () {
    loadFixtures('utc_to_local/utc_time.html');
  });

  it('New York', function () {
    spyOn(moment.tz, 'guess').and.returnValue('America/New_York');
    utcToLocal.setup();
    ele = $('.utc_to_local_time')[0];
    expect($(ele).text()).toEqual('November 7, 2016 1:04 PM');
  });

  it('Johannesburg', function () {
    spyOn(moment.tz, 'guess').and.returnValue('Africa/Johannesburg');
    utcToLocal.setup();
    ele = $('.utc_to_local_time')[0];
    expect($(ele).text()).toEqual('November 7, 2016 8:04 PM');
  });

  it('London', function () {
    spyOn(moment.tz, 'guess').and.returnValue('Europe/London');
    utcToLocal.setup();
    ele = $('.utc_to_local_time')[0];
    expect($(ele).text()).toEqual('November 7, 2016 6:04 PM');
  });

  it('Shanghai', function () {
    spyOn(moment.tz, 'guess').and.returnValue('Asia/Shanghai');
    utcToLocal.setup();
    ele = $('.utc_to_local_time')[0];
    expect($(ele).text()).toEqual('November 8, 2016 2:04 AM');
  });

  it('Hawaii', function () {
    spyOn(moment.tz, 'guess').and.returnValue('US/Hawaii');
    utcToLocal.setup();
    ele = $('.utc_to_local_time')[0];
    expect($(ele).text()).toEqual('November 7, 2016 8:04 AM');
  });
});
