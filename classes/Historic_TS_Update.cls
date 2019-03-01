global class Historic_TS_Update implements Database.Batchable<tc9_ti__Time_Sheet__c>{
    
    global Date startDate{get;set;}
    global Date endDate{get;set;}
    
    
    public Historic_TS_Update(Date st, Date endd){
        this.startDate = st;
        this.endDate = endd;
    }
    
    global List<tc9_ti__Time_Sheet__c> start(Database.BatchableContext bc){
        system.debug('**' + this.startDate + ' - ' + this.endDate);
        String query = 'SELECT id From tc9_Ti__time_Sheet__c where tc9_ti__Start_Date__c >=: startDate and tc9_ti__Start_Date__c <=: endDate and tc9_ti__WeeklyActualHours__c != 0';
        return Database.Query(query);
    }
    
    global void execute(Database.BatchableContext bc, List<tc9_Ti__time_Sheet__c> tss){
        system.debug('***' + tss);
        List<tc9_ti__Time_sheet__c> tss1 = [SELECT id,(select id from tc9_ti__Time_Sheet_Entries__r limit 1) From tc9_Ti__time_Sheet__c where id in:tss];
        List<tc9_ti__Time_Sheet_Entry__c> entries = new List<tc9_ti__Time_Sheet_Entry__c>();
        for(tc9_ti__Time_sheet__c ts : tss1){
            if(ts.tc9_ti__Time_Sheet_Entries__r != null && ts.tc9_ti__Time_Sheet_Entries__r.size() >0)
               entries.add(new tc9_ti__Time_Sheet_Entry__c(id=ts.tc9_ti__Time_Sheet_Entries__r.get(0).Id));
        }
        
        update entries;
    }
    
    global void finish(Database.BatchableContext bc){
        
    }
}