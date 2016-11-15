describe('UTC to local time', function () {
  it ('should return the appropriate hour and day provided a UTC hour and day', function (){
         // Thursdays at 2 a.m. UTC
         const result = DateMath.getDayHourForClient(4, 2);
         // Wednesdays at 8 p.m. Chicago
         expect(result.day).toEqual(3);
         expect(result.hour).toEqual(20);
     });
  });
});
