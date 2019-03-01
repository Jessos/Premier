/**
 * Created by Adelaide Greenaway on 30/10/17.
 *
 * Copyright © 2017 2cloudnine Pty Ltd - Strictly Confidential.
 * Not to be distributed without authorisation
 *
 * Controller to support the 2c9 Custom Portal Home Page
 *
 * The Home Page is accessible to the user if:
 *  - A Contact record exists AND;
 *      - 2c9 Portal Community User has been created and accessible to the Portal as per the Portal_Base_Controller
 *      - A Primary Payee record exists for this Contact
 * Updated by Jesse Windebank to remove; general announcement, bank, super and tax references
 * Test Class:
 */

global class Portal_Home_Controller extends Portal_AgreementBase_Controller {

    public List<tc9_ti__Time_Sheet__c> timesheetLateList {get;set;}

    public Boolean tsOutstanding {get;set;}
    public Boolean detailsIncomplete {get;set;}
    public Boolean personalIncomplete {get;set;}
    public Boolean empnumnull {get;set;}
    public String empnummsg {get;set;}

    public Decimal notificationCount {get;set;}

    public Portal_Home_Controller(){

        tsOutstanding = false;
        detailsIncomplete = false;
      
        personalIncomplete = false;

        empnumnull = false;
        empnummsg = null;

        notificationCount = 0;

        if(contractor.Id != null){
            //get the notification count for Contact details      

            if(contractor.Personal_Details_Provided__c == false){
                notificationCount = notificationCount+1;
                //detailsIncomplete = true;
                personalIncomplete = true;
            }

            if(contractor.EMP_NUM__c == null){
                notificationCount = notificationCount+1;
                empnumnull = true;
                empnummsg ='Please complete your Paylocity Onboarding. We cannot process a paycheck for you unless your Paylocity onboarding is complete.';
                }
                else
                {
                empnumnull = false;    
                }
            
        }

        //let's find out if this payee has any overdue timesheets
        timesheetLateList = new List<tc9_ti__Time_Sheet__c>([SELECT Id, Name, tc9_ti__Placement__c, tc9_ti__Candidate__c,
                tc9_ti__Placement__r.Payee__c, tc9_ti__Status__c, tc9_ti__End_Date__c, tc9_ti__Start_Date__c,
                tc9_ti__Placement__r.Name, tc9_ti__Placement__r.Account_Name__c, tc9_ti__Placement__r.ts2__Job__r.Name,
                tc9_ti__WeeklyActualHours__c
                FROM tc9_ti__Time_Sheet__c
                WHERE tc9_ti__Candidate__r.Id =: contractor.Id
                AND tc9_ti__Status__c != 'Submitted'
                AND tc9_ti__Status__c != 'Approved'
                AND tc9_ti__End_Date__c < TODAY
                ORDER BY tc9_ti__Start_Date__c DESC ]);
        if(timesheetLateList.size() > 0){
            tsOutstanding = true;
            notificationCount = notificationCount+1;
        }else {
            tsOutstanding = false;
        }
        system.debug('timesheetLateList: '+timesheetLateList);

    }

    public pageReference paylocityportal() {
        PageReference pageRef = new PageReference('https://access.paylocity.com/');
        pageRef.setRedirect(true);
        return pageRef;
    }

    public pageReference paylocityonboarding() {
        PageReference pageRef = new PageReference('https://onboarding.paylocity.com/onboarding/');
        pageRef.setRedirect(true);
        return pageRef;
    }

    //remote action to upload documentation and create Attachments
    @RemoteAction
    global static String doUploadAttachment(String parentId, String attachmentBody, String attachmentName, String attachmentId, String attachmentDesc) {
        system.debug('got here!!');
        return Portal_JSRemoting_FileUpload_Ctlr.doUploadAttachment(parentId, attachmentBody, attachmentName, attachmentId, attachmentDesc);
    }

}