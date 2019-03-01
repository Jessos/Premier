public with sharing class Ctrl_ClientProjectCode {
    
    public tc9_ti__Time_Sheet__c oTimesheet ;   
    public List<tc9_ti__Project_Code__c> listOfProjectCodes {get;set;}
    public String strTimesheetId{get;set;}
    public String searchString{get;set;}
    public boolean toCreate{get;set;}
    public boolean isRecent{get;set;}
    public boolean isActive{get;set;}
    public Integer rowNumber{get;set;}
    public tc9_ti__Project_Code__c oProject{get;set;}
    
    public integer totalRecs{get;set;}     
    public integer index{get;set;}        
    public integer sumEvents{get;set;}  
    Integer blockSize = 10;
    
    Id ClientId ;
    Id jobId;
    Set<Id> jobProjectIds;
    List<tc9_ti__Project_Code__c> allProjectCodes;
    List<tc9_ti__Job_Project_Code__c> jobCodestobeInserted;
    List<tc9_ti__Project_Code__c> proCodestobeInserted;
    Pagereference page;
    
    //sc-2721
    public Boolean successAlert{get;set;}
    
    public Ctrl_ClientProjectCode(){
        index = 0;
        totalRecs = 0;
        isRecent = true;
        //sc-2721
        successAlert = false;
        ////////
        jobProjectIds = new Set<Id>();
        oProject = new tc9_ti__Project_Code__c();
        allProjectCodes = new List<tc9_ti__Project_Code__c>();
        listOfProjectCodes = new List<tc9_ti__Project_Code__c>();
        jobCodestobeInserted = new List<tc9_ti__Job_Project_Code__c>();
        proCodestobeInserted = new List<tc9_ti__Project_Code__c>();         
        
        if(ApexPages.currentPage().getParameters().get('tsId') != NULL){
            
            //get the parameter which determines the timesheet
            strTimesheetId = ApexPages.currentPage().getParameters().get('tsId');
            
            oTimesheet = [Select t.tc9_ti__Status__c, t.tc9_ti__Placement__r.ts2__Job__r.Name, t.tc9_ti__Placement__r.ts2__Job__r.tc9_ti__Client_Name__c,t.tc9_ti__Placement__r.ts2__Job__r.ts2__Account__c, t.tc9_ti__Placement__r.ts2__Job__c, t.tc9_ti__Placement__c, Id
                          From tc9_ti__Time_Sheet__c t
                          Where Id =: strTimesheetId LIMIT 1];
            
            system.debug('*** ' + oTimesheet);
                                            
            if(oTimesheet.tc9_ti__Status__c != 'New' && oTimesheet.tc9_ti__Status__c != 'Rejected' && ApexPages.currentPage().getParameters().get('list') == null){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Cannot_edit_an_approved_Timesheet));
            }
            
            ClientId = oTimesheet.tc9_ti__Placement__r.ts2__Job__r.ts2__Account__c;
            jobId = oTimesheet.tc9_ti__Placement__r.ts2__Job__c;
            
            System.debug('***'+oTimesheet.tc9_ti__Placement__r.ts2__Job__r.ts2__Account__c);
            
            for(tc9_ti__Job_Project_Code__c projCode : [SELECT id, tc9_ti__Project_Code__c, tc9_ti__Project_Code__r.Name , tc9_ti__Job_Order__c
                                                FROM tc9_ti__Job_Project_Code__c 
                                                WHERE tc9_ti__Job_Order__c =: jobId]){
                jobProjectIds.add(projCode.tc9_ti__Project_Code__c);                                        
            }
            
            //All Projects codes against client which have not yet been assigned to Job and are craeted in last 30 days
            allProjectCodes = [Select p.tc9_ti__Status__c, p.Name, p.Id, p.tc9_ti__Client__c
                                  From tc9_ti__Project_Code__c p 
                                  Where tc9_ti__Client__c =: ClientId And CreatedDate = LAST_N_DAYS:30 And Id not in: jobProjectIds];
             initialDisplay(0);                   
        }
        else{
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Associate_a_Timesheet_in_the_page));
        } 
    }
    
    //Method to search project codes based on search string
    public void searchProjectCodes(){
        searchString = '%'+searchString+'%';
        System.debug('!@#$%^&'+searchString);
        allProjectCodes.clear();
        allProjectCodes = [Select p.tc9_ti__Status__c, p.Name, p.Id, p.tc9_ti__Client__c
                              From tc9_ti__Project_Code__c p 
                              Where tc9_ti__Client__c =: ClientId And Name like :searchString and Id NOT in: jobProjectIds];
        initialDisplay(0);
        isRecent = false;
        searchString='';
    }
    
    //Method to display the new project creation section
    public void displaySection(){
        toCreate = true;        
        system.debug('****'+toCreate);
    }
    
    //Method to assign a existing project code to Job by creating a new Job Project Code
    public PageReference addProjectCode(){
        System.debug('****'+rowNumber);
        
        jobCodestobeInserted.clear();
        jobCodestobeInserted.add((new tc9_ti__Job_Project_Code__c(tc9_ti__Job_Order__c = jobId, tc9_ti__Project_Code__c = listOfProjectCodes.get(rowNumber).Id)));
        insert jobCodestobeInserted;
        
        Integer toRemove = 0;
        for(tc9_ti__Project_Code__c oProject:allProjectCodes){
            if(oProject.Id == listOfProjectCodes.get(rowNumber).Id){
                break;
            }
            else
                toRemove++;
        }
        allProjectCodes.remove(toRemove);
        initialDisplay(index);
        ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO, Label.Project_Code_added_to_Job));
        return null;
    }
    
    //Method to create a new project code 
    public PageReference saveProjectCode(){
        //sc-2721
        String newName = oProject.Name;
        successAlert = true;
        /////////
        List<tc9_ti__Project_Code__c> allAvailableCode = [Select Id,Name From tc9_ti__Project_Code__c where tc9_ti__Client__c =: ClientId];
        
        for(tc9_ti__Project_Code__c iProject: allAvailableCode){
            if((iProject.Name).equalsIgnoreCase(oProject.Name)){
                ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, Label.Project_Code_Created));
                return null;                
            }
        }
        //sc-2721
        oProject = new tc9_ti__Project_Code__c();
        oProject.Name = newName;
        ////////
        oProject.tc9_ti__Client__c = ClientId;
        oProject.tc9_ti__Status__c = 'Active';
        try {
            insert oProject;
            jobCodestobeInserted.clear();
            jobCodestobeInserted.add((new tc9_ti__Job_Project_Code__c(tc9_ti__Job_Order__c = jobId, tc9_ti__Project_Code__c = oProject.Id)));
            insert jobCodestobeInserted;
            
            //sc-2721
            for(tc9_ti__Job_Project_Code__c thisJobCde: jobCodestobeInserted)
                jobProjectIds.add(thisJobCde.tc9_ti__Project_Code__c);
            ///////
        }
        catch(Exception e) {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR, e.getMessage()));
        }
        return null;
    }
    
    //To go back to FillTimesheet page
    public PageReference cancelExtension(){
        page = new Pagereference('/apex/Filltimesheet');
        page.setRedirect(true);           
        return page;
    }
    
    public void beginning(){
        index = 0;
        sumEvents = index + blockSize; 
        populateList(index,sumEvents);   
    }
    
    //For Pagination
    public void previous(){
        if(index>=blockSize)
            index = index - blockSize;
        sumEvents = index + blockSize; 
        populateList(index,sumEvents);       
    }
    
    public void next(){
        if((index+blockSize) < totalRecs)
            index = index + blockSize;
        if(index+blockSize < totalRecs)
            sumEvents = index + blockSize;
        else
            sumEvents = totalRecs;  
            
        populateList(index,sumEvents);        
    }

    public void end(){
        if(math.mod(totalRecs,blockSize) != 0)
            index = totalrecs - math.mod(totalRecs,blockSize);
        else
            index = totalrecs - blockSize;
        if(index+blockSize < totalRecs)
            sumEvents = index + blockSize;
        else
            sumEvents = totalRecs; 
            
        populateList(index,sumEvents);         
    }        
    
    public boolean getprev(){
        if(index == 0)
            return true;
        else
            return false;
    }  
    
    public boolean getnxt(){
        if((index + blockSize) > totalRecs)
            return true;
        else
            return false;
    }
    
    
    //Submethods to populate displaylist
    public void populateList(Integer iIndex,Integer iSumEvents){
        listOfProjectCodes.clear();
        for(integer i = iIndex; i<iSumEvents; i++){
            listOfProjectCodes.add(allProjectCodes.get(i));
        }       
    }
    public void initialDisplay(Integer iIndex){     
        totalRecs = allProjectCodes.size();
        if(iIndex+blockSize < totalRecs)
            sumEvents = iIndex + blockSize;
        else
            sumEvents = totalRecs;
        populateList(iIndex,sumEvents);
    }
    
    //TO check if a project code can be assigned to job. If status is ACTIVE, then the project code can be assigned
    public void checkStatus(){
        if(listOfProjectCodes.get(rowNumber).tc9_ti__Status__c == 'Active')
            isActive = true;
        else
            isActive = false;
    }
    
    //To back to the main page.
    public PageReference backToHome() {
        page = new Pagereference('/apex/LandingPage');
        page.setRedirect(true); 
        return page;
    }
    

    public void aDummyCall() {
        
    }
}