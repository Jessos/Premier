/*
        @Description:       Scheduler to run Batch_LeaveAccrual at specified time
        @Scrum:             SC-14579
        @TestClass:         TestScheduler_Batch_LeaveAccrual
        @CreatedBy:         Sethuraman

Change History 
***************************************************************************************************************
    SCRUM          ModifiedBy          Date            Requested By            Description                   Tag
***************************************************************************************************************

*/

global class Scheduler_Batch_LeaveAccrual implements Schedulable {
   global void execute(SchedulableContext SC) {
      Database.executeBatch(new Batch_LeaveAccrual(null, null, 'Scheduler')); 
   }
}