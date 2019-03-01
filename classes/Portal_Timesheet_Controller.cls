/**
 * Created by Adelaide Greenaway on 5/12/17.
 *
 * Copyright © 2017 2cloudnine Pty Ltd - Strictly Confidential.
 * Not to be distributed without authorisation
 *
 * Controller to support the 2c9 Timesheet Home Page
 *
 * The Timesheet Home Page is accessible to the user if:
 *  - At least one Placement exists that has timesheets generated;
 *  - 2c9 Portal Community User has been granted access to complete timesheets for that Placement
 * Test Class:
 */

public class Portal_Timesheet_Controller extends Portal_AgreementBase_Controller{//Portal_Base_Controller{
    public List<tc9_ti__Time_Sheet__c> timesheetQueryAllList {get;set;}

    public List<tc9_ti__Time_Sheet__c> timesheetAllList {get;set;}
    public List<tc9_ti__Time_Sheet__c> timesheetApprovedList {get;set;}
    public List<tc9_ti__Time_Sheet__c> timesheetCurrentList {get;set;}
    public List<tc9_ti__Time_Sheet__c> timesheetFutureList {get;set;}
    public List<tc9_ti__Time_Sheet__c> timesheetSubmittedList {get;set;}

    public List<tc9_ti__Time_Sheet__c> approvedTimesheetsToShow {get;set;}
    public List<tc9_ti__Time_Sheet__c> currentTimesheetsToShow {get;set;}
    public List<tc9_ti__Time_Sheet__c> futureTimesheetsToShow {get;set;}
    public List<tc9_ti__Time_Sheet__c> submittedTimesheetsToShow {get;set;}

    public integer approved_counter = 0;
    public integer current_counter = 0;
    public integer future_counter = 0;
    public integer submitted_counter = 0;

    public integer limitsize;

    public integer approved_totalSize = 0;
    public integer current_totalSize = 0;
    public integer future_totalSize = 0;
    public integer submitted_totalSize = 0;

//    public integer allfirstEntry {get;set;}
//    public integer alllastEntry {get;set;}

    public integer approvedTotalEntry {get;set;}
    public integer approvedfirstEntry {get;set;}
    public integer approvedlastEntry {get;set;}

    public integer currentTotalEntry {get;set;}
    public integer currentfirstEntry {get;set;}
    public integer currentlastEntry {get;set;}

    public integer futureTotalEntry {get;set;}
    public integer futurefirstEntry {get;set;}
    public integer futurelastEntry {get;set;}

    public integer submittedTotalEntry {get;set;}
    public integer submittedfirstEntry {get;set;}
    public integer submittedlastEntry {get;set;}

    public Boolean approvedPageTurn {get;set;}
    public Boolean currentPageTurn {get;set;}
    public Boolean futurePageTurn {get;set;}
    public Boolean submittedPageTurn {get;set;}

    public Boolean haveTimesheets {get;set;}

    public Portal_Timesheet_Controller(){

        initialisePageTurns();

        //let's get all timesheets for this payee for a 2 year period only
        timesheetQueryAllList = new List<tc9_ti__Time_Sheet__c>([SELECT Id, Name, tc9_ti__Placement__c, tc9_ti__Candidate__c,
                tc9_ti__Placement__r.Payee__c, tc9_ti__Status__c, tc9_ti__End_Date__c, tc9_ti__Start_Date__c,
                tc9_ti__Placement__r.Name, tc9_ti__Placement__r.Account_Name__c, tc9_ti__Placement__r.ts2__Job__r.Name,
                tc9_ti__WeeklyActualHours__c, tc9_ti__Placement__r.Use_2c9_Portal_Agreement_Logic__c, tc9_ti__Placement__r.X2c9_Portal_Placement_Agreement_Status__c
                FROM tc9_ti__Time_Sheet__c
                WHERE tc9_ti__Placement__r.Payee__c =: currentPayee.Id
                AND tc9_ti__Start_Date__c >= LAST_N_YEARS:2
                AND tc9_ti__End_Date__c <= NEXT_MONTH
                ORDER BY tc9_ti__End_Date__c DESC LIMIT 200]);

        system.debug('Ordered list: '+timesheetQueryAllList);


        //do we have any timesheets for the 2 year period
        if(timesheetQueryAllList.size() > 0){
            haveTimesheets = true;
        }else{
            haveTimesheets = false;
        }

        //now lets get all the sublists for the tabs to display
        timesheetAllList = new List<tc9_ti__Time_Sheet__c>();
        timesheetCurrentList = new List<tc9_ti__Time_Sheet__c>();
        timesheetFutureList = new List<tc9_ti__Time_Sheet__c>();
        timesheetApprovedList = new List<tc9_ti__Time_Sheet__c>();
        timesheetSubmittedList = new List<tc9_ti__Time_Sheet__c>();

        for(tc9_ti__Time_Sheet__c ts : timesheetQueryAllList) {
            /*Lets make sure we only pickup and view the timesheets that are ready for portal
            * - if custom setting use echosign is disabled - get all timesheets for Placements
            * - if custom setting use echosign is enabled
            *   -- per placement: check if agreement logic in place and agreement is complete
            *   */
            //initialise the ability to access timesheets
            if (settings.Use_Echosign__c == false){
                timesheetAllList.add(ts);
            }
            if(settings.Use_Echosign__c == true){
                if(ts.tc9_ti__Placement__r.Use_2c9_Portal_Agreement_Logic__c == false){
                    timesheetAllList.add(ts);
                }
                if(ts.tc9_ti__Placement__r.Use_2c9_Portal_Agreement_Logic__c == true){
                   if(ts.tc9_ti__Placement__r.X2c9_Portal_Placement_Agreement_Status__c != null && ts.tc9_ti__Placement__r.X2c9_Portal_Placement_Agreement_Status__c == 'Complete') {
                       timesheetAllList.add(ts);
                   }
                }
            }
        }
        //now that we have only the accessible timesheets, populate for all the different status types
        if(timesheetAllList.size()>0){
            haveTimesheets = true;
            for(tc9_ti__Time_Sheet__c ts : timesheetAllList){
                //system.debug('ts: '+ts);
                //only get the Timesheets for Placements that have Agreements or do not use Echosign
                if (ts.tc9_ti__Status__c != 'Approved' && ts.tc9_ti__Status__c != 'Submitted') {
                    if (ts.tc9_ti__Status__c == 'New' && ((ts.tc9_ti__End_Date__c >= Date.today().addDays(-21) && ts.tc9_ti__End_Date__c <= Date.today().addDays(7)) || ts.tc9_ti__End_Date__c < Date.today())) {
                        timesheetCurrentList.add(ts);
                    }
                    if (ts.tc9_ti__End_Date__c > Date.today().addDays(7)) {
                        timesheetFutureList.add(ts);
                    }
                    if(ts.tc9_ti__Status__c == 'Rejected') {
                        timesheetCurrentList.add(ts);
                        system.debug('Got Rejected:: '+ts);
                    }
                }
                if (ts.tc9_ti__Status__c == 'Submitted') {
                    timesheetSubmittedList.add(ts);
                }
                if (ts.tc9_ti__Status__c == 'Approved') {
                    timesheetApprovedList.add(ts);
                }

            }
        }else{
            haveTimesheets = false;
        }

        //paginate the lists
        approvedTimesheetsToShow = new List<tc9_ti__Time_Sheet__c>();
        currentTimesheetsToShow = new List<tc9_ti__Time_Sheet__c>();
        futureTimesheetsToShow = new List<tc9_ti__Time_Sheet__c>();
        submittedTimesheetsToShow = new List<tc9_ti__Time_Sheet__c>();

        approved_totalSize = timesheetApprovedList.size();
        current_totalSize = timesheetCurrentList.size();
        future_totalSize = timesheetFutureList.size();
        submitted_totalSize = timesheetSubmittedList.size();

        approvedTotalEntry = approved_totalSize;
        approvedfirstEntry = 1;

        currentTotalEntry = current_totalSize;
        currentfirstEntry = 1;

        futureTotalEntry = future_totalSize;
        futurefirstEntry = 1;

        submittedTotalEntry = submitted_totalSize;
        submittedfirstEntry = 1;

        limitSize = 10;

        //Initial adding of timesheets to TimesheetsToShow
        //check the total records are more than limitSize and assign the records

        //approved
        if((approved_counter+limitSize) <= approved_totalSize){
            for(Integer i=0;i<limitSize;i++){
                approvedTimesheetsToShow.add(timesheetApprovedList.get(i));
            }
            approvedlastEntry = 10;
        }else{
            for(Integer i=0;i<approved_totalSize;i++){
                approvedTimesheetsToShow.add(timesheetApprovedList.get(i));
            }
            approvedlastEntry = approved_totalSize;
        }

        //CURRENT
        if((current_counter+limitSize) <= current_totalSize){
            for(Integer i=0;i<limitSize;i++){
                currentTimesheetsToShow.add(timesheetCurrentList.get(i));
            }
            currentlastEntry=10;
        }else{
            for(Integer i=0;i<current_totalSize;i++){
                currentTimesheetsToShow.add(timesheetCurrentList.get(i));
            }
            currentlastEntry=current_totalSize;
        }

        //FUTURE
        if((future_counter+limitSize) <= future_totalSize){
            for(Integer i=0;i<limitSize;i++){
                futureTimesheetsToShow.add(timesheetFutureList.get(i));
            }
            futurelastEntry=10;
        }else{
            for(Integer i=0;i<future_totalSize;i++){
                futureTimesheetsToShow.add(timesheetFutureList.get(i));
            }
            futurelastEntry=future_totalSize;
        }
        //reverse the sort order for future timesheets
        futureTimesheetsToShow.sort();

        //SUBMITTED
        if((submitted_counter+limitSize) <= submitted_totalSize){
            for(Integer i=0;i<limitSize;i++){
                submittedTimesheetsToShow.add(timesheetSubmittedList.get(i));
            }
            submittedlastEntry=10;
        }else{
            for(Integer i=0;i<submitted_totalSize;i++){
                submittedTimesheetsToShow.add(timesheetSubmittedList.get(i));
            }
            submittedlastEntry=submitted_totalSize;
        }
    }

    public void initialisePageTurns(){

        currentPageTurn = true;

        approvedPageTurn = false;
        futurePageTurn = false;
        submittedPageTurn = false;
    }

    public void nextApproved(){
        approvedTimesheetsToShow.clear();
        approved_counter = approved_counter+limitsize;

        approvedPageTurn = true;

        currentPageTurn = false;
        futurePageTurn = false;
        submittedPageTurn = false;

        approvedfirstEntry=approvedlastEntry+1;
        //approved
        if((approved_counter + limitSize) <= approved_totalSize){
            for(Integer i=approved_counter;i<(approved_counter+limitSize);i++){
                approvedTimesheetsToShow.add(timesheetApprovedList.get(i));
            }
            approvedlastEntry=(approvedfirstEntry-1)+limitsize;
        } else{
            for(Integer i=approved_counter;i<approved_totalSize;i++){
                approvedTimesheetsToShow.add(timesheetApprovedList.get(i));
            }
            approvedlastEntry=approved_totalSize;
        }
    }

    public void previousApproved(){
        approvedTimesheetsToShow.clear();
        approved_counter = approved_counter-limitsize;

        approvedPageTurn = true;

        currentPageTurn = false;
        futurePageTurn = false;
        submittedPageTurn = false;

        for(Integer i=approved_counter;i<(approved_counter+limitSize); i++){
            approvedTimesheetsToShow.add(timesheetApprovedList.get(i));
        }
        approvedfirstEntry=approved_counter+1;
        approvedlastEntry=approved_counter+limitsize;
    }

    public Boolean getDisableNextApproved(){
        if((approved_counter + limitSize) >= approved_totalSize )
            return true ;
        else
            return false ;
    }

    public Boolean getDisablePreviousApproved(){
        if(approved_counter == 0)
            return true ;
        else
            return false ;
    }

    public void nextCurrent(){
        currentTimesheetsToShow.clear();
        current_counter = current_counter+limitsize;

        currentfirstEntry=currentlastEntry+1;

        currentPageTurn = true;

        approvedPageTurn = false;
        futurePageTurn = false;
        submittedPageTurn = false;

        //CURRENT
        if((current_counter + limitSize) <= current_totalSize){
            for(Integer i=current_counter;i<(current_counter+limitSize);i++){
                currentTimesheetsToShow.add(timesheetCurrentList.get(i));
            }
            currentlastEntry=(currentfirstEntry-1)+limitsize;
        } else{
            for(Integer i=current_counter;i<current_totalSize;i++){
                currentTimesheetsToShow.add(timesheetCurrentList.get(i));
            }
            currentlastEntry=current_totalSize;
        }
    }

    public void previousCurrent(){
        currentTimesheetsToShow.clear();
        current_counter = current_counter-limitsize;

        currentPageTurn = true;

        approvedPageTurn = false;
        futurePageTurn = false;
        submittedPageTurn = false;

        for(Integer i=current_counter;i<(current_counter+limitSize); i++){
            currentTimesheetsToShow.add(timesheetCurrentList.get(i));
        }
        currentfirstEntry=current_counter+1;
        currentlastEntry=current_counter+limitsize;
    }

    public Boolean getDisableNextCurrent(){

        if((current_counter + limitSize) >= current_totalSize )
            return true ;
        else
                return false ;
    }

    public Boolean getDisablePreviousCurrent(){
        if(current_counter == 0)
            return true ;
        else
            return false ;
    }

    public void nextFuture(){
        futureTimesheetsToShow.clear();
        future_counter = future_counter+limitsize;

        futurefirstEntry=futurelastEntry+1;

        futurePageTurn = true;

        approvedPageTurn = false;
        currentPageTurn = false;
        submittedPageTurn = false;

        //FUTURE
        if((future_counter + limitSize) <= future_totalSize){
            for(Integer i=future_counter;i<(future_counter+limitSize);i++){
                futureTimesheetsToShow.add(timesheetFutureList.get(i));
            }
            futurelastEntry=(futurefirstEntry-1)+limitsize;
        } else{
            for(Integer i=future_counter;i<future_totalSize;i++){
                futureTimesheetsToShow.add(timesheetFutureList.get(i));
            }
            futurelastEntry=future_totalSize;
        }
    }

    public void previousFuture(){
        futureTimesheetsToShow.clear();
        future_counter = future_counter-limitsize;

        futurePageTurn = true;

        approvedPageTurn = false;
        currentPageTurn = false;
        submittedPageTurn = false;

        for(Integer i=future_counter;i<(future_counter+limitSize); i++){
            futureTimesheetsToShow.add(timesheetFutureList.get(i));
        }
        futurefirstEntry=future_counter+1;
        futurelastEntry=future_counter+limitsize;
    }

    public Boolean getDisableNextFuture(){
        if((future_counter + limitSize) >= future_totalSize )
            return true ;
        else
            return false ;
    }

    public Boolean getDisablePreviousFuture(){
        if(future_counter == 0)
            return true ;
        else
            return false ;
    }

    public void nextSubmitted(){
        submittedTimesheetsToShow.clear();
        submitted_counter = submitted_counter+limitsize;

        submittedfirstEntry=submittedlastEntry+1;

        submittedPageTurn = true;

        approvedPageTurn = false;
        currentPageTurn = false;
        futurePageTurn = false;

        //SUBMITTED
        if((submitted_counter + limitSize) <= submitted_totalSize){
            for(Integer i=submitted_counter;i<(submitted_counter+limitSize);i++){
                submittedTimesheetsToShow.add(timesheetSubmittedList.get(i));
            }
            submittedlastEntry=(submittedfirstEntry-1)+limitsize;
        } else{
            for(Integer i=submitted_counter;i<submitted_totalSize;i++){
                submittedTimesheetsToShow.add(timesheetSubmittedList.get(i));
            }
            submittedlastEntry=submitted_totalSize;
        }
    }

    public void previousSubmitted(){
        submittedTimesheetsToShow.clear();
        submitted_counter = submitted_counter-limitsize;

        submittedPageTurn = true;

        approvedPageTurn = false;
        currentPageTurn = false;
        futurePageTurn = false;

        for(Integer i=submitted_counter;i<(submitted_counter+limitSize); i++){
            submittedTimesheetsToShow.add(timesheetSubmittedList.get(i));
        }
    }

    public Boolean getDisableNextSubmitted(){
        if((submitted_counter + limitSize) >= submitted_totalSize )
            return true ;
        else
            return false ;
    }

    public Boolean getDisablePreviousSubmitted(){
        if(submitted_counter == 0)
            return true ;
        else
            return false ;
    }
}