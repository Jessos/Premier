public class CreateBillingFromPlacment
{
public static void  CreateUpdateBillling(List<ts2__Placement__c> PlacementList,Map<Id,ts2__Placement__c> PlacementListOld)
{
if(PlacementListOld==null)
{
List<Billings__c> Billinglist=new List<Billings__c>();
    for(ts2__Placement__c Placement:PlacementList)
    {
        if(Placement.ts2__Filled_By__c!=null && Placement.ClientMgrBillAmount__c!=null)
        {
        Billings__c billObj=createBilling(Placement,'Job Manager',Placement.ts2__Filled_By__c,Placement.ClientMgrBillAmount__c);
        Billinglist.add(billObj);
        }
        if(Placement.ts2__Taken_By__c!=null && Placement.ClientRef1BillAmount__c!=null)
        {
        Billings__c billObj=createBilling(Placement,'Job Referral 1',Placement.ts2__Taken_By__c,Placement.ClientRef1BillAmount__c);
        Billinglist.add(billObj);
        }
        if(Placement.ts2__Sales_Rep__c!=null && Placement.ClientRef2BillAmount__c!=null)
        {
        Billings__c billObj=createBilling(Placement,'Job Referral 2',Placement.ts2__Sales_Rep__c,Placement.ClientRef2BillAmount__c);
        Billinglist.add(billObj);
        }
        if(Placement.ts2__Filled_By_2__c!=null && Placement.PrimaryRecruiterBillAmount__c!=null)
        {
        Billings__c billObj=createBilling(Placement,'Candidate Manager',Placement.ts2__Filled_By_2__c,Placement.PrimaryRecruiterBillAmount__c);
        Billinglist.add(billObj);
        }
        if(Placement.ts2__Taken_By_2__c!=null && Placement.ReferralRec1BillAmount__c!=null)
        {
        Billings__c billObj=createBilling(Placement,'Candidate Referrel 1',Placement.ts2__Taken_By_2__c,Placement.ReferralRec1BillAmount__c);
        Billinglist.add(billObj);
        }
        if(Placement.ts2__Sales_Rep_2__c!=null && Placement.ReferralRec2BillAmount__c!=null)
        {
        Billings__c billObj=createBilling(Placement,'Candidate Referral 2',Placement.ts2__Sales_Rep_2__c,Placement.ReferralRec2BillAmount__c);
        Billinglist.add(billObj);
        }
        if(Placement.Referred_By_Name__c!=null && Placement.Referred_By_Amt__c!=null)
        {
        Billings__c billObj=createBilling(Placement,'Outside Referral',Placement.Referred_By_Name__c,Placement.Referred_By_Amt__c);
        Billinglist.add(billObj);
        }
        
    }
    insert Billinglist;
}
else if(PlacementListOld!=null)
{
    List<Billings__c> NewBillinglist=new List<Billings__c>();
    List<Billings__c> ToBeUpdateBillinglist=new List<Billings__c>();
    set<String> BillingRole=new Set<String>{'Job Manager','Candidate Manager','Job Referral 1','Job Referral 2','Candidate Referrel 1','Candidate Referral 2','Outside Referral'};
    Map<string,Billings__c> BillingMap=new Map<string,Billings__c>();
    set<Id> PlacementIdset=new Set<Id>();
    for(ts2__Placement__c Placement:PlacementList)
    {
        PlacementIdset.add(Placement.Id);
    }
    for(Billings__c Billing:[select id,Placement__c,Role__c,Billing_Credits__c,Billing_Owner__c from Billings__c where Role__c in:BillingRole and Placement__c in:PlacementIdset])
    {
    BillingMap.put(Billing.Placement__c+Billing.Role__c,Billing);
    }
    for(ts2__Placement__c Placement:PlacementList)
    {
        ts2__Placement__c oldPlacement=PlacementListOld.get(Placement.Id);
         if((oldPlacement.ts2__Filled_By__c==null && Placement.ts2__Filled_By__c!=null) && (oldPlacement.ClientMgrBillAmount__c==null && Placement.ClientMgrBillAmount__c!=null))
        {
        Billings__c billObj=createBilling(Placement,'Job Manager',Placement.ts2__Filled_By__c,Placement.ClientMgrBillAmount__c);
        NewBillinglist.add(billObj);
        }
        else if((Placement.ts2__Filled_By__c!=null) && (oldPlacement.ClientMgrBillAmount__c==null && Placement.ClientMgrBillAmount__c!=null))
        {
        Billings__c billObj=createBilling(Placement,'Job Manager',Placement.ts2__Filled_By__c,Placement.ClientMgrBillAmount__c);
        NewBillinglist.add(billObj);
        }
        else if((Placement.ts2__Filled_By__c!=oldPlacement.ts2__Filled_By__c) || (Placement.ClientMgrBillAmount__c!=oldPlacement.ClientMgrBillAmount__c))
        {
            if(BillingMap.get(oldPlacement.Id+'Job Manager')!=null)
            {
            Billings__c ExistBilling=BillingMap.get(oldPlacement.Id+'Job Manager');
            ExistBilling.Billing_Credits__c=Placement.ClientMgrBillAmount__c;           
            ExistBilling.Billing_Owner__c=Placement.ts2__Filled_By__c;
            ExistBilling.Role__c='Job Manager';
            ToBeUpdateBillinglist.add(ExistBilling);
            }
            
        }
     if((oldPlacement.ts2__Taken_By__c==null && Placement.ts2__Taken_By__c!=null) && (oldPlacement.ClientRef1BillAmount__c==null && Placement.ClientRef1BillAmount__c!=null))
        {
        Billings__c billObj=createBilling(Placement,'Job Referral 1',Placement.ts2__Taken_By__c,Placement.ClientRef1BillAmount__c);
        NewBillinglist.add(billObj);
        }
        else if((Placement.ts2__Taken_By__c!=null) && (oldPlacement.ClientRef1BillAmount__c==null && Placement.ClientRef1BillAmount__c!=null))
        {
        Billings__c billObj=createBilling(Placement,'Job Referral 1',Placement.ts2__Taken_By__c,Placement.ClientRef1BillAmount__c);
        NewBillinglist.add(billObj);
        }
     else if((Placement.ts2__Taken_By__c!=oldPlacement.ts2__Taken_By__c) || (Placement.ClientRef1BillAmount__c!=oldPlacement.ClientRef1BillAmount__c))
        {
            system.debug('BillingMap#'+BillingMap);     
            if(BillingMap.get(oldPlacement.Id+'Job Referral 1')!=null)
            {
            Billings__c ExistBilling=BillingMap.get(oldPlacement.Id+'Job Referral 1');
            system.debug('ExistBilling#'+ExistBilling);
            ExistBilling.Billing_Credits__c=Placement.ClientRef1BillAmount__c;          
            ExistBilling.Billing_Owner__c=Placement.ts2__Taken_By__c;
            ExistBilling.Role__c='Job Referral 1';
            ToBeUpdateBillinglist.add(ExistBilling);
            }
        }
        
         if((oldPlacement.ts2__Sales_Rep__c==null && Placement.ts2__Sales_Rep__c!=null) && (oldPlacement.ClientRef2BillAmount__c==null && Placement.ClientRef2BillAmount__c!=null))
        {
        Billings__c billObj=createBilling(Placement,'Job Referral 2',Placement.ts2__Sales_Rep__c,Placement.ClientRef2BillAmount__c);
        NewBillinglist.add(billObj);
        }
        else if((Placement.ts2__Sales_Rep__c!=null) && (oldPlacement.ClientRef2BillAmount__c==null && Placement.ClientRef2BillAmount__c!=null))
        {
        Billings__c billObj=createBilling(Placement,'Job Referral 2',Placement.ts2__Sales_Rep__c,Placement.ClientRef2BillAmount__c);
        NewBillinglist.add(billObj);
        }
       else if((oldPlacement.ts2__Sales_Rep__c!=null && Placement.ts2__Sales_Rep__c!=oldPlacement.ts2__Sales_Rep__c) || (Placement.ClientRef2BillAmount__c!=oldPlacement.ClientRef2BillAmount__c))
        {
           if(BillingMap.get(oldPlacement.Id+'Job Referral 2')!=null)
           {
           Billings__c ExistBilling=BillingMap.get(oldPlacement.Id+'Job Referral 2');
            ExistBilling.Billing_Credits__c=Placement.ClientRef2BillAmount__c;          
            ExistBilling.Billing_Owner__c=Placement.ts2__Sales_Rep__c;
            ExistBilling.Role__c='Job Referral 2';
            ToBeUpdateBillinglist.add(ExistBilling);
            }
        }
        if((oldPlacement.ts2__Filled_By_2__c==null && Placement.ts2__Filled_By_2__c!=null) && (oldPlacement.PrimaryRecruiterBillAmount__c==null && Placement.PrimaryRecruiterBillAmount__c!=null))
        {
        Billings__c billObj=createBilling(Placement,'Candidate Manager',Placement.ts2__Filled_By_2__c,Placement.PrimaryRecruiterBillAmount__c);
        NewBillinglist.add(billObj);
        } 
        else if((Placement.ts2__Filled_By_2__c!=null) && (oldPlacement.PrimaryRecruiterBillAmount__c==null && Placement.PrimaryRecruiterBillAmount__c!=null))
        {
        Billings__c billObj=createBilling(Placement,'Candidate Manager',Placement.ts2__Filled_By_2__c,Placement.PrimaryRecruiterBillAmount__c);
        NewBillinglist.add(billObj);
        }  
    else if((Placement.ts2__Filled_By_2__c!=oldPlacement.ts2__Filled_By_2__c) || (Placement.PrimaryRecruiterBillAmount__c!=oldPlacement.PrimaryRecruiterBillAmount__c))
        {
            if(BillingMap.get(oldPlacement.Id+'Candidate Manager')!=null)
            {
            Billings__c ExistBilling=BillingMap.get(oldPlacement.Id+'Candidate Manager');
            ExistBilling.Billing_Credits__c=Placement.PrimaryRecruiterBillAmount__c;            
            ExistBilling.Billing_Owner__c=Placement.ts2__Filled_By_2__c;
            ExistBilling.Role__c='Candidate Manager';
            ToBeUpdateBillinglist.add(ExistBilling);
            }
        }
        if((oldPlacement.ts2__Taken_By_2__c==null && Placement.ts2__Taken_By_2__c!=null) && (oldPlacement.ReferralRec1BillAmount__c==null && Placement.ReferralRec1BillAmount__c!=null))
        {
        Billings__c billObj=createBilling(Placement,'Candidate Referrel 1',Placement.ts2__Taken_By_2__c,Placement.ReferralRec1BillAmount__c);
        NewBillinglist.add(billObj);
        } 
        else if((Placement.ts2__Taken_By_2__c!=null) && (oldPlacement.ReferralRec1BillAmount__c==null && Placement.ReferralRec1BillAmount__c!=null))
        {
        Billings__c billObj=createBilling(Placement,'Candidate Referrel 1',Placement.ts2__Taken_By_2__c,Placement.ReferralRec1BillAmount__c);
        NewBillinglist.add(billObj);
        }  
       else if((oldPlacement.ts2__Taken_By_2__c!=null && Placement.ts2__Taken_By_2__c!=oldPlacement.ts2__Taken_By_2__c) || (Placement.ReferralRec1BillAmount__c!=oldPlacement.ReferralRec1BillAmount__c))
        {
            if(BillingMap.get(oldPlacement.Id+'Candidate Referrel 1')!=null)
            {
           Billings__c ExistBilling=BillingMap.get(oldPlacement.Id+'Candidate Referrel 1');
            ExistBilling.Billing_Credits__c=Placement.ReferralRec1BillAmount__c;            
            ExistBilling.Billing_Owner__c=Placement.ts2__Taken_By_2__c;
            ExistBilling.Role__c='Candidate Referrel 1';
            ToBeUpdateBillinglist.add(ExistBilling);
            }
        }
         if((oldPlacement.ts2__Sales_Rep_2__c==null && Placement.ts2__Sales_Rep_2__c!=null) && (oldPlacement.ReferralRec2BillAmount__c==null && Placement.ReferralRec2BillAmount__c!=null))
        {
        Billings__c billObj=createBilling(Placement,'Candidate Referral 2',Placement.ts2__Sales_Rep_2__c,Placement.ReferralRec2BillAmount__c);
        NewBillinglist.add(billObj);
        }   
        else if((Placement.ts2__Sales_Rep_2__c!=null) && (oldPlacement.ReferralRec2BillAmount__c==null && Placement.ReferralRec2BillAmount__c!=null))
        {
        Billings__c billObj=createBilling(Placement,'Candidate Referrel 2',Placement.ts2__Sales_Rep_2__c,Placement.ReferralRec2BillAmount__c);
        NewBillinglist.add(billObj);
        } 
       else if((Placement.ts2__Sales_Rep_2__c!=oldPlacement.ts2__Sales_Rep_2__c) || (Placement.ReferralRec2BillAmount__c!=oldPlacement.ReferralRec2BillAmount__c))
        {
            if(BillingMap.get(oldPlacement.Id+'Candidate Referral 2')!=null)
            {
            Billings__c ExistBilling=BillingMap.get(oldPlacement.Id+'Candidate Referral 2');
            ExistBilling.Billing_Credits__c=Placement.ReferralRec2BillAmount__c;            
            ExistBilling.Billing_Owner__c=Placement.ts2__Sales_Rep_2__c;
            ExistBilling.Role__c='Candidate Referral 2';
            ToBeUpdateBillinglist.add(ExistBilling);
            }
        }
        if((oldPlacement.Referred_By_Name__c==null && Placement.Referred_By_Name__c!=null) && (oldPlacement.Referred_By_Amt__c==null && Placement.Referred_By_Amt__c!=null))
        {
        Billings__c billObj=createBilling(Placement,'Outside Referral',Placement.Referred_By_Name__c,Placement.Referred_By_Amt__c);
        NewBillinglist.add(billObj);
        }
        else if((Placement.Referred_By_Name__c!=null) && (oldPlacement.Referred_By_Amt__c==null && Placement.Referred_By_Amt__c!=null))
        {
        Billings__c billObj=createBilling(Placement,'Outside Referral',Placement.Referred_By_Name__c,Placement.Referred_By_Amt__c);
        NewBillinglist.add(billObj);
        }   
        else if((Placement.Referred_By_Name__c!=oldPlacement.Referred_By_Name__c) || (Placement.Referred_By_Amt__c!=oldPlacement.Referred_By_Amt__c))
        {
            if(BillingMap.get(oldPlacement.Id+'Outside Referral')!=null)
            {
            Billings__c ExistBilling=BillingMap.get(oldPlacement.Id+'Outside Referral');
            ExistBilling.Billing_Credits__c=Placement.Referred_By_Amt__c;           
            ExistBilling.Billing_Owner__c=Placement.Referred_By_Name__c;
            ExistBilling.Role__c='Outside Referral';
            ToBeUpdateBillinglist.add(ExistBilling);
            }
        }
        
    
    }
insert NewBillinglist;
update ToBeUpdateBillinglist;
}

}

public static Billings__c createBilling(ts2__Placement__c Placment,string Roletype,Id BillingOwner,Decimal BillingAmt)
{
 system.debug('BillingOwner#'+BillingOwner);
 Id BillPlacmentRecTypeId = Billings__c.SObjectType.getDescribe().getRecordTypeInfosByName().get('Billing for this Placement').getRecordTypeId();
    Billings__c Billing=new Billings__c();
    Billing.Billing_Owner__c=BillingOwner; //Placement.ts2__Filled_By__c
    Billing.Placement__c=Placment.Id;
    //Billing.Billing_Owner_Dept__c=Placment.ts2__Department__c;
   // Billing.Billing_Owner__c= Placment.ts2__Filled_By__c;
    Billing.Role__c=Roletype;
    Billing.Billing_Credits__c=BillingAmt;
    Billing.Billing_Status__c='Not Paid';
    Billing.CurrencyIsoCode='USD';
    Billing.RecordTypeID=BillPlacmentRecTypeId;
return Billing;
}
}