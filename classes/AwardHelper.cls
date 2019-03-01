/* 
    Class      : AwardHelper
    Test class :
    Developer  : 
    Reason     : Helper methods for AwardBuilder calculation/display
        
    Change History 
    ******************************************************************************************************************************************
         SCRUM        ModifiedBy        Date            Requested By                           Description                              Tag
    ******************************************************************************************************************************************
       SC-10702    Srinidhi.R       22/04/2016      Guy Baxter              Split Consolidated Invoice by Invoice Cycle
       SC-11479    Khushboo.B       05/07/2016      Benoit Legalant         Updating the daily award with new design
       SC-11604    Khushboo.B       03/08/2016      Michelle Cole           Excluding the manually adjusted timesheetentries
       SC-7350/7088 Khushboo.B      07/10/2016      David Levy              Roll back timesheet when expense fails
       SC-14059/60   Jagadeswary       11/11/2016      David Levy            adding field to query
       CI-171645    Ieswarya J       16/11/2017      David Levy             adding field to query
*/
public class AwardHelper{
    
    //used to send error messages during simulations
    String errorString;   
    public String batchJobId; 
    
    public static Date customToStartOfWeek(Date thisDate, String strWeekDay){
        Integer weekStartDay = UtilClass1.getWeekDayNumber(strWeekDay);
        Date sundayDate = thisDate.toStartOfWeek();
        if(sundayDate.addDays(weekStartDay) <= thisDate)
            return sundayDate.addDays(weekStartDay);
        return sundayDate.addDays(weekStartDay).addDays(-7);        
    }    
    
    //sort a given set of rules by a field
    public static List<tc9_ti__Rule__c> sortRulesByATimeField(List<tc9_ti__Rule__c> rules, String fieldName){
        //check if list is empty
        if(rules.isEmpty())
            return rules;
        
        List<DateTime> dateTimes = new List<DateTime>();
        Map<DateTime, List<tc9_ti__Rule__c>> time_rule_Map = new Map<DateTime, List<tc9_ti__Rule__c>>();
        
        //group rules based on the field-fieldName
        Date tDay = Date.today();
        for(tc9_ti__Rule__c rule : rules){
            Datetime dt;
            String timeStr = '00:00';
            if(rule.get(fieldName) != null)
                timeStr = (String)rule.get(fieldName);
            String[] theTime =  timeStr.split(':'); 
            dt = DateTime.newInstance(tDay.year(),tDay.month(),tDay.day(), Integer.valueOf(theTime[0]), Integer.valueOf(theTime[1]), 0);
            
            if(time_rule_Map.containsKey(dt))
                time_rule_Map.get(dt).add(rule);
            else
                time_rule_Map.put(dt,new List<tc9_ti__Rule__c>{rule});            
        }
        
        dateTimes.addAll(time_rule_Map.keySet());
        dateTimes.sort();
        
        //re-order rules in sorted order
        List<tc9_ti__Rule__c> sortedRuleList    = new List<tc9_ti__Rule__c>();
        for(DateTime dt : dateTimes){
            sortedRuleList.addAll(time_rule_Map.get(dt));
        }
        
        return sortedRuleList;
        
    }
    
    //sort a given set of rules by a field
    public static List<tc9_ti__Rule__c> sortRulesByAField(List<tc9_ti__Rule__c> rules, String fieldName){
        //check if list is empty
        if(rules.isEmpty())
            return rules;
        List<Decimal> thresholdList = new List<Decimal>();
        Map<Decimal,List<tc9_ti__Rule__c>> threshold_rule_Map = new Map<Decimal,List<tc9_ti__Rule__c>>();
        
        //group rules based on the field- fieldName(passed as parameter)
        for(tc9_ti__Rule__c rule : rules){
            Decimal thresholdVal;
            if(rule.get(fieldName)!=null)
                thresholdVal = Decimal.valueOf(''+rule.get(fieldName));
            else
                thresholdVal = 0;
            if(threshold_rule_Map.containsKey(thresholdVal))
                threshold_rule_Map.get(thresholdVal).add(rule);
            else
                threshold_rule_Map.put(thresholdVal,new List<tc9_ti__Rule__c>{rule});
        }
        //sort threshold
        thresholdList.addAll(threshold_rule_Map.keySet());
        thresholdList.sort();
        //re-order rules in sorted order
        List<tc9_ti__Rule__c> sortedRuleList    = new List<tc9_ti__Rule__c>();
        for(Decimal threshold : thresholdList)
            sortedRuleList.addAll(threshold_rule_Map.get(threshold));
        
        return sortedRuleList;
    }
    
    //for the given set of transactions generated for a timesheet, construct the structure :
    // Date : 1x    - a hrs
    //      : 1.50x - b hrs
    //      : 2x    - c hrs
    //      : leave - d hrs
    static Map<Date, TransactionSimulatorWrapper.Simulator> addSimulatedTransactions(List<tc9_ti__Transaction__c> trans, Id tsId){
        list <tc9_ti__Time_Sheet_Entry__c> typeOfleave = new list <tc9_ti__Time_Sheet_Entry__c>([select Id, tc9_ti__Type_of_Leave__c,   tc9_ti__Time_Sheet__c from tc9_ti__Time_Sheet_Entry__c where  tc9_ti__Time_Sheet__c =: tsId]);
        set <string> leave = new set<string>();
        for(tc9_ti__Time_Sheet_Entry__c s : typeOfleave){
            leave.add(s.tc9_ti__Type_of_Leave__c);
        } 
        Map<Date, TransactionSimulatorWrapper.Simulator> tempMap = new Map<Date, TransactionSimulatorWrapper.Simulator>();
        for(tc9_ti__Transaction__c tran : trans){
            system.debug(tran);
            TransactionSimulatorWrapper.Simulator trSimulator;
            String bpType ='';
            if(leave.contains(tran.tc9_ti__Description__c)){
                bpType = tran.tc9_ti__Description__c;
            }
            else {
                bpType  = (tran.tc9_ti__Multiplier__c==1 && tran.tc9_ti__BillRate__c==0.0 && tran.tc9_ti__PayRate__c == 0.0 ) ? tran.tc9_ti__Description__c : tran.tc9_ti__Multiplier__c+'x';
                
                if(bpType == '1.00x')
                    bpType = 'REG';
                else if(bpType == '1.50x')
                    bpType = 'OT';
                else if(bpType == '2.00x')
                    bpType = 'DT';
            } 
            system.debug(bpType);
            if(tempMap.containsKey(tran.tc9_ti__EntryDate__c)){
                //get the object for that date
                trSimulator = tempMap.get(tran.tc9_ti__EntryDate__c);
                //trSimulator.type_PayMultiplier.put(bpType, tran.Multiplier__c);
                //trSimulator.type_BillMultiplier.put(bpType, tran.Bill_Multiplier__c);
                //if the current bp is already in place, add hours actual value
                if(trSimulator.type_Hours.containsKey(bpType)){
                    Decimal currentVal = (trSimulator.type_Hours.get(bpType)==null?0:trSimulator.type_Hours.get(bpType));
                    trSimulator.type_Hours.put(bpType,currentVal + tran.tc9_ti__HoursActutal__c);
                }
                else{   //add new entry to the map
                    trSimulator.type_Hours.put(bpType,tran.tc9_ti__HoursActutal__c);
                }
            }
            else{
                trSimulator     = new TransactionSimulatorWrapper.Simulator();
                trSimulator.workDate = tran.tc9_ti__EntryDate__c;
                trSimulator.type_Hours = new Map<String,Decimal>();
                trSimulator.type_Hours.put(bpType,tran.tc9_ti__HoursActutal__c);
            }
            tempMap.put(tran.tc9_ti__EntryDate__c , trSimulator);
        }
        return tempMap;
    }
    
    static Map<Date, TransactionSimulatorWrapper.Simulator> addSimulatedTransactions_Cloned(List<tc9_ti__Transaction__c> trans, Id tsId){
        
        Map<Date, TransactionSimulatorWrapper.Simulator> tempMap = new Map<Date, TransactionSimulatorWrapper.Simulator>();
        Decimal totalPay, totalBill;
        for(tc9_ti__Transaction__c tran : trans){
            system.debug(tran);
            TransactionSimulatorWrapper.Simulator trSimulator;
            
            String bpType   = tran.tc9_ti__Paycode__c;
            system.debug(bpType);
            if(tempMap.containsKey(tran.tc9_ti__EntryDate__c)){
                //get the object for that date
                trSimulator = tempMap.get(tran.tc9_ti__EntryDate__c);
                
                //if the current bp is already in place, add hours actual value
                if(trSimulator.type_Hours.containsKey(bpType)){
                    Decimal currentVal = (trSimulator.type_Hours.get(bpType)==null?0:trSimulator.type_Hours.get(bpType));
                    trSimulator.type_Hours.put(bpType, currentVal + tran.tc9_ti__HoursActutal__c);
                    
                    //tran.TotalPay__c is the value of qty * paymultiplier * payrate
                    Decimal currentPayVal = (trSimulator.type_PayVal.get(bpType) == null ? 0 : trSimulator.type_PayVal.get(bpType));
                    //Multiplier__c
                    //PayRate__c
                    totalPay = currentPayVal + (tran.tc9_ti__HoursActutal__c * tran.tc9_ti__Multiplier__c * tran.tc9_ti__PayRate__c);
                    trSimulator.type_PayVal.put(bpType, totalPay);
                    
                    Decimal currentBillVal = (trSimulator.type_BillVal.get(bpType)== null ? 0: trSimulator.type_BillVal.get(bpType));
                    //BillRate__c
                    //Bill_Multiplier__c
                    totalBill = currentBillVal + (tran.tc9_ti__HoursActutal__c * tran.tc9_ti__Bill_Multiplier__c * tran.tc9_ti__BillRate__c);
                    trSimulator.type_BillVal.put(bpType, totalBill);
                }
                else{   //add new entry to the map
                    trSimulator.type_Hours.put(bpType,tran.tc9_ti__HoursActutal__c);
                    trSimulator.type_PayVal.put(bpType, (tran.tc9_ti__HoursActutal__c * tran.tc9_ti__Multiplier__c * tran.tc9_ti__PayRate__c));
                    trSimulator.type_BillVal.put(bpType, (tran.tc9_ti__HoursActutal__c * tran.tc9_ti__Bill_Multiplier__c * tran.tc9_ti__BillRate__c));
                }
            }
            else{
                trSimulator     = new TransactionSimulatorWrapper.Simulator();
                trSimulator.workDate = tran.tc9_ti__EntryDate__c;
                
                trSimulator.type_Hours = new Map<String,Decimal>();
                trSimulator.type_Hours.put(bpType,tran.tc9_ti__HoursActutal__c);
                
                trSimulator.type_PayVal = new Map<String, Decimal> ();
                trSimulator.type_PayVal.put(bpType, (tran.tc9_ti__HoursActutal__c * tran.tc9_ti__Multiplier__c * tran.tc9_ti__PayRate__c));
                
                trSimulator.type_BillVal = new Map<String, Decimal> ();
                trSimulator.type_BillVal.put(bpType, (tran.tc9_ti__HoursActutal__c * tran.tc9_ti__Bill_Multiplier__c * tran.tc9_ti__BillRate__c));
            }
            tempMap.put(tran.tc9_ti__EntryDate__c , trSimulator); 
        }
        return tempMap;
    }
    
    public static Map<Id, Map<Date,TransactionSimulatorWrapper.Simulator>> getTransactionForTimesheets_Cloned(List<tc9_ti__Transaction__c> trans){
        
        Map<Id, List<tc9_ti__Transaction__c>> ts_Transaction = new Map<Id, List<tc9_ti__Transaction__c>>();
        Map<Id, Map<Date,TransactionSimulatorWrapper.Simulator>> ts_TransactionSim = new Map<Id, Map<Date,TransactionSimulatorWrapper.Simulator>>();
        
        //group transactions based on the timesheets
        for(tc9_ti__Transaction__c tran : trans){
            if(ts_Transaction.containsKey(tran.tc9_ti__Time_Sheet__c))
                ts_Transaction.get(tran.tc9_ti__Time_Sheet__c).add(tran);
            else
                ts_Transaction.put(tran.tc9_ti__Time_Sheet__c, new List<tc9_ti__Transaction__c>{tran});
        }        
        for(Id tsId : ts_Transaction.keySet()){
            ts_TransactionSim.put(tsId, addSimulatedTransactions_Cloned(ts_Transaction.get(tsId), tsId));
        }        
        return ts_TransactionSim;
    }
    
    public static Map<Id, Map<Date,TransactionSimulatorWrapper.Simulator>> getTransactionForTimesheets(List<tc9_ti__Transaction__c> trans){
        
        Map<Id, List<tc9_ti__Transaction__c>> ts_Transaction = new Map<Id, List<tc9_ti__Transaction__c>>();
        Map<Id, Map<Date,TransactionSimulatorWrapper.Simulator>> ts_TransactionSim = new Map<Id, Map<Date,TransactionSimulatorWrapper.Simulator>>();
        
        //group transactions based on the timesheets
        for(tc9_ti__Transaction__c tran : trans){
            if(ts_Transaction.containsKey(tran.tc9_ti__Time_Sheet__c))
                ts_Transaction.get(tran.tc9_ti__Time_Sheet__c).add(tran);
            else
                ts_Transaction.put(tran.tc9_ti__Time_Sheet__c, new List<tc9_ti__Transaction__c>{tran});
        }
        
        for(Id tsId : ts_Transaction.keySet()){
            ts_TransactionSim.put(tsId, addSimulatedTransactions(ts_Transaction.get(tsId), tsId));
        }        
        return ts_TransactionSim;
    }
    
    //it is mandatory to pass 'Time_Sheet__r.Placement__r.Award_Master__r.RecordTypeId, Time_Sheet__r.RecordType.DeveloperName' field along with the timesheet entry records,
    //otherwise the method throws error
    public String createTransactionForTSE(List<tc9_ti__Time_Sheet_Entry__c> tseRecs){
        
        //get and set award master record types
        Map<String, Id> awardMap = UtilClass1.getRecordTypeMap_ByDeveloperName(NamespaceUtil1.getObjectName(new tc9_ti__Award_Master__c()));
        system.debug('awardMapp '+awardMap);
        for(String s: awardMap.keySet())
            if(s == UtilClass1.AWARD_US_REC_TYPE)
                UtilClass1.AWARD_US_REC_TYPE_ID  = awardMap.get(s);
            else if(s == UtilClass1.AWARD_AUS_REC_TYPE)
                UtilClass1.AWARD_AUS_REC_TYPE_ID = awardMap.get(s); 
            else if(s == UtilClass1.AWARD_DAILY_REC_TYPE)
                UtilClass1.AWARD_DAILY_REC_TYPE_ID = awardMap.get(s);
        
        //get and set transaction record types  
        Map<String, Id> tranMap   = UtilClass1.getRecordTypeMap_ByDeveloperName(NamespaceUtil1.getObjectName(new tc9_ti__Transaction__c()));
        system.debug('tranMap '+tranMap);
        for(String s: tranMap.keySet())
            if(s == UtilClass1.TRAN_TIMESHEET_REC_TYPE_DEVName)
                UtilClass1.TRAN_TIMESHEET_REC_TYPE_ID = tranMap.get(s);
            else if(s == UtilClass1.TRAN_ALLOWANCE_REC_TYPE)
                UtilClass1.TRAN_ALLOWANCE_REC_TYPE_ID = tranMap.get(s);
            else if(s == UtilClass1.TRAN_EXPENSE_REC_TYPE)
                UtilClass1.TRAN_EXPENSE_REC_TYPE_ID = tranMap.get(s);
            
        String returnStr;
        String domainStr = '';
        
        //group timesheet IDs based on the award record type
        Map<Id, Set<Id>> award_TSEs = new Map<Id, Set<Id>>();        
        
        for(tc9_ti__Time_Sheet_Entry__c tse : tseRecs){            
            
            Id key = tse.tc9_ti__Time_Sheet__r.tc9_ti__Placement__r.tc9_ti__Award_Master__r.RecordTypeId;
            if(key != null){
                if(award_TSEs.containsKey(key))
                    award_TSEs.get(key).add(tse.Id);
                else{
                    Set<Id> timesheetentryids = new Set<Id>();
                    if(batchJobId != null && batchJobId != '')
                        timesheetentryids.add(batchJobId);
                    timesheetentryids.add(tse.Id);
                    award_TSEs.put(key, timesheetentryids);
                }
            }
        }
        system.debug('awardTseee '+award_TSEs);
        //get recordtype & custom settings details
        system.debug(' ** Map ** ' + award_TSEs);
        Map<Id, RecordType> awrdRecTypes = new Map<Id, RecordType>([SELECT id, Name, DeveloperName From RecordType WHERE id in: award_TSEs.keySet()]);
        system.debug('awrdRecTypes '+awrdRecTypes); 
        Map<String, tc9_ti__Available_Awards__c> custSettings = tc9_ti__Available_Awards__c.getAll();
        
        for(Id awrdId : award_TSEs.keyset()){
            
            //get record type
            RecordType recType = awrdRecTypes.get(awrdId);
            if(custSettings.containsKey(recType.DeveloperName)){
                
                //get custom settings
                tc9_ti__Available_Awards__c custSettingRec = custSettings.get(recType.DeveloperName);
                system.debug('custSettingRec '+custSettingRec); 
                try{
                    
                    //process the record type's timesheet entries, using the class mentioned in the corresponding custom settings
                    Type t = Type.forName(custSettingRec.tc9_ti__Award_Interpreter_Class__c);
                    AwardBuilderInterface factory = (AwardBuilderInterface)t.newInstance();
                    returnStr                       = factory.createTransactionForTSE(award_TSEs.get(awrdId));
                    if(returnStr != null)
                        return 'Error while processing \''+ custSettingRec.tc9_ti__Display_Name__c + '\' domain : ' + returnStr;
                }
				catch(Exception e){
				
				
				}
                /*catch(Exception e){
                    
                    throw (debugException)e;
                   // String domain = custSettingRec.tc9_ti__Display_Name__c;
                    if(domain == null)
                        domain = custSettingRec.Name; 
                    return 'Error while processing \''+ domain + '\' domain : Please provide valid class name in \'Available Awards\' custom settings';
                }*/
            }
            else{
                return 'There is no page assigned for the Award record type '+ recType.DeveloperName ; 
            }
        }
        return returnStr;
    }
    
    //it is mandatory to pass 'Time_Sheet__r.Placement__r.Award_Master__r.RecordTypeId, Time_Sheet__r.RecordType.DeveloperName' field along with the timesheet entry records,
    //otherwise the method throws error
    public List<tc9_ti__Transaction__c> simulateTransactionsForTSE(Set<Id> tseId){
        
        //get and set award master record types
        Map<String, Id> awardMap = UtilClass1.getRecordTypeMap_ByDeveloperName(NamespaceUtil1.getObjectName(new tc9_ti__Award_Master__c()));
        for(String s: awardMap.keySet())
            if(s == UtilClass1.AWARD_US_REC_TYPE)
                UtilClass1.AWARD_US_REC_TYPE_ID  = awardMap.get(s);
            else if(s == UtilClass1.AWARD_AUS_REC_TYPE)
                UtilClass1.AWARD_AUS_REC_TYPE_ID = awardMap.get(s); 
            else if(s == UtilClass1.AWARD_DAILY_REC_TYPE)
                UtilClass1.AWARD_DAILY_REC_TYPE_ID = awardMap.get(s);
        
        //get and set transaction record types  
        Map<String, Id> tranMap   = UtilClass1.getRecordTypeMap_ByDeveloperName(NamespaceUtil1.getObjectName(new tc9_ti__Transaction__c()));
        for(String s: tranMap.keySet())
            if(s == UtilClass1.TRAN_TIMESHEET_REC_TYPE_DEVName)
                UtilClass1.TRAN_TIMESHEET_REC_TYPE_ID = tranMap.get(s);
            else if(s == UtilClass1.TRAN_ALLOWANCE_REC_TYPE)
                UtilClass1.TRAN_ALLOWANCE_REC_TYPE_ID = tranMap.get(s);
            else if(s == UtilClass1.TRAN_EXPENSE_REC_TYPE)
                UtilClass1.TRAN_EXPENSE_REC_TYPE_ID = tranMap.get(s);
        
        List<tc9_ti__Transaction__c> trans  = new List<tc9_ti__Transaction__c>();
        
        //group timesheet IDs based on the award record type
        Map<Id, Set<Id>> award_TSEs = new Map<Id, Set<Id>>(); 
        
        for(tc9_ti__Time_Sheet_Entry__c tse : [SELECT tc9_ti__Time_Sheet__r.tc9_ti__Placement__r.tc9_ti__Award_Master__r.RecordTypeId, tc9_ti__Time_Sheet__r.RecordType.DeveloperName from tc9_ti__Time_Sheet_Entry__c Where id in : tseId]){
            
            Id key = tse.tc9_ti__Time_Sheet__r.tc9_ti__Placement__r.tc9_ti__Award_Master__r.RecordTypeId;
            if(award_TSEs.containsKey(key))
                award_TSEs.get(key).add(tse.Id);
            else
                award_TSEs.put(key, new Set<Id>{tse.Id});
        }
        
        system.debug(' ** Map ** ' + award_TSEs);
        Map<Id, RecordType> awrdRecTypes = new Map<Id, RecordType>([SELECT id, Name, DeveloperName From RecordType WHERE id in: award_TSEs.keySet()]);
        Map<String, tc9_ti__Available_Awards__c> custSettings = tc9_ti__Available_Awards__c.getAll();
        
        system.debug('***' + custSettings); 
        
        for(Id awrdId : award_TSEs.keyset()){
            
            system.debug('awrdRecTypes'+awrdRecTypes + ' '+awrdId);
            //get record type
            RecordType recType = awrdRecTypes.get(awrdId);            
            
            if(custSettings.containsKey(recType.DeveloperName)){
                
                //get custom settings
                tc9_ti__Available_Awards__c custSettingRec = custSettings.get(recType.DeveloperName);
                try{
                    //process the record type's timesheet entries, using the class mentioned in the corresponding custom settings
                    Type t = Type.forName(custSettingRec.tc9_ti__Award_Interpreter_Class__c);
                    AwardBuilderInterface factory = (AwardBuilderInterface)t.newInstance();
                    
                    
                    List<tc9_ti__Transaction__c> thisTrans = factory.simulateTransactionsForTSE(award_TSEs.get(awrdId));
                    if(thisTrans == null){
                        errorString = 'Error while processing \''+ custSettingRec.tc9_ti__Display_Name__c + '\' domain : ' + factory.getErrorString();
                        return null;
                    }
                    trans.addAll(thisTrans);
                    
                }
				catch(Exception e){
				
				
				}
				/*catch(Exception e){
				
                    throw new debugException(e.getMessage(),e);
                    //String domain = custSettingRec.tc9_ti__Display_Name__c;
                    if(domain == null)
                        domain = custSettingRec.Name; 
                    errorString = 'Error while processing \''+ domain + '\' domain : Please provide valid class name in \'Available Awards\' custom settings';
                    return null;
                }*/
            }
        }
        
        return trans;
    }
    
    public String getErrorString(){
        return errorString;
    }
    
    public static Map<String,list<tc9_ti__Time_Sheet_Entry__c>> weeklyTimesheetEntries(list<tc9_ti__Time_Sheet_Entry__c> listOfEntries,List<Date> allWeekStartDays){
        
        Date tseEndDate;
        
        Set<Id> plcIds = new Set<Id>();
        Map<Id,Date> mapOfPlacementAndHighdate = new Map<Id,Date>();
        for(tc9_ti__Time_Sheet_Entry__c tse : listOfEntries){
            plcIds.add(tse.tc9_ti__Time_Sheet__r.tc9_ti__Placement__c);
            
            if(mapOfPlacementAndHighdate.containsKey(tse.tc9_ti__Time_Sheet__r.tc9_ti__Placement__c) ){
                if(tse.tc9_ti__WorkDate__c > mapOfPlacementAndHighdate.get(tse.tc9_ti__Time_Sheet__r.tc9_ti__Placement__c))
                    mapOfPlacementAndHighdate.put(tse.tc9_ti__Time_Sheet__r.tc9_ti__Placement__c, tse.tc9_ti__WorkDate__c);
            }    
            else
                mapOfPlacementAndHighdate.put(tse.tc9_ti__Time_Sheet__r.tc9_ti__Placement__c, tse.tc9_ti__WorkDate__c);
        }        
        
        //query all timesheet entries between the earliest date & the end date given by the user
        List<tc9_ti__Time_Sheet_Entry__c> prevTimesheetEntries = [select Id, tc9_ti__Time_Sheet__r.tc9_ti__Placement__r.tc9_ti__Award_Master__c,tc9_ti__Time_Sheet__r.tc9_ti__Placement__r.tc9_ti__Public_Holiday_Calendar__c,
                                                          tc9_ti__Time_Sheet__c,tc9_ti__Time_Sheet__r.tc9_ti__Placement__c,tc9_ti__Time_Sheet__r.tc9_ti__Placement__r.ts2__Job__r.tc9_ti__Week_Start_Day__c, tc9_ti__WorkDate__c,tc9_ti__WorkDay__c ,tc9_ti__BreakTime__c,tc9_ti__Edited__c,
                                                          tc9_ti__End_Date__c,tc9_ti__Flagged__c,tc9_ti__HoursAcutal__c,tc9_ti__Status__c,tc9_ti__BreakTime2__c,tc9_ti__Type_of_Leave__c ,tc9_ti__Start__c ,tc9_ti__Time_Sheet__r.tc9_ti__Week_Start_Day__c,
                                                          tc9_ti__End__c,tc9_ti__Time_Sheet__r.tc9_ti__Placement__r.tc9_ti__Market__c,tc9_ti__Time_Sheet__r.tc9_ti__Placement__r.tc9_ti__Base_Bill_Rate__c,tc9_ti__Processed_Date__c, tc9_ti__Time_Sheet__r.tc9_ti__Placement__r.ts2__Client__r.tc9_ti__Billing_Entity__c,
                                                          tc9_ti__Time_Sheet__r.tc9_ti__Placement__r.tc9_ti__Base_Pay_Rate__c,tc9_ti__Time_Sheet__r.tc9_ti__Placement__r.tc9_ti__Market__r.tc9_ti__TaxID__c,tc9_ti__Time_Sheet__r.tc9_ti__Placement__r.tc9_ti__Market__r.tc9_ti__TaxID__r.tc9_ti__Rate__c,
                                                          tc9_ti__Time_Sheet__r.tc9_ti__Placement__r.ts2__Job__c, tc9_ti__Time_Sheet__r.tc9_ti__Placement__r.ts2__Job__r.ts2__Account__c, tc9_ti__Time_Sheet__r.tc9_ti__Placement__r.ts2__Job__r.ts2__Account__r.tc9_ti__Group_By_Project_Code__c,
                                                          tc9_ti__Time_Sheet__r.tc9_ti__Placement__r.ts2__Job__r.ts2__Account__r.tc9_ti__Invoice_Group_By__c,
                                                          tc9_ti__Time_Sheet__r.tc9_ti__Placement__r.ts2__Job__r.ts2__Account__r.tc9_ti__Invoice_Split__c,
                                                          tc9_ti__Time_Sheet__r.tc9_ti__Placement__r.ts2__Client__r.tc9_ti__Invoice_Split__c,
                                                          tc9_ti__Time_Sheet__r.tc9_ti__Placement__r.tc9_ti__Bill_To_Contact__c,
                                                          tc9_ti__Time_Sheet__r.tc9_ti__Placement__r.ts2__Client__c,
                                                          tc9_ti__Time_Sheet__r.tc9_ti__Placement__r.tc9_ti__Bill_To_Account__c,
                                                          tc9_ti__Time_Sheet__r.tc9_ti__Placement__r.tc9_ti__Client_Hiring_Manager__c,
                                                          tc9_ti__Time_Sheet__r.tc9_ti__Placement__r.tc9_ti__Rate_Calculator__c,
                                                          tc9_ti__Time_Sheet__r.tc9_ti__Placement__r.ts2__Client__r.tc9_ti__Invoice_Group_By__c,
                                                          tc9_ti__Time_Sheet__r.tc9_ti__Start_Date__c,
                                                          tc9_ti__Time_Sheet__r.tc9_ti__End_Date__c,CurrencyIsoCode,
                                                          tc9_ti__Time_Sheet__r.tc9_ti__Placement__r.tc9_ti__Purchase_Order_Number__c,
                                                          tc9_ti__Project_Code__c
                                                          from tc9_ti__Time_Sheet_Entry__c  
                                                          WHERE tc9_ti__Status__c = 'Approved'  
                                                          and tc9_ti__WorkDate__c >=: allWeekStartDays.get(0)
                                                          and tc9_ti__WorkDate__c <= :listOfEntries.get(listOfEntries.size()-1).tc9_ti__WorkDate__c
                                                          and id not in: listOfEntries
                                                          and tc9_ti__Time_Sheet__r.tc9_ti__Placement__c in : plcIds
                                                          and tc9_ti__Manual_Adjustment__c = false 
                                                          order by  tc9_ti__WorkDate__c,  tc9_ti__Start__c, tc9_ti__End__c, Name
                                                         ];
        system.debug('listOfEntries '+listOfEntries);                                                
        system.debug('prevTimesheetEntries '+prevTimesheetEntries);  
        
        //List of all the time sheet entries including entries from the previous Timesheets
        list<tc9_ti__Time_Sheet_Entry__c> listOfAllEntries = new list<tc9_ti__Time_Sheet_Entry__c> ();
        listOfAllEntries.addAll(listOfEntries);
        listOfAllEntries.addAll(prevTimesheetEntries);
        
        system.debug('listOfAllEntriessssss '+listOfAllEntries);
        Map<String,list<tc9_ti__Time_Sheet_Entry__c>> mapOfPlacementAndEntries = new Map<String,list<tc9_ti__Time_Sheet_Entry__c>>();
        
        //List of weekly timesheet entries
        for(tc9_ti__Time_Sheet_Entry__c tse : listOfAllEntries){
            tseEndDate = mapOfPlacementAndHighdate.get(tse.tc9_ti__Time_Sheet__r.tc9_ti__Placement__c);
            if(tse.tc9_ti__WorkDate__c <= tseEndDate){
                
                Date keyDate = customToStartOfWeek(tse.tc9_ti__WorkDate__c,tse.tc9_ti__Time_Sheet__r.tc9_ti__Week_Start_Day__c);
                String s= tse.tc9_ti__Time_Sheet__r.tc9_ti__Placement__c+'-'+keyDate;
                if(mapOfPlacementAndEntries.containsKey(s))
                    mapOfPlacementAndEntries.get(s).add(tse);
                else
                    mapOfPlacementAndEntries.put(s,new List<tc9_ti__Time_Sheet_Entry__c>{tse}); 
            }
        }        
        return mapOfPlacementAndEntries;       
    }
    /*
    public class timesheetWrapper implements comparable{   
        
        public Time_Sheet_Entry__c timeEntry ;       
        
        public timesheetWrapper(Time_Sheet_Entry__c timesheeEntry){
            timeEntry = timesheeEntry;
        }       
        
        public Integer compareTo(object tranObj){                        
            timesheetWrapper awd = (timesheetWrapper)tranObj;
            if(this.timeEntry.WorkDate__c > awd.timeEntry.WorkDate__c) 
                return 1;
            else if(this.timeEntry.WorkDate__c < awd.timeEntry.WorkDate__c)
                return -1;
            
            return 0;
        }        
    }  
    */  
}