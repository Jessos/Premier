/*
        @Description:       Scheduler to run Batch_LeaveLedger at specified time
        @Scrum:             SC-11619
        @TestClass:         TestScheduler_Batch_LeaveLedger
        @CreatedBy:         Sethuraman

Change History 
***************************************************************************************************************
    SCRUM          ModifiedBy          Date            Requested By            Description                   Tag
***************************************************************************************************************

*/

global class Scheduler_Batch_LeaveLedger implements Schedulable {
   global void execute(SchedulableContext SC) {
      Database.executeBatch(new Batch_LeaveLedger()); 
   }
}