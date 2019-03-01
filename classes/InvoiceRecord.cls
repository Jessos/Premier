public with sharing class InvoiceRecord implements Comparable{
    
    Id candidateId;
    Id plcId;
    Id jobId;
    public Id conInvoiceId;
    public Id invItemId;
    public String candidateName{get;set;}
    public String candidateFullName{get;set;}
    public String jobName{get;set;}
    public String description {get;set;} 
    public String PONumber{get;set;}
    public Decimal totalBillExTax{get;set;}
    public Decimal totalTax{get;set;}
    public Decimal totalBillIncTax{get;set;}
    public Boolean showInvoiceDetails {get;set;}
    public Decimal totalRateDiscAmt{get;set;}
    Map<String, InvoiceItemByPaycode> invItemsMap;//group invoice items by paycode & store in map
    /*
    public InvoiceRecord(tc9_ti__InvoiceItem__c invItem,tc9_ti__Consolidated_Invoice__c conInvoice) {
        this.conInvoiceId   = conInvoice.Id;
        this.invItemId      = invItem.Id;
        this.jobId          = invItem.tc9_ti__Fee__r.tc9_ti__Job_Order__c;
        this.jobName        = invItem.tc9_ti__Fee__r.tc9_ti__Job_Order__r.Name;
        this.description    = invItem.tc9_ti__Description__c;
        this.PONumber       = conInvoice.tc9_ti__PurchaseOrderNumber__c != null ? conInvoice.tc9_ti__PurchaseOrderNumber__c : '';
        this.totalBillExTax = 0;
        this.totalTax       = 0;
        this.totalBillIncTax= 0;
        this.totalRateDiscAmt = 0;
        this.addFeeInvoiceItem(invItem);        
    }*/
    public InvoiceRecord(tc9_ti__InvoiceItem__c invItem, tc9_ti__Invoice__c invoice,tc9_ti__Consolidated_Invoice__c conInvoice){
        this.conInvoiceId   = conInvoice.Id;
        this.plcId          = invoice.tc9_ti__Placement__c;
        this.candidateId    = invoice.tc9_ti__Placement__r.ts2__Employee__c;
        this.invItemId      = invItem.Id;
        String firstName    = invoice.tc9_ti__Placement__r.ts2__Employee__r.FirstName;
        this.candidateName  = invoice.tc9_ti__Placement__r.ts2__Employee__r.LastName + (firstName == null ? '' : ', '+firstName) ;
        this.candidateFullName= (firstName == null ? '' : firstName + ' ') + invoice.tc9_ti__Placement__r.ts2__Employee__r.LastName;
        this.jobId          = invoice.tc9_ti__Placement__r.ts2__Job__c;
        this.jobName        = invoice.tc9_ti__Placement__r.ts2__Job__r.Name;
        this.description    = invItem.tc9_ti__Description__c;
        this.PONumber       = invoice.tc9_ti__PurchaseOrderNumber__c != null ? invoice.tc9_ti__PurchaseOrderNumber__c :'';
        this.invItemsMap    = new Map<String, InvoiceItemByPaycode>();
        this.totalBillExTax = 0;
        this.totalTax       = 0;
        this.totalBillIncTax= 0;
        this.totalRateDiscAmt = 0;
        this.addInvoiceItem(invItem);
        system.debug('PPPPPP '+this.description);
    }
    
    public InvoiceRecord(InvoiceRecord copyInvoice){
        this.plcId = copyInvoice.plcId;
        this.candidateId = copyInvoice.candidateId;
        this.candidateName = copyInvoice.candidateName;
        this.candidateFullName = copyInvoice.candidateFullName;
        this.jobId = copyInvoice.jobId;
        this.jobName = copyInvoice.jobName;
        this.description = copyInvoice.description;
        this.PONumber = copyInvoice.PONumber;
        this.totalBillExTax = copyInvoice.totalBillExTax;
        this.totalTax = copyInvoice.totalTax;
        this.totalBillIncTax = copyInvoice.totalBillIncTax;
        this.totalRateDiscAmt = copyInvoice.totalRateDiscAmt;
        this.invItemsMap    = new Map<String, InvoiceItemByPaycode>();
    }
    
    public boolean isMapEmpty(){
        return invItemsMap.isEmpty();
    }
    
    public void clearMap(){
        invItemsMap.clear();
    }
    
    public void addToMap(String key, InvoiceItemByPaycode invItem){
        if(invItemsMap == null)
            invItemsMap = new Map<String, InvoiceItemByPaycode>();
        invItemsMap.put(key, invItem);
    }
    
    public void addFeeInvoiceItem(tc9_ti__InvoiceItem__c invItem) {
        this.totalBillExTax = (this.totalBillExTax + invItem.tc9_ti__TotalBillExTax__c);
        this.totalTax       = (this.totalTax + invItem.tc9_ti__TotalTax__c);
        this.totalBillIncTax= (this.totalBillIncTax + invItem.tc9_ti__TotalBillIncTax__c);
        this.totalRateDiscAmt= (this.totalRateDiscAmt + invItem.Pre_Discount_Amount__c);

    }
    
    //add new invoice item
    public void addInvoiceItem(tc9_ti__InvoiceItem__c invItem){
        
        String grpString = invItem.tc9_ti__Paycode__c + '-' + invItem.tc9_ti__Multiplied_Bill_Rate1__c + '-' + invItem.tc9_ti__Week_End_Date__c;
        if(invItem.tc9_ti__Invoice__r.tc9_ti__Placement__r.ts2__Job__r.ts2__Account__r.tc9_ti__Group_By_Project_Code__c) {
            grpString += '-' +invItem.tc9_ti__Time_Sheet_Entry__r.tc9_ti__Project_Code__c;
        }
        if(invItemsMap.containsKey(grpString))
            invItemsMap.get(grpString).addInvoiceItem(invItem);
        else
            invItemsMap.put(grpString, new InvoiceItemByPaycode(invItem));
        system.debug('mappppp '+invItemsMap);
        this.totalBillExTax = (this.totalBillExTax + invItem.tc9_ti__TotalBillExTax__c);
        this.totalTax       = (this.totalTax + invItem.tc9_ti__TotalTax__c);
        this.totalBillIncTax= (this.totalBillIncTax + invItem.tc9_ti__TotalBillIncTax__c);
        this.totalRateDiscAmt= (this.totalRateDiscAmt + (invItem.Pre_Discount_Amount__c!=null?invItem.Pre_Discount_Amount__c:0));

    }
    
    //return the first item from the list
    public InvoiceItemByPaycode getFirstInvoiceItem(){
        List<InvoiceItemByPaycode> invItems = invItemsMap.values();
        if(invItems.isEmpty())
            return null;
        invItems.sort();
        Date previousDate = null;
        for(InvoiceItemByPaycode item : invItems){
            if(item.invItem.tc9_ti__Week_End_Date__c != previousDate)
                item.showWeekEndDate = true;
            previousDate = item.invItem.tc9_ti__Week_End_Date__c;
        }
        return invItems[0];
    }
    
    //return the other items (removing the first one)
    public List<InvoiceItemByPaycode> getFollowingInvoiceItems(){
        List<InvoiceItemByPaycode> invItems = invItemsMap.values();
        if(invItems.size() == 1)
            return new List<InvoiceItemByPaycode>();
        invItems.sort();
        invItems.remove(0);
        return invItems;
    }
    
    //sort based on the candidate and job order
    public Integer compareTo(Object obj){
        InvoiceRecord invRecord = (InvoiceRecord) obj;
        if(this.candidateName > invRecord.candidateName)
            return 1;
        else if(this.candidateName < invRecord.candidateName)
            return -1;
        
        if(this.PONumber != null && invRecord.PONumber != null){
            if(this.PONumber > invRecord.PONumber)
                return 1;
            else if(this.PONumber < invRecord.PONumber)
                return -1;
        }
            
        if(this.jobName > invRecord.jobName)
            return 1;
        else if(this.jobName < invRecord.jobName)
            return -1;
            
        return 0;
    }
    
    /*** inner class to hold invoice items grouped by paycodes ***/
    public class InvoiceItemByPaycode implements Comparable{
        
        public String paycode{get;set;}
        public tc9_ti__InvoiceItem__c invItem{get;set;}
        public boolean showWeekEndDate {get;set;}
        public boolean expenseDesc{get;set;}
        public string projectCode {get;set;}
       public Decimal invItemPreDescAmt {get;set;}
       public Decimal invItemPreDescRate {get;set;}
        public Integer compareTo(Object obj){
            InvoiceItemByPaycode otherObj = (InvoiceItemByPaycode) obj;
            if(this.invItem.tc9_ti__Week_End_Date__c != null && otherObj.invItem.tc9_ti__Week_End_Date__c != null){
                if(this.invItem.tc9_ti__Week_End_Date__c > otherObj.invItem.tc9_ti__Week_End_Date__c)
                    return 1;
                else if(this.invItem.tc9_ti__Week_End_Date__c < otherObj.invItem.tc9_ti__Week_End_Date__c)
                    return -1;
            }
            else if(this.invItem.tc9_ti__Week_End_Date__c == null && otherObj.invItem.tc9_ti__Week_End_Date__c == null){
            }
            else if(this.invItem.tc9_ti__Week_End_Date__c == null || otherObj.invItem.tc9_ti__Week_End_Date__c == null){
                if(otherObj.invItem.tc9_ti__Week_End_Date__c == null)
                    return -1;
                if(this.invItem.tc9_ti__Week_End_Date__c == null)
                    return 1;
            }
            if(this.invItem.tc9_ti__Paycode_Sort_Order__c > otherObj.invItem.tc9_ti__Paycode_Sort_Order__c){
                
                return 1;
            }
            else if(this.invItem.tc9_ti__Paycode_Sort_Order__c < otherObj.invItem.tc9_ti__Paycode_Sort_Order__c){
                
                return -1;
            }    
            return 0;
        }
        
        //constructor
        public InvoiceItemByPaycode(tc9_ti__InvoiceItem__c invItem){
            this.expenseDesc=false;
            this.invItem                    = new tc9_ti__InvoiceItem__c();
            this.invItem.tc9_ti__Week_End_Date__c   = invItem.tc9_ti__Week_End_Date__c;
            this.invItem.tc9_ti__Paycode__c         = invItem.tc9_ti__Paycode__c;
            this.invItem.CurrencyIsoCode    = invItem.CurrencyIsoCode;
            
            this.invItem.tc9_ti__Description__c     = invItem.tc9_ti__Description__c ; 
            this.invItem.tc9_ti__Paycode_Sort_Order__c      = invitem.tc9_ti__Paycode_Sort_Order__c;
            this.invItem.tc9_ti__BillRate__c        = invItem.tc9_ti__Multiplied_Bill_Rate1__c;
            this.invItem.tc9_ti__Quantity__c        = this.invItem.tc9_ti__TotalBillExTax__c = this.invItem.tc9_ti__TotalTax__c = this.invItem.tc9_ti__TotalBillIncTax__c  =0;
            this.invItem.tc9_ti__Time_Sheet_Entry__c = invItem.tc9_ti__Time_Sheet_Entry__c;
            this.projectCode                = invItem.tc9_ti__Time_sheet_Entry__r.tc9_ti__Project_Code__r.Name;
            this.addInvoiceItem(invItem);
            this.showWeekEndDate            = false;           
        }
        
        //add invoice item with the same paycode
        public void addInvoiceItem(tc9_ti__InvoiceItem__c invItem){
            this.invItem.tc9_ti__Quantity__c            = ((this.invItem.tc9_ti__Quantity__c!=null?this.invItem.tc9_ti__Quantity__c:0)  + (invItem.tc9_ti__Quantity__c!=null?invItem.tc9_ti__Quantity__c:0));
            this.invItem.tc9_ti__TotalBillExTax__c      = ((this.invItem.tc9_ti__TotalBillExTax__c!=0?this.invItem.tc9_ti__TotalBillExTax__c:0)   + (invItem.tc9_ti__TotalBillExTax__c!=null?invItem.tc9_ti__TotalBillExTax__c:0));
            this.invItem.tc9_ti__TotalTax__c            = ((this.invItem.tc9_ti__TotalTax__c!=0?this.invItem.tc9_ti__TotalTax__c:0)         + (invItem.tc9_ti__TotalTax__c!=0?invItem.tc9_ti__TotalTax__c:0));
            this.invItem.tc9_ti__TotalBillIncTax__c     = ((this.invItem.tc9_ti__TotalBillIncTax__c!=0?this.invItem.tc9_ti__TotalBillIncTax__c:0)  + (invItem.tc9_ti__TotalBillIncTax__c!=0?invItem.tc9_ti__TotalBillIncTax__c:0));
            System.debug('this.invItem.Pre_Discount_Amount__c=='+invItem.Pre_Discount_Amount__c);
            this.invItemPreDescAmt  = invItem.Pre_Discount_Amount__c;
            this.invItemPreDescRate  = invItem.Pre_Discount_Rate__c;

            //this.invItem.Pre_Discount_Amount__c         = (this.invItem.Pre_Discount_Amount__c );
        }
    }
}