@isTest
private class TestScheduleAutoUpdateStatus{
static testMethod void TestScheduleAutoUpdateStatus() {
ScheduleAutoUpdateStatus bc = new ScheduleAutoUpdateStatus();
 string Query = 'SELECT ID FROM contact Limit 1';
 SchedulableContext schedule;
        bc.execute(schedule);
       
}
}