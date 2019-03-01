public with sharing class CandidateAttachmentcls {
   public  id contactidd ;
    public List<Attachment> AttachmentList{get;set;}
    public List<ts2__Application__c> application{get;set;}
    public  Set<id> SelectedAttachmentSet = new Set<id>();
    public  id IsSelected{get;set;}
    public  boolean isclose{get;set;}
    
    public  List<Contact> ContactList = new List<Contact>();
    public List<Attachment> SelectedAttachmentList = new List<Attachment>();
    
 public CandidateAttachmentcls () {
        isclose = false;
        application = [SELECT Id,Name,ts2__Candidate_Contact__c,Bio__c FROM ts2__Application__c WHERE id =:ApexPages.CurrentPage().getParameters().get('id')];
         system.debug('application .........'+application );
        for(ts2__Application__c app :application){
           contactidd  = app.ts2__Candidate_Contact__c;
          
        }
     AttachmentList= [SELECT Id,Name,ParentId FROM Attachment WHERE ParentId =:contactidd];
     
    }

      public List<SelectOption> getAttachmentRec(){
        List<SelectOption> AttachmentOptions= new List<SelectOption>();
        integer i;
        string value;
         for(i=0;i<AttachmentList.size();i++){
                  system.debug('AttachmentList[i].....'+AttachmentList[i]); 
                        string str = string.valueof(AttachmentList[i].Name);
                        value = string.valueof(AttachmentList[i].id);                           
                        AttachmentOptions.add(new SelectOption(value,str));
        }
      return AttachmentOptions;     
    }
    
    public void Save(){
    system.debug('IsSelected...........'+IsSelected);
      for(Attachment att : [SELECT Id,Name,Body,ParentId FROM Attachment WHERE id =: IsSelected]){
      
      //Modified by Ajay Kumar Khatri
          Attachment newatt = new Attachment(name=att.name,Body=att.Body,ParentId= ApexPages.CurrentPage().getParameters().get('id')  );
         
         
         // Commented by Ajay kumar khatri
          /*  newatt.name = att.name ; 
            newatt.Body = att.Body;
            newatt.ParentId = ApexPages.CurrentPage().getParameters().get('id') ;  */
            SelectedAttachmentList.add(newatt);
      }
    /*  for(Contact ctct : [SELECT Id,Name,Bio__c FROM Contact WHERE id =:contactidd]){
         Attachment att = new Attachment();
            att.name = 'Bio'; 
            att.Body = Blob.valueof(ctct.Bio__c);
            att.ParentId = ApexPages.CurrentPage().getParameters().get('id') ; 
            SelectedAttachmentList.add(att);
      }*/
      //insert SelectedAttachmentList;
      //
         try {
           insert SelectedAttachmentList;
           isclose = true;
          } catch (Exception e) {
          // insert code to handle exceptions here
           } finally {
             // free up the variable size in the view state
             SelectedAttachmentList = new List<Attachment>();
           }
        //
       
    }
}