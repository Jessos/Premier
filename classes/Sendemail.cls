public with sharing class Sendemail {

  public ts2__Application__c email= new ts2__Application__c ();
  public boolean displayPopup {get;set;}
  public boolean sendemail;
   public string PageMesg{get;set;}
  
    public Sendemail(ApexPages.StandardController controller) {
     email= (ts2__Application__c)controller.getRecord(); 
       //displayPopup = False;
    }
    
     
   /* public void closePopup() {        
        displayPopup = false;    
    } 
        
    public void showPopup() {            
        displayPopup = true;
    }*/
    
    public void SendEmail(){
     try{
         email.Send_Email__c= true; 
                             
         update email;
         
         ts2__Application__c AppRow = [select id,ts2__Internally_Applied__c from ts2__Application__c where id=:email.id];
         
         system.debug('============AppRow.ts2__Internally_Applied__c============='+AppRow.ts2__Internally_Applied__c);
         
         if(AppRow.ts2__Internally_Applied__c == true){
            PageMesg = 'Email has been successfully sent!';
         }else{
            PageMesg = 'This functionality is available only for Internally Applied Applications';
         }
     }
     catch(exception ee){
       system.debug('====ee===='+ee);
     }
    }
    
    
   /* public PageReference POPCancel() {                 
           displayPopup = False;
         //sherr=true;
         pagereference pr = new pagereference('/apex/sendemail');
         pr.setRedirect(true);
         return pr; 
    }*/

}