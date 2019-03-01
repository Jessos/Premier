/**
	Purpose : Used by trg_Placement.trg
	Test cls: Testtrg_Placement.cls
**/

public with sharing class PlacementTriggerUtility {
	
	public static boolean plcAfterTrigger = false;
	
	//populate the latest placement (based on start date) on candidate contact record
	public static void populateLatestPlacementOnCandidate(List<ts2__Placement__c> placements, Map<Id, ts2__Placement__c> oldMap, boolean isInsert){
		
		Set<Id> candidateIds = new Set<Id>();
		Map<Id, ts2__Placement__c> candidate_LatestPlc = new Map<Id, ts2__Placement__c>();
		//Map<Id, ts2__Placement__c> candidate_FirstPlc = new Map<Id, ts2__Placement__c>();
			
		for(ts2__Placement__c plc : placements){
			if(isInsert || ((plc.ts2__Employee__c != oldMap.get(plc.Id).ts2__Employee__c) ||
							(plc.ts2__Start_Date__c != oldMap.get(plc.Id).ts2__Start_Date__c) )){
				
				ts2__Placement__c latestPlacementId 	 = plc;
				//ts2__Placement__c firstPlacementId 	 = plc;
				Date latestPlacementDate = plc.ts2__Start_Date__c;
				
				// module that can be used to update for existing data - first placement
				/*if(candidate_FirstPlc.containsKey(plc.ts2__Employee__c)){
					ts2__Placement__c previousPlc = candidate_FirstPlc.get(plc.ts2__Employee__c);
					if(previousPlc.ts2__Start_Date__c < latestPlacementDate){
						firstPlacementId = previousPlc;
					}
				}
				candidate_FirstPlc.put(plc.ts2__Employee__c, firstPlacementId); */
				
				//check if the candidate has more than one placement inserted, and compare the start dates
				if(candidate_LatestPlc.containsKey(plc.ts2__Employee__c)){
					ts2__Placement__c previousPlc = candidate_LatestPlc.get(plc.ts2__Employee__c);
					if(previousPlc.ts2__Start_Date__c > latestPlacementDate){
						latestPlacementId = previousPlc;
					}
				}
				candidate_LatestPlc.put(plc.ts2__Employee__c, latestPlacementId);
			}
		}
		
		if(candidate_LatestPlc.isEmpty()) // && candidate_FirstPlc.isEmpty())
			return;
		
		//get candidates
		List<Contact> candidates = [SELECT id, Latest_Placement__c, First_Placement__c, Latest_Placement__r.ts2__Start_Date__c FROM Contact WHERE id in: candidate_LatestPlc.keySet()];
		
		boolean ischangedLatest = false;
		boolean ischangedFirst = false;
		for(Contact candidate : candidates){
			
			//get latest placement from map
			ts2__Placement__c latestPlacement = candidate_LatestPlc.get(candidate.Id);
			
			// module that can be used to update for existing data - first placement
			/*if(candidate_FirstPlc.containsKey(candidate.Id)){
				ts2__Placement__c FirstPlacement = candidate_FirstPlc.get(candidate.Id);
				//set first placement
				if(candidate.First_Placement__c == null){
					candidate.First_Placement__c = FirstPlacement.Id;
					ischangedFirst = true;
				}
			}*/
			//set the first placement for new data
			if(candidate.First_Placement__c == null){
				candidate.First_Placement__c = latestPlacement.Id;
				ischangedFirst = true;
			}
			
			//change latest placement if the existing placement starts earlier
			if(candidate.Latest_Placement__c == null || candidate.Latest_Placement__r.ts2__Start_Date__c == null ||
			   candidate.Latest_Placement__r.ts2__Start_Date__c <= latestPlacement.ts2__Start_Date__c){			   	
			   	ischangedLatest = true;
			   	candidate.Latest_Placement__c = latestPlacement.Id;
			}
		}
		
		//perform DML if there is a change
		if(ischangedLatest || ischangedFirst)
			update candidates;
	}
	
	
	/*** Populate placment fields with Job order field values 
	     Works On-Insert ***/ 
	public static void populateFromJobOrder(List<ts2__Placement__c> placements){
		
		List<String> jobFields  = new List<String>{'tc9_ti__Base_Bill_Rate__c','tc9_ti__Base_Pay_Rate__c','tc9_ti__Market__c','ts2__Contact__c','ts2__Contact__c','ts2__Contact__r.MailingStreet','ts2__Contact__r.MailingCity','ts2__Contact__r.MailingState','ts2__Contact__r.MailingCountry','ts2__Contact__r.MailingPostalCode'};
	    List<String> plcFields  = new List<String>{'tc9_ti__Base_Bill_Rate__c','tc9_ti__Base_Pay_Rate__c','tc9_ti__Market__c','tc9_ti__TimeSheetApprover__c','ts2__Accounts_Payable__c','Billing_Address_1__c','City__c','Billing_State__c','Billing_Address_2__c','Billing_ZIP__c'};
	    List<String> fieldType  = new List<String>();
	    
	     //get the field's label and picklist values
	    Map<String, Schema.SObjectField> fieldMap = Sobjecttype.ts2__Placement__c.fields.getMap();
	    
	    for(Integer i=0;i<plcFields.size();i++){
	        if(fieldMap.get(plcFields[i]).getDescribe().getType() == Schema.DisplayType.Integer || 
	                fieldMap.get(plcFields[i]).getDescribe().getType()  == Schema.DisplayType.Double || 
	                fieldMap.get(plcFields[i]).getDescribe().getType()  == Schema.DisplayType.Currency || 
	                fieldMap.get(plcFields[i]).getDescribe().getType()  == Schema.DisplayType.Percent )
	            fieldType.add('Number');
	        else
	            fieldType.add('String');
	    }
	    
	    system.debug(fieldType);
	    
	    //collect related job Ids
	    Set<Id> jobIds          = new Set<Id>();
	    for(ts2__Placement__c plc : placements){
	        jobIds.add(plc.ts2__Job__c);
	    }
	    
	    //construct query string
	    Set<String> preventDuplicate = new Set<String>();
	    String queryStr         = 'SELECT id, ';
	    for(String s : jobFields){
	        if(!preventDuplicate.contains(s))
	            queryStr           += s +' , ';
	        preventDuplicate.add(s);
	    }
	    queryStr               += ' Name FROM ts2__Job__c WHERE id in : jobIds ';
	    Map<Id, ts2__Job__c> relatedJobs = new Map<Id,ts2__Job__c>();
	    for(ts2__Job__c job : Database.query(queryStr)){
	        relatedJobs.put(job.Id, job);
	    }
	    
	    //populate public holidate calander for placement
	    String year     = '' + Date.today().year();
	    String calName  = 'Premier Staffing - US CA '+year;
	    List<tc9_ti__Public_Holiday_Calendar__c> cals   = [SELECT id From tc9_ti__Public_Holiday_Calendar__c WHERE Name= :calName];
	    
	    //populate award master
	    String awardName = 'Premier Staffing US CA';
	    List<tc9_ti__Award_Master__c> awardMasters  = [SELECT id FROM tc9_ti__Award_Master__c WHERE Name = : awardName];
	    
	    for(ts2__Placement__c plc : placements){
	        for(Integer i=0;i<jobFields.size();i++){
	            if(jobFields[i].contains('.')){
	                String[] fieldName = jobFields[i].split('\\.');
	                SObject obj = relatedJobs.get(plc.ts2__Job__c).getsObject(fieldName[0]);
	                if(obj!=null)
	                    plc.put(plcFields[i], obj.get(fieldName[1]));
	            }
	            else{
	                if(fieldType[i]=='Number')
	                    plc.put(plcFields[i], (relatedJobs.get(plc.ts2__Job__c).get(jobFields[i])==null) ? 0 : relatedJobs.get(plc.ts2__Job__c).get(jobFields[i]));
	                else
	                    plc.put(plcFields[i], relatedJobs.get(plc.ts2__Job__c).get(jobFields[i]));
	            }
	        }
	        
	        //populate public holidate calander for placement
	        if(!cals.isEmpty())
	            plc.tc9_ti__Public_Holiday_Calendar__c      = cals.get(0).Id;
	        
	        //populate award master for placement
	        if(!awardMasters.isEmpty())
	            plc.tc9_ti__Award_Master__c                 = awardMasters.get(0).Id;
	    }
	}
}