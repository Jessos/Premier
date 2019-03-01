/**
 * Created by Adelaide Greenaway on 19/12/17.
 *
 * Copyright © 2017 2cloudnine Pty Ltd - Strictly Confidential.
 * Not to be distributed without authorisation
 *
 * Controller to support the 2c9 Portal Placement History Page
 *
 * The Placement History Page is accessible to the user if:
 *  - At least one Placement exists that has timesheets generated;
 * Cloned by Jesse Windebank based off the existing Portal_PaymentHistory_Controller
 * Test Class:
 */

public class Portal_PlacementHistory_Controller extends Portal_Base_Controller{
    public List<ts2__Placement__c> listPlacements {get;set;}
    public List<PlacementHistoryWrapper> placementHistoryList{get;set;}  
    public Boolean placementHistoryExists {get;set;}
    public Boolean placementHistoryInactiveExists{get;set;}
    public Boolean pageTurn {get;set;} 
    public List<PlacementHistoryWrapper> placementHistoryToShow {get;set;}
    public integer counter = 0;
    public integer limitsize;
    public integer totalSize = 0;
    public integer totalEntry {get;set;}
    public integer firstEntry {get;set;}
    public integer lastEntry {get;set;}
    //Inactive List Components
    public integer totalInactiveentry {get;set;}
    public integer firstInactiveEntry {get;set;}
    public integer lastInactiveEntry {get;set;}
    public integer inactivecounter = 0;
    public integer totalInactiveSize = 0;
    public Boolean pageTurnInactive {get;set;}
    public List<PlacementHistoryWrapper> placementHistoryInactiveList{get;set;}
    public List<PlacementHistoryWrapper> placementInactiveHistoryToShow {get;set;}

    public Portal_PlacementHistory_Controller() {

        listPlacements = new List<ts2__Placement__c>();
        placementHistoryList = new List<Portal_PlacementHistory_Controller.PlacementHistoryWrapper>();
        placementHistoryInactiveList = new List<Portal_PlacementHistory_Controller.PlacementHistoryWrapper>();

        placementHistoryExists = false;
        placementHistoryInactiveExists= false;
        pageTurn = true;
        pageTurnInactive =true;
        for(ts2__Placement__c placements : [SELECT Id,Name, ts2__Job__r.Name, ts2__Client__r.Name, ts2__Start_Date__c, ts2__End_Date__c, ts2__Filled_By_2__r.Name, tc9_ti__Base_Pay_Rate__c, ts2__Status__c, Reason_Ended__c 
            FROM ts2__Placement__c
            WHERE ts2__Employee__c=:contractor.Id AND ts2__Status__c in ('Inactive','Active') AND Reason_Ended__c != 'Candidate Never Started'
            ORDER BY ts2__Start_Date__c DESC]){

            PlacementHistoryWrapper PlacementHistory =  new PlacementHistoryWrapper();
            PlacementHistoryWrapper PlacementHistoryInactive =  new PlacementHistoryWrapper();
            if(placements.ts2__Status__c=='Active'){
                PlacementHistory.tempPlacements = placements;
                PlacementHistory.startDate = placements.ts2__Start_Date__c;
                PlacementHistory.endDate = placements.ts2__End_Date__c;
                PlacementHistory.jobName = placements.ts2__Job__r.Name;
                PlacementHistory.clientName = placements.ts2__Client__r.Name;
                PlacementHistory.candidateManager = placements.ts2__Filled_By_2__r.Name;
                PlacementHistory.payRate = placements.tc9_ti__Base_Pay_Rate__c;
                PlacementHistory.status= placements.ts2__Status__c;
                PlacementHistory.name= placements.Name;

                placementHistoryList.add(PlacementHistory);
                listPlacements.add(placements);
            }
            else if(placements.ts2__Status__c=='Inactive'){
                PlacementHistory.tempPlacements = placements;
                PlacementHistory.startDate = placements.ts2__Start_Date__c;
                PlacementHistory.endDate = placements.ts2__End_Date__c;
                PlacementHistory.jobName = placements.ts2__Job__r.Name;
                PlacementHistory.clientName = placements.ts2__Client__r.Name;
                PlacementHistory.candidateManager = placements.ts2__Filled_By_2__r.Name;
                PlacementHistory.payRate = placements.tc9_ti__Base_Pay_Rate__c;
                PlacementHistory.status= placements.ts2__Status__c;
                PlacementHistory.name= placements.Name;
                
                placementHistoryInactiveList.add(PlacementHistory);
            }
        }

        if(placementHistoryList.size()>0){
            placementHistoryExists = true;
        }
         if(placementHistoryInactiveList.size()>0){
            placementHistoryInactiveExists = true;
        }
        system.debug('placementHistoryList: '+placementHistoryList);

        placementHistoryToShow = new List<PlacementHistoryWrapper>();
        placementInactiveHistoryToShow = new List<PlacementHistoryWrapper>();
        totalSize = placementHistoryList.size();
        totalInactiveSize=placementHistoryInactiveList.size();
        totalEntry = totalSize;
        totalInactiveentry= totalInactiveSize;
        firstEntry = 1;
        firstInactiveEntry = 1;
        limitsize = 10;

        if((counter+limitsize) <= totalSize){
            for(Integer i=0; i<limitsize; i++){
                placementHistoryToShow.add(placementHistoryList.get(i));
            }
            lastEntry = 10;
        }else{
            for(Integer i=0; i<totalSize; i++){
                placementHistoryToShow.add(placementHistoryList.get(i));
            }
            lastEntry = totalSize;
        }
         //Inactive List
        if((inactivecounter+limitsize) <= totalInactiveSize){
            for(Integer i=0; i<limitsize; i++){
                placementInactiveHistoryToShow.add(placementHistoryInactiveList.get(i));
            }
            lastInactiveEntry = 10;
        }else{
            for(Integer i=0; i<totalInactiveSize; i++){
                placementInactiveHistoryToShow.add(placementHistoryInactiveList.get(i));
            }
            lastInactiveEntry = totalInactiveSize;
        }
    }

    public class PlacementHistoryWrapper{
        public ts2__Placement__c tempPlacements {get; set;}
        public Date startDate {get;set;}
        public Date endDate {get;set;}
        public String jobName {get;set;}
        public String clientName {get;set;}
        public String candidateManager {get;set;}
        public Decimal payRate {get;set;}
        public String status{get;set;}
        public String name{get;set;}
    }

    public void next(){

        placementHistoryToShow.clear();
        counter = counter+limitsize;
        pageTurn = true;
        firstEntry = lastEntry+1;
        
        if((counter + limitSize) <= totalSize) {
            for (Integer i = counter; i<(counter+limitSize); i++) {
                placementHistoryToShow.add(placementHistoryList.get(i));
            }
            lastEntry = (firstEntry-1) + limitSize;
        } else{
            for(Integer i=counter;i<totalSize;i++){
                placementHistoryToShow.add(placementHistoryList.get(i));
            }
            lastEntry = totalSize;
        }
         
    }
    //Inactive List
    public void nextInactive(){
        
        placementInactiveHistoryToShow.clear();
        inactivecounter=inactivecounter+limitsize;
        pageTurnInactive = true;
        firstInactiveEntry=lastInactiveEntry+1;
        
        if((inactivecounter + limitSize) <= totalInactiveSize) {
            for (Integer i = inactivecounter; i<(inactivecounter+limitSize); i++) {
                placementInactiveHistoryToShow.add(placementHistoryInactiveList.get(i));
            }
            lastInactiveEntry = (firstInactiveEntry-1) + limitSize;
        } else{
            for(Integer i=inactivecounter;i<totalInactiveSize;i++){
                placementInactiveHistoryToShow.add(placementHistoryInactiveList.get(i));
            }
            lastInactiveEntry = totalInactiveSize;
        }
    }
    public void previous(){
        placementHistoryToShow.clear();
        counter = counter-limitsize;
        pageTurn = true;

        for(Integer i=counter;i<(counter+limitSize); i++){
            placementHistoryToShow.add(placementHistoryList.get(i));
        }
        firstEntry = counter+1;
        lastEntry = counter+limitSize;
    }
      //Inactive List
    public void previousInactive(){
        placementInactiveHistoryToShow.clear();
        inactivecounter=inactivecounter-limitsize;
         pageTurnInactive = true;
         
        for(Integer i=inactivecounter;i<(inactivecounter+limitSize); i++){
            placementInactiveHistoryToShow.add(placementHistoryInactiveList.get(i));
        }
        firstInactiveEntry = inactivecounter+1;
        lastInactiveEntry = inactivecounter+limitSize;

    }
    public Boolean getDisableNext(){
        if((counter + limitSize) >= totalSize )
            return true ;
        else
            return false ;
    }
    //Inactive List
    public Boolean getDisableNextInactive(){
        if((inactivecounter + limitSize) >= totalInactiveSize )
            return true ;
        else
            return false ;
    }
    public Boolean getDisablePrevious(){
        if(counter == 0)
            return true ;
        else
            return false ;
    }
    //Inactive List
    public boolean getdisablepreviousinactive(){
        if(inactivecounter == 0)
            return true ;
        else
            return false ;
    }
}