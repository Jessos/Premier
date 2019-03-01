trigger roundrobinforcandidate on Contact (after update) {
  public string CandiUserId;
  public string FormSiteGuest; 
  public string ListRoleId;
  public string ListProfileId;
  public string CntUserId;
  public string cntmodifiedId;   
  CandiUserId = system.label.Careers_Site_Guest_User;
  FormSiteGuest= system.label.Forms_Site_Guest_UserId;
 
  if(Trigger.new[0].Division__c <> null){
    for(Contact ap : Trigger.new){
      CntUserId = ap.createdbyId;
      cntmodifiedId = ap.lastmodifiedbyId;
    }

    if (CntUserId == CandiUserId && cntmodifiedId == FormSiteGuest){
      utilforroundrobin.AssignManagerToCandidatecontact(Trigger.new);
    }
  }
}