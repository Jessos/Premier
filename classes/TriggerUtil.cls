public class TriggerUtil {   
   // BEGIN - Auto Calculate markup
   public static void updateMarkup(ts2__Job__c job)
   {      
      if(job.ts2__Markup_Pct__c==null || job.ts2__Markup_Pct__c==0)
      {
         decimal minMarkup = calcMarkup(job.ts2__Min_Pay_Rate__c, job.ts2__Min_Bill_Rate__c);
         decimal maxMarkup = calcMarkup(job.ts2__Max_Pay_Rate__c, job.ts2__Max_Bill_Rate__c);
         // Truncate the result at the hundredth place

         while(minMarkup > 100)
         {
            minMarkup = minMarkup / 10;
         }

         while(maxMarkup > 100)
         {
            maxMarkup = maxMarkup / 10;
         }

         // Set value for Markup
         if(minMarkup==null && maxMarkup==null)
         {
            return;
         }
         else if(maxMarkup!=null && minMarkup==null)
         {
            job.ts2__Markup_Pct__c = maxMarkup;

            // Max is ok, need to calculate Min
            calcRate(job, false);
         }
         else if(maxMarkup==null && minMarkup!=null)
         {
           job.ts2__Markup_Pct__c = minMarkup;

           // Min is ok, need to calculate Max
           calcRate(job, true);
         }
         else
         {
           job.ts2__Markup_Pct__c = maxMarkup;
         }
      }
      else
      {
         calcRate(job, true);
         calcRate(job, false);
      }
   }
   
   public static void calcRate(ts2__Job__c job, boolean isMax)
   {
      if(isMax)
      {
        if(job.ts2__Max_Pay_Rate__c==null && job.ts2__Max_Bill_Rate__c!=null)
        {
          job.ts2__Max_Pay_Rate__c = job.ts2__Max_Bill_Rate__c /(1 + job.ts2__Markup_Pct__c/100);
        }else if(job.ts2__Max_Pay_Rate__c!=null && job.ts2__Max_Bill_Rate__c==null)
        {
          job.ts2__Max_Bill_Rate__c = job.ts2__Max_Pay_Rate__c*(1 + job.ts2__Markup_Pct__c/100);
        }
      }
      else
      {
        if(job.ts2__Min_Pay_Rate__c==null && job.ts2__Min_Bill_Rate__c!=null)
        {
          job.ts2__Min_Pay_Rate__c = job.ts2__Min_Bill_Rate__c /(1 + job.ts2__Markup_Pct__c/100);
        }
        else if(job.ts2__Min_Pay_Rate__c!=null && job.ts2__Min_Bill_Rate__c==null)
        {
          job.ts2__Min_Bill_Rate__c = job.ts2__Min_Pay_Rate__c*(1 + job.ts2__Markup_Pct__c/100);
        }
      }
   }
   
   public static decimal calcMarkup(decimal payRate, decimal billRate)
   {
      decimal markup = null;
      if( (payRate==null || payRate==0) || ( billRate==null || billRate==0) )
      {
         return null;
      }
      else
      {
         markup = (billRate/payRate - 1)*100;
      }
      return markup;
   } // END - Auto Calculate markup
      
   // BEGIN - Send Application Email to Primary Recruiter & Candidate Manager   
    //Case: 939 round-robin 
    public static void AssignManagerToCandidate(List<ts2__Application__c> appList)
    {
      try{ 
        Map<id,Contact> contactmap = new Map<id,contact>();
        Set<Id> appIds = new Map<Id, ts2__Application__c>(appList).keySet(); 
        List<ts2__Application__c> appL = [Select Id, 
                                          ts2__Job__r.ts2__Department__c, 
                                          ts2__Candidate_Contact__r.Id, 
                                          ts2__Candidate_Contact__r.Admin_Manager__c,
                                          ts2__Candidate_Contact__r.Sales_Manager__c, 
                                          ts2__Candidate_Contact__r.Technology_Manager__c,
                                          ts2__Candidate_Contact__r.Temp_Manager__c,
                                          ts2__Candidate_Contact__r.EastBay_Manager__c,
                                          ts2__Candidate_Contact__r.East_Bay_Administrative_Manager__c,
                                          ts2__Candidate_Contact__r.East_Bay_Sales_Manager__c,
                                          ts2__SecondaryRecruiter__c // Case# 00001787 
                                          from ts2__Application__c 
                                          where Id IN :appIds];

        
         List<String> departmentList = new List<String>();
        for(ts2__Application__c tmp : appL){
            departmentList.add(tmp.ts2__Job__r.ts2__Department__c);
        }        

        List<User> userList = GetUserList(departmentList);         
        list<Contact> candidateList = new List<Contact>();
        List<User> updateList = new List<User>();
        Integer userAt = -1;

        string currentDepartment ='';
        for(ts2__Application__c app: appL)
        {
            currentDepartment = app.ts2__Job__r.ts2__Department__c;
            Contact candidate = app.ts2__Candidate_Contact__r;

            if((currentDepartment == 'East Bay Administrative' && candidate.East_Bay_Administrative_Manager__c == null)
                || (currentDepartment == 'East Bay Contract/Temp' &&  candidate.EastBay_Manager__c == null)
                || (currentDepartment == 'East Bay Sales' && candidate.East_Bay_Sales_Manager__c == null )
                || (currentDepartment == 'San Francisco Administrative' && candidate.Admin_Manager__c  == null)
                || (currentDepartment == 'San Francisco Contract/Temp' && candidate.Temp_Manager__c  == null)
                || (currentDepartment == 'San Francisco Sales' && candidate.Sales_Manager__c  == null)
                || (currentDepartment == 'Technology' && candidate.Technology_Manager__c  == null)
                || (currentDepartment == 'Finance' && candidate.EastBay_Manager__c  == null)
                )
            {   
                if(userList == null || userList.size() == 0)
                {
                  if(updateList!= null && updateList.size()> 0)
                  {
                    update updateList;
                    updateList = new List<User>();
                  }

                  userList = GetUserList(departmentList);
                }
                
                for(Integer i = 0;i<userList.size(); i++)
                {
                  if(userList[i].Department == currentDepartment)
                  {
                    updateList.add(userList[i]);
                    userList.remove(i);
                    break;
                  }
                }

                userAt = updateList.size() - 1;
                if(userAt >= 0)
                {
                  if(currentDepartment == 'East Bay Administrative')
                  {               
                    if(contactmap.containskey(candidate.id)){
                        contact cnt = contactmap.get(candidate.id);
                        cnt.East_Bay_Administrative_Manager__c = updateList[userAt].id;
                        contactmap.put(candidate.id,cnt);
                    }
                    else{
                      candidate.East_Bay_Administrative_Manager__c = updateList[userAt].id;  
                    }  
                  }
                  else if(currentDepartment == 'East Bay Contract/Temp')
                  {      
                    if(contactmap.containskey(candidate.id)){
                      contact cnt = contactmap.get(candidate.id);
                      cnt.EastBay_Manager__c = updateList[userAt].id;
                      contactmap.put(candidate.id,cnt);
                    }
                    else{
                      candidate.EastBay_Manager__c = updateList[userAt].id;  
                    }  
                  }
                  else if(currentDepartment == 'East Bay Sales')
                  {      
                   if(contactmap.containskey(candidate.id)){
                      contact cnt = contactmap.get(candidate.id);
                      cnt.East_Bay_Sales_Manager__c = updateList[userAt].id;
                      contactmap.put(candidate.id,cnt);
                    }
                    else{
                      candidate.East_Bay_Sales_Manager__c = updateList[userAt].id;  
                    }  
                  }
                  else if(currentDepartment == 'San Francisco Administrative')
                  {
                    if(contactmap.containskey(candidate.id)){
                      contact cnt = contactmap.get(candidate.id);
                      cnt.Admin_Manager__c = updateList[userAt].id;
                      contactmap.put(candidate.id,cnt);
                    }
                    else{
                      candidate.Admin_Manager__c = updateList[userAt].id;  
                    } 
                  }
                  else if(currentDepartment == 'San Francisco Contract/Temp')
                  {
                   if(contactmap.containskey(candidate.id)){
                      contact cnt = contactmap.get(candidate.id);
                      cnt.Temp_Manager__c = updateList[userAt].id;
                      contactmap.put(candidate.id,cnt);
                    }
                    else{
                      candidate.Temp_Manager__c = updateList[userAt].id;  
                    } 
                  }                  
                  else if(currentDepartment == 'San Francisco Sales')
                  {
                    if(contactmap.containskey(candidate.id)){
                        contact cnt = contactmap.get(candidate.id);
                        cnt.Sales_Manager__c = updateList[userAt].id;
                        contactmap.put(candidate.id,cnt);
                    }
                    else{
                      candidate.Sales_Manager__c = updateList[userAt].id;  
                    } 
                  }
                   else if(currentDepartment == 'Technology')
                  {
                    if(contactmap.containskey(candidate.id)){
                        contact cnt = contactmap.get(candidate.id);
                        cnt.Technology_Manager__c = updateList[userAt].id;
                        contactmap.put(candidate.id,cnt);
                    }
                    else{
                      candidate.Technology_Manager__c = updateList[userAt].id;  
                    } 
                  } 
                   else if(currentDepartment == 'Finance')
                  {
                    if(contactmap.containskey(candidate.id)){
                        contact cnt = contactmap.get(candidate.id);
                        cnt.EastBay_Manager__c = updateList[userAt].id;
                        contactmap.put(candidate.id,cnt);
                    }
                    else{
                      candidate.EastBay_Manager__c = updateList[userAt].id;  
                    } 
                  } 

                  updateList[userAt].Last_Assign_Date__c = datetime.now();
                  if(!contactmap.containskey(candidate.id)){
                    contactmap.put(candidate.id,candidate);
                  }
                }
            }
        }

        candidateList.addall(contactmap.values());
        if(updateList!= null && updateList.size()> 0)
        {
          update updateList;
        }

        if(candidateList != null && candidateList.size() > 0)
        {
          update candidateList;          
        }
        
        // Update the Candidate Manager , Case# 00001787
        // This update will not break the trigger as, there is no code on after update..
        //Update appL;  
        }
        catch(Exception e){
          system.debug('e..............'+e);
        }
    }
    
    public static List<User> GetUserList(List<String> departmentList)
    {
      List<User> userList =  [SELECT id, name, Department,Last_Assign_Date__c FROM User 
                where Department in :departmentList
                and Available_for_Round_Robin_Assignment__c = true
                and isActive = true 
                order by Last_Assign_Date__c asc nulls first]; 
      return userList;
    }  
}