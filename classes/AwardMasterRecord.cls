/*
    Class      : AwardMasterRecord 
    Test class : 
    Developer  : 
    Reason     : 
    
    Change History 
    ******************************************************************************************************************************************
         SCRUM        ModifiedBy        Date            Requested By                           Description                              Tag
    ******************************************************************************************************************************************
Changed SC-16736       Ieswarya J       23/10/2017       Michelle Cole             Award Master - Saturdays/Sundays/Pub Hols require hours breakpoints

*/

public class AwardMasterRecord {
    
    public static String DAILY_HOURS_BREAKPOINT_RULE = 'Daily hours Breakpoint';
    public static String WEEKLY_BREAKPOINT_RULE = 'Weekly Breakpoint';
    public static String SATURDAY_BREAKPOINT_RULE = 'Saturday hours Breakpoint';
    public static String SUNDAY_BREAKPOINT_RULE = 'Sunday hours Breakpoint';    
    public static String PH_BREAKPOINT_RULE = 'Public Holiday hours Breakpoint';
    
    
    public static String SATURDAY_RULE = 'Saturday';
    public static String SUNDAY_RULE = 'Sunday';
    
    public static String PUBLIC_HOLIDAY_RULE= 'Public Holiday';
    public static String PUBLIC_HOLIDAY_HOURS_BREAKPOINT_RULE = 'Public Holiday Hours Breakpoint';
    
    //Australia
    public static String DAILY_TIME_BREAKPOINT_RULE = 'Daily time Breakpoint';
    public static String DAILY_START_TIME_BREAKPOINT_RULE = 'Daily Start time Breakpoint';
    public static String OUTSIDE_SATURDAY_RULE = 'Outside Saturday';
    public static String OUTSIDE_SUNDAY_RULE = 'Outside Sunday';
    public static String OUTSIDE_PUBLIC_HOLIDAY_RULE = 'Outside Public Holiday';
    public static String SATURDAY_START_TIME_BREAKPOINT_RULE = 'Saturday Start Time Breakpoint';
    public static String SUNDAY_START_TIME_BREAKPOINT_RULE = 'Sunday Start Time Breakpoint';
    public static String PUBLIC_HOLIDAY_START_TIME_BREAKPOINT_RULE = 'Public Holiday Start Time Breakpoint';
    public static String MEAL_RULE = 'Meal Allowance';
    public static String ALLOWANCE_BREAKPOINT = 'Allowance Breakpoint';
    
    //US
    public static String LEAVE_RULE = 'Leave';  
    public static String X_7TH_DAY_RULE = '7th Day Breakpoint'; 
    public static String DAILY_BREAKPOINT_ABOVE_ORD_WEEKLY = 'Daily Breakpoint Above Ordinary Weekly';
    
    public static String WORK_DAY_RULE = 'Work Day';
    
    /***************** Rules of the Award Master **********/
  /*  Not used in code
    List<tc9_ti__Rule__c> dailyBPRules;
    List<tc9_ti__Rule__c> dailyTimeBPRules;
    List<tc9_ti__Rule__c> dailyStartTimeBPRules;
    List<tc9_ti__Rule__c> dailyBPRulesAboveWeekly;
    
    List<tc9_ti__Rule__c> weeklyBPRules;
    
    tc9_ti__Rule__c saturdayRule;
    List<tc9_ti__Rule__c> SaturdayBPRules;
    List<tc9_ti__Rule__c> SundayBPRules;
    List<tc9_ti__Rule__c> PHBPRules;
    List<tc9_ti__Rule__c> saturdayStartTimeBPRules;
    List<tc9_ti__Rule__c> saturdayOT_BPRules;
    
    tc9_ti__Rule__c sundayRule;
    List<tc9_ti__Rule__c> sundayStartTimeBPRules;
    List<tc9_ti__Rule__c> sundayOT_BPRules;
    
    tc9_ti__Rule__c publicHolidayRule;
    List<tc9_ti__Rule__c> PHOT_BPRules;
    List<tc9_ti__Rule__c> publicHolidayStartTimeBPRules;
    List<tc9_ti__Rule__c> publicHolidayHourlyBPRules;
    
    tc9_ti__Rule__c mealRule;
    List<tc9_ti__Rule__c> allowanceBPRules;
    List<tc9_ti__Rule__c> leaveRules;
    List<tc9_ti__Rule__c> x_7thDayRules;
    
    tc9_ti__Rule__c outsideSaturdayRule;
    tc9_ti__Rule__c outsideSundayRule;
    
    tc9_ti__Rule__c workDayRule;
    tc9_ti__Award_Master__c awrdMasterRecord;*/
    
    /***************** Getter ***************************/
  /*  public List<tc9_ti__Rule__c> getDailyBPRules(){
        return dailyBPRules;
    }
    public List<tc9_ti__Rule__c> getDailyTimeBPRules(){
        return dailyTimeBPRules;
    }
    public List<tc9_ti__Rule__c> getdailyStartTimeBPRules(){
        return dailyStartTimeBPRules;
    }
    public List<tc9_ti__Rule__c> getWeeklyBPRules(){
        return weeklyBPRules;
    }
    
    public List<tc9_ti__Rule__c> getSaturdayBPRules(){
        return SaturdayBPRules;
    }
    
    public List<tc9_ti__Rule__c> getSundayBPRules(){
        return SundayBPRules;
    }
    
    public List<tc9_ti__Rule__c> getPHBPRules(){
        return PHBPRules;
    }
    
    public List<tc9_ti__Rule__c> getAllowanceBPRules(){
        return allowanceBPRules;
    }
    public tc9_ti__Rule__c getSaturdayRule(){
        return saturdayRule;
    }
    public List<tc9_ti__Rule__c> getSaturdayStartTimeBPRules(){
        return saturdayStartTimeBPRules;
    }
    public List<tc9_ti__Rule__c> getSaturdayOTBPRules(){
        return saturdayOT_BPRules;
    }
    public tc9_ti__Rule__c getOutsideSaturdayRule(){
        return outsideSaturdayRule;
    }
    
    public List<tc9_ti__Rule__c> getoutsidePHRule(){
       return PHOT_BPRules;            
    }
    public tc9_ti__Rule__c getSundayRule(){
        return sundayRule;
    }
    public List<tc9_ti__Rule__c> getSundayStartTimeBPRules(){
        return sundayStartTimeBPRules;
    }
    public List<tc9_ti__Rule__c> getSundayOTBPRules(){
        return sundayOT_BPRules;
    }
    public tc9_ti__Rule__c getOutsideSundayRule(){
        return outsideSundayRule;
    }
    public List<tc9_ti__Rule__c> getPublicHolidayStartTimeBPRules(){
        return publicHolidayStartTimeBPRules;
    }
    public tc9_ti__Rule__c getMealRule(){
        return mealRule;
    }
    public tc9_ti__Rule__c getPublicHolidayRule(){
        return publicHolidayRule;
    }
    public List<tc9_ti__Rule__c> getPubilcHolidayHoursBPRules(){
        return publicHolidayHourlyBPRules;
    }
    public tc9_ti__Rule__c getWorkDayRule(){
        return workDayRule;
    }
    public tc9_ti__Award_Master__c getAwradMaster(){
        return awrdMasterRecord;
    }
    public List<tc9_ti__Rule__c> getLeaveRules(){
        return leaveRules;
    }
    public List<tc9_ti__Rule__c> get7thDayRules(){
        return x_7thDayRules;
    }
    //get daily bp rules for hours above Ordinary weekly hours (US)
    public List<tc9_ti__Rule__c> getDailyBPRulesAboveWeekly(){
        return dailyBPRulesAboveWeekly;
    }
    
    //get a type of leave
    public List<tc9_ti__Rule__c> getLeaveRules(String name){
        List<tc9_ti__Rule__c> leaveRulesTemp = new List<tc9_ti__Rule__c>();
        for(tc9_ti__Rule__c rule : leaveRules)
            if(rule.Name == name)
                leaveRulesTemp.add(rule);
        return leaveRulesTemp;
    }
    
    //constructor
    public AwardMasterRecord(tc9_ti__Award_Master__c awrdMaster){
        
        this.awrdMasterRecord = awrdMaster;
        
        dailyBPRules        = populateATypeOfRules(DAILY_HOURS_BREAKPOINT_RULE);
        dailyBPRules        = sortByColumn(dailyBPRules,'Start_Threshold__c');
        
        dailyTimeBPRules    = populateATypeOfRules(DAILY_TIME_BREAKPOINT_RULE);
        dailyTimeBPRules    = sortByColumn(dailyTimeBPRules,'Start_Threshold__c');
        
        dailyStartTimeBPRules   = populateATypeOfRules(DAILY_START_TIME_BREAKPOINT_RULE);
        dailyStartTimeBPRules   = AwardHelper.sortRulesByATimeField(dailyStartTimeBPRules, 'Start_Time__c');
        
        weeklyBPRules       = populateATypeOfRules(WEEKLY_BREAKPOINT_RULE);
        weeklyBPRules       = sortByColumn(weeklyBPRules,'Start_Threshold__c');
        
        SaturdayBPRules     = populateATypeOfRules(SATURDAY_BREAKPOINT_RULE);
        SaturdayBPRules     = sortByColumn(SaturdayBPRules,'Start_Threshold__c');
        
        SundayBPRules     = populateATypeOfRules(SUNDAY_BREAKPOINT_RULE);
        SundayBPRules     = sortByColumn(SundayBPRules,'Start_Threshold__c');
        
        PHBPRules     = populateATypeOfRules(PH_BREAKPOINT_RULE);
        PHBPRules     = sortByColumn(PHBPRules,'Start_Threshold__c');
        
        allowanceBPRules    = populateATypeOfRules(ALLOWANCE_BREAKPOINT);
        allowanceBPRules    = sortByColumn(allowanceBPRules,'End_Threshold__c');
        
        saturdayOT_BPRules  = populateATypeOfRules(OUTSIDE_SATURDAY_RULE);
        saturdayOT_BPRules  = sortByColumn(saturdayOT_BPRules, 'Start_Threshold__c');
        
        sundayOT_BPRules    = populateATypeOfRules(OUTSIDE_SUNDAY_RULE);
        sundayOT_BPRules    = sortByColumn(sundayOT_BPRules, 'Start_Threshold__c');
        
        PHOT_BPRules        = populateATypeOfRules(OUTSIDE_PUBLIC_HOLIDAY_RULE);
        PHOT_BPRules        = sortByColumn(PHOT_BPRules, 'Start_Threshold__c');
        
        saturdayStartTimeBPRules= populateATypeOfRules(SATURDAY_START_TIME_BREAKPOINT_RULE);
        saturdayStartTimeBPRules= AwardHelper.sortRulesByATimeField(saturdayStartTimeBPRules, 'Start_Time__c');
        
        sundayStartTimeBPRules  = populateATypeOfRules(SUNDAY_START_TIME_BREAKPOINT_RULE);
       sundayStartTimeBPRules  = AwardHelper.sortRulesByATimeField(sundayStartTimeBPRules, 'Start_Time__c');
        
        publicHolidayStartTimeBPRules = populateATypeOfRules(PUBLIC_HOLIDAY_START_TIME_BREAKPOINT_RULE);
       publicHolidayStartTimeBPRules = AwardHelper.sortRulesByATimeField(publicHolidayStartTimeBPRules, 'Start_Time__c');
        
        publicHolidayHourlyBPRules    = populateATypeOfRules(PUBLIC_HOLIDAY_HOURS_BREAKPOINT_RULE);
        publicHolidayHourlyBPRules    = sortByColumn(publicHolidayHourlyBPRules,'Start_Threshold__c');
        
        leaveRules          = populateATypeOfRules(LEAVE_RULE);
        
        x_7thDayRules       = populateATypeOfRules(X_7TH_DAY_RULE);
        x_7thDayRules       = sortByColumn(x_7thDayRules, 'Start_Threshold__c');
        
        dailyBPRulesAboveWeekly     = populateATypeOfRules(DAILY_BREAKPOINT_ABOVE_ORD_WEEKLY);
        dailyBPRulesAboveWeekly     = sortByColumn(dailyBPRulesAboveWeekly, 'Start_Threshold__c');
        
        saturdayRule        = populateATypeOfRule(SATURDAY_RULE);
        sundayRule          = populateATypeOfRule(SUNDAY_RULE);
        outsideSaturdayRule = populateATypeOfRule(OUTSIDE_SATURDAY_RULE);
        outsideSundayRule   = populateATypeOfRule(OUTSIDE_SUNDAY_RULE);
        mealRule            = populateATypeOfRule(MEAL_RULE);
        publicHolidayRule   = populateATypeOfRule(PUBLIC_HOLIDAY_RULE);
        workDayRule         = populateATypeOfRule(WORK_DAY_RULE);
    }
    
    //populate list with the specified type
    private List<tc9_ti__Rule__c> populateATypeOfRules(String ruleType){
        List<tc9_ti__Rule__c> ruleListToPopulate = new List<tc9_ti__Rule__c>();
        for(tc9_ti__Rule__c rule : this.awrdMasterRecord.tc9_ti__Rules__r)
            if(rule.tc9_ti__type__c == ruleType)
                ruleListToPopulate.add(rule);
        return ruleListToPopulate;
    }
    
    private tc9_ti__Rule__c populateATypeOfRule(String ruleType){
        tc9_ti__Rule__c ruleToPopulate;
        for(tc9_ti__Rule__c rule : this.awrdMasterRecord.tc9_ti__Rules__r)
            if(rule.tc9_ti__type__c == ruleType){
                ruleToPopulate = rule;
                break;
            }
        return ruleToPopulate;
    }
    
    private List<tc9_ti__Rule__c> sortByColumn(List<tc9_ti__Rule__c> rules,String fieldName){
        
        //check if list is empty
        if(rules.isEmpty())
            return rules;
        system.debug('***' );   
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
        system.debug('***' );   
        //sort threshold
        thresholdList.addAll(threshold_rule_Map.keySet());
        thresholdList.sort();
        system.debug('***' );   
        //re-order rules in sorted order
        List<tc9_ti__Rule__c> sortedRuleList    = new List<tc9_ti__Rule__c>();
        for(Decimal threshold : thresholdList)
            sortedRuleList.addAll(threshold_rule_Map.get(threshold));
        
        return sortedRuleList;
    }*/
    
}