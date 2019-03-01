//-------------------------------------------------------------------------
//Trigger to hold all the trigger logic for Contact triggers
//1. when candidate is created from JobProtal set status to NEW
//-------------------------------------------------------------------------
trigger bat_AllContactTriggers on Contact (before insert, before update) {
    List<Contact> contactsForChange = new List<Contact>();
    
    if(trigger.isInsert && trigger.isBefore)
    {
        //condition for setting the new candidate status to new 
        User careerSiteUser = [select id from user where CommunityNickname = 'Careers' limit 1];
        for(Contact candidate : trigger.new)
        {
            system.debug(candidate.ts2__People_Status__c);
            system.debug(candidate.CreatedBy);
            system.debug(UserInfo.getUserId());
            if(UserInfo.getUserId() == careerSiteUser.id)
            {
                candidate.ts2__People_Status__c = 'New Lead';
            }
        } 
        
    }
    if(Trigger.isBefore && Trigger.isUpdate){
        for(Contact contact : Trigger.New){
            if(!contact.Ready_For_Paycom__c &&  //if not ready for paycom already, check for values in the below fields
               contact.lastName != null && contact.ts2__Social_Security__c != null &&
               contact.Birthdate != null && contact.First_Day_Worked__c != null &&
               contact.MailingStreet != null && contact.MailingCity != null &&
               contact.MailingPostalCode != null && contact.Fed_Filing_Status__c != null &&
               contact.FedTaxExemptions__c != null && contact.StateTaxFiling1__c != null &&
               contact.email != null)
               contact.Ready_For_Paycom__c = true; 
        }
    }
}