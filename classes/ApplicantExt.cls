public with sharing class ApplicantExt {
private final List<ts2__Application__c> applist {get;set;}
public list<SelectedApplicant__c> jobapplicantlist = new list<SelectedApplicant__c>();
public list<ts2__Submittal__c> SubMittalList = new  list<ts2__Submittal__c>();
//public string vartest;
public set<string> AppSet = new set<string>();
public set<string> SubMittalSet = new set<string>();
public string Jobtitle{get;set;}

 public ApplicantExt (){
 jobapplicantlist = [select id,name,Applicants__c from SelectedApplicant__c where name = 'JobOrder'];
   for(SelectedApplicant__c slt : jobapplicantlist){

      if(slt.Applicants__c <> null){
                 for(string s: slt.Applicants__c.Split('~')){
                        s= s.deleteWhitespace();
                        if(s <> null && s <> ''){
                            SubMittalSet.add(s);
                        }
                  }
            }
         }
     SubMittalList  = [Select id,name,ts2__Job__c,ts2__Job__r.name,ts2__Related_Application__c from ts2__Submittal__c where id In: SubMittalSet];
          for(ts2__Submittal__c sub : SubMittalList){
                 if(sub.ts2__Related_Application__c <> null || sub.ts2__Related_Application__c <> ''){
                   AppSet.add(sub.ts2__Related_Application__c); 
                 }
                   Jobtitle = sub.ts2__Job__r.name;
          }
    applist  = [select ts2__Candidate_Contact__r.name,name,id,ts2__Job__c,Bio__c from ts2__Application__c where id IN:AppSet];
          system.debug('applist  ...........'+applist  );
  }
  
 public list<ts2__Application__c> getApplicantBios(){
  system.debug('applist.......'+applist);
   return applist;
  }

}