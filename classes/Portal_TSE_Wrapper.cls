/**
 * Created by adelaide on 6/12/17.
 * Wrapper to hold daily entries with start/end 24 hrs time entry
 *
 * May 25, AG: SC-18288: Add Break Start End Times
 */

public with sharing class Portal_TSE_Wrapper{
    public tc9_ti__Time_Sheet_Entry__c tsEntry {get;set;}
    public String startTimeHrs_24 {get;set;}
    public String endTimeHrs_24 {get;set;}
    public String startTimeMins_24 {get;set;}
    public String endTimeMins_24 {get;set;}
    public Boolean selected {get; set;}
    public Boolean show {get;set;}
    public String startEndTime {get;set;}
    public String publicHoliday {get;set;}
    public Boolean pubHol {get;set;}

    public String breakStartHrs_24 {get;set;}
    public String breakEndHrs_24 {get;set;}
    public String breakStartMins_24 {get;set;}
    public String breakEndMins_24 {get;set;}
    public String breakStartEndTime {get;set;}

//    public Portal_TSE_Wrapper(tc9_ti__Time_Sheet_Entry__c tseRec, String tseTimeStart, String tseTimeEnd, Boolean selected, String tseBreakTimeStart, String tseBreakTimeEnd) {
    public Portal_TSE_Wrapper(tc9_ti__Time_Sheet_Entry__c tseRec, Boolean selected) {

        this.tsEntry = tseRec;

        this.startTimeHrs_24 = tseRec.tc9_ti__StartTime__c.left(2); //tseTimeStart.left(2);
        this.startTimeMins_24 = tseRec.tc9_ti__StartTime__c.right(2); //tseTimeStart.right(2);

        this.endTimeHrs_24 = tseRec.tc9_ti__EndTime__c.left(2); //tseTimeEnd.left(2);
        this.endTimeMins_24 = tseRec.tc9_ti__EndTime__c.right(2); //tseTimeEnd.right(2);

        this.startEndTime = this.startTimeHrs_24+':'+this.startTimeMins_24+' - '+this.endTimeHrs_24+':'+this.endTimeMins_24;
        system.debug('startTimeHrs_24: '+startTimeHrs_24+' startTimeMins_24:'+startTimeMins_24+' endTimeHrs_24: '+endTimeHrs_24+' endTimeMins_24:'+endTimeMins_24);


        this.breakStartHrs_24 = tseRec.Break_Start_Time__c.left(2);//tseBreakTimeStart.left(2);
        this.breakStartMins_24 = tseRec.Break_Start_Time__c.right(2);//tseBreakTimeStart.right(2);

        this.breakEndHrs_24 = tseRec.Break_End_Time__c.left(2); //tseBreakTimeEnd.left(2);
        this.breakEndMins_24 = tseRec.Break_End_Time__c.right(2); //tseBreakTimeEnd.right(2);

        system.debug('breakStartHrs_24: '+breakStartHrs_24+' breakStartMins_24:'+breakStartMins_24+' breakEndHrs_24: '+breakEndHrs_24+' breakEndMins_24:'+breakEndMins_24);

        this.breakStartEndTime = this.breakStartHrs_24+':'+this.breakStartMins_24+' - '+this.breakEndHrs_24+':'+this.breakEndMins_24;
        system.debug('breakStartEndTime: '+breakStartEndTime);

        this.selected = selected;
        system.debug('Wrapper8');
        if(selected){
            this.show = false;
        }else{
            this.show = true;
        }
    }
}