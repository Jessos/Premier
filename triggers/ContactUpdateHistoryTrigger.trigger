trigger ContactUpdateHistoryTrigger on Contact (before update) {

   // Get picklist values
   map<String, Schema.SObjectField> fieldMap = Contact_Update_Record__c.getSObjectType().getDescribe().fields.getMap();
   list<Schema.PicklistEntry> values = fieldMap.get('Field_Changed__c').getDescribe().getPickListValues();
   map<String, Schema.SObjectField> contactFieldMap = Contact.getSObjectType().getDescribe().fields.getMap();
   Map<Id,Contact> newContactMap = Trigger.newMap;
   Map<Id,Contact> oldContactMap = Trigger.oldMap;
   List<Contact_Update_Record__c> UpdateHis = New List<Contact_Update_Record__c> ();
   
   for(Id contactId:newContactMap.keySet()){
      Contact myNewContact = newContactMap.get(contactId);
      Contact myOldContact = oldContactMap.get(contactId);
      if(myOldContact.EMP_NUM__c!=null){// check condition to track update
         for (Schema.PicklistEntry item : values){ 
            if(String.valueOf(myNewContact.get(item.getValue())) != String.valueOf(myOldContact.get(item.getValue()))){
               Contact_Update_Record__c udhis = new Contact_Update_Record__c();
               udhis.Contact__c = myNewContact.id;
               udhis.Modify_Date__c = System.now();
               udhis.Field_Changed__c = contactFieldMap.get(item.getValue()).getDescribe().getLabel();
               udhis.New_Value__c = String.valueOf(myNewContact.get(item.getValue()));
               udhis.Old_Value__c = String.valueOf(myOldContact.get(item.getValue()));
               UpdateHis.Add(udhis);
            } 
         }  
      }
   }
   insert UpdateHis;
}