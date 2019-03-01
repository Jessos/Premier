trigger ApplicationTrigger on ts2__Application__c (after insert/*,after Update*/) {
  public string CandiUserId;
  public string UserRoleId;
  public string ListRoleId;
  public string ListProfileId;
  public ID CntUserId;

  CandiUserId = system.label.Jobseeker_Portal_ProfileId;
  UserRoleId = system.label.CandidatesCustomerUserId;

  if(Trigger.isAfter && Trigger.isInsert)
  {    
    system.debug('Trigger.new...............'+(Trigger.new)); 
    for(ts2__Application__c ap : Trigger.new){
      System.debug('ap.createdbyId..............' + (ap.createdbyId)); 
      CntUserId = ap.createdbyId;
    }

    for(User u : [Select id,name,UserRoleId,ProfileId From User where Id =:CntUserId]){
      ListRoleId = u.UserRoleId;
      ListProfileId = u.ProfileId;
    }

    system.debug('ListRoleId ...............'+(ListRoleId)); 
    system.debug('UserRoleId............'+(UserRoleId)); 
    system.debug('ListProfileId .............'+(ListProfileId)); 
    system.debug('CandiUserId.............'+(CandiUserId)); 
    if((ListRoleId == UserRoleId) && (ListProfileId == CandiUserId)){
      //case 939
      system.debug('ListRoleId ...............'+(ListRoleId)); 
      system.debug('UserRoleId............'+(UserRoleId)); 
      system.debug('ListProfileId .............'+(ListProfileId)); 
      system.debug('CandiUserId.............'+(CandiUserId)); 
      TriggerUtil.AssignManagerToCandidate(Trigger.new);
    }
  }
}