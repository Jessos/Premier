trigger UpdateOwner on ts2__Job__c (before insert,before update) 
{
system.debug('**Hi*');
for(ts2__Job__c job:trigger.new)
{
if(trigger.isInsert)
{
    if(job.ts2__Recruiter__c!=null)
    {
    system.debug('******Job Manager****'+job.Job_Candidate_Manager__c);
    job.ownerId=job.ts2__Recruiter__c;
    }

}
if(trigger.isUpdate)
{
    if(trigger.oldmap.get(job.id).ts2__Recruiter__c!=job.ts2__Recruiter__c && job.ts2__Recruiter__c !=null )
    {
    job.ownerId=job.ts2__Recruiter__c;
    }

}

}

}