/**
 * Created by Adelaide Greenaway on 19/12/17.
 *
 * Copyright © 2017 2cloudnine Pty Ltd - Strictly Confidential.
 * Not to be distributed without authorisation
 *
 * Controller to support the 2c9 Portal Payment History Page
 *
 * The Payment History Page is accessible to the user if:
 *  - At least one Placement exists that has timesheets generated;
 * Test Class:
 */

public class Portal_PaymentHistory_Controller extends Portal_Base_Controller{
    public List<tc9_p__Pay_Advice__c> listPayAdvices {get;set;}
    public List<tc9_p__Contractor_Invoice__c> listConInvoices {get;set;}

    public List<PaymentHistoryWrapper> paymentHistoryList{get;set;}

    public Boolean paymentHistoryExists {get;set;}

    public Boolean pageTurn {get;set;}
    public List<PaymentHistoryWrapper> payHistoryToShow {get;set;}
    public integer counter = 0;
    public integer limitsize;
    public integer totalSize = 0;
    public integer totalEntry {get;set;}
    public integer firstEntry {get;set;}
    public integer lastEntry {get;set;}

    public Portal_PaymentHistory_Controller() {

        listPayAdvices = new List<tc9_p__Pay_Advice__c>();
        listConInvoices = new List<tc9_p__Contractor_Invoice__c>();
        paymentHistoryList = new List<Portal_PaymentHistory_Controller.PaymentHistoryWrapper>();

        paymentHistoryExists = false;
        pageTurn = true;


        for(tc9_p__Pay_Advice__c paygAdvice : [SELECT Id, Name, (SELECT id, Name,Contenttype FROM attachments LIMIT 1),
            tc9_p__Payment_Entity__r.Name,tc9_p__Period_Start_Date__c , tc9_p__Period_End_Date__c,tc9_p__Date_Paid__c,
            tc9_p__Gross_Earnings__c,tc9_p__Net_Earnings__c,tc9_p__Contact__c
            FROM tc9_p__Pay_Advice__c
            WHERE tc9_p__Contact__c=:contractor.Id
            ORDER BY tc9_p__Date_Paid__c DESC]){

            PaymentHistoryWrapper paygPaymentHistory =  new PaymentHistoryWrapper();
            paygPaymentHistory.payeeType='PAYG';
            paygPaymentHistory.payInvoice = paygAdvice;
            paygPaymentHistory.startDate = paygAdvice.tc9_p__Period_Start_Date__c;
            paygPaymentHistory.endDate = paygAdvice.tc9_p__Period_End_Date__c;
            paygPaymentHistory.paymentEntity = paygAdvice.tc9_p__Payment_Entity__r.Name;
            paygPaymentHistory.paidDate = paygAdvice.tc9_p__Date_Paid__c;
            paygPaymentHistory.grossEarnings = paygAdvice.tc9_p__Gross_Earnings__c;
            paygPaymentHistory.netEarnings = paygAdvice.tc9_p__Net_Earnings__c;
            if(paygAdvice.Attachments.size()>0){
                paygPaymentHistory.payAdviceAtt = paygAdvice.Attachments[0];
            }

            paymentHistoryList.add(paygPaymentHistory);
            listPayAdvices.add(paygAdvice);
        }

        for(tc9_p__Contractor_Invoice__c rctiAdvice :  [SELECT Id, Name, (SELECT id, Name, Contenttype FROM Attachments LIMIT 1),
            tc9_p__Payment_Entity__r.Name, tc9_p__Period_Start_Date__c , tc9_p__Period_End_Date__c, tc9_p__Invoice_Date__c, tc9_p__Invoice_Total_incl_GST__c, tc9_p__Total_ex_GST__c
            FROM tc9_p__Contractor_Invoice__c
            WHERE tc9_p__Contact__c=:contractor.Id ORDER BY lastModifiedDate DESC]){

            PaymentHistoryWrapper rctiPaymentHistory =  new PaymentHistoryWrapper();
            rctiPaymentHistory.payeeType='PTY LTD';
            rctiPaymentHistory.contractorInvoice = rctiAdvice;
            rctiPaymentHistory.startDate = rctiAdvice.tc9_p__Period_Start_Date__c;
            rctiPaymentHistory.endDate = rctiAdvice.tc9_p__Period_End_Date__c;
            rctiPaymentHistory.paymentEntity = rctiAdvice.tc9_p__Payment_Entity__r.Name;
            rctiPaymentHistory.paidDate = rctiAdvice.tc9_p__Invoice_Date__c;
            rctiPaymentHistory.grossEarnings = rctiAdvice.tc9_p__Total_ex_GST__c;
            rctiPaymentHistory.netEarnings = rctiAdvice.tc9_p__Invoice_Total_incl_GST__c;

            if(rctiAdvice.Attachments.size()>0){
                rctiPaymentHistory.payAdviceAtt = rctiAdvice.Attachments[0];
                system.debug('rcti Attachment: '+rctiAdvice.Attachments);
            }

            paymentHistoryList.add(rctiPaymentHistory);
            listConInvoices.add(rctiAdvice);

            system.debug('rcti PAYMENT ENTITY: '+rctiAdvice.tc9_p__Payment_Entity__r.Name);
            system.debug('rcti Attachment: '+rctiAdvice.Attachments);
        }

        if(paymentHistoryList.size()>0)
            paymentHistoryExists = true;

        system.debug('paymentHistoryList: '+paymentHistoryList);

        payHistoryToShow = new List<PaymentHistoryWrapper>();
        totalSize = paymentHistoryList.size();
        totalEntry = totalSize;
        firstEntry = 1;
        limitsize = 10;

        if((counter+limitsize) <= totalSize){
            for(Integer i=0; i<limitsize; i++){
                payHistoryToShow.add(paymentHistoryList.get(i));
            }
            lastEntry = 10;
        }else{
            for(Integer i=0; i<totalSize; i++){
                payHistoryToShow.add(paymentHistoryList.get(i));
            }
            lastEntry = totalSize;
        }

    }

    public class PaymentHistoryWrapper{
        public String payeeType{get; set;}
        public tc9_p__Pay_Advice__c payInvoice {get; set;}
        public tc9_p__Contractor_Invoice__c contractorInvoice {get; set;}
        public String paymentEntity {get;set;}
        public Date startDate {get;set;}
        public Date endDate {get;set;}
        public Date paidDate {get;set;}
        public Decimal grossEarnings {get;set;}
        public Decimal netEarnings {get;set;}
        public Attachment payAdviceAtt {get;set;}
    }

    public void next(){

        payHistoryToShow.clear();
        counter = counter+limitsize;

        pageTurn = true;
        firstEntry = lastEntry+1;

        if((counter + limitSize) <= totalSize) {
            for (Integer i = counter; i<(counter+limitSize); i++) {
                payHistoryToShow.add(paymentHistoryList.get(i));
            }
            lastEntry = (firstEntry-1) + limitSize;
        } else{
            for(Integer i=counter;i<totalSize;i++){
                payHistoryToShow.add(paymentHistoryList.get(i));
            }
            lastEntry = totalSize;
        }
    }

    public void previous(){

        payHistoryToShow.clear();
        counter = counter-limitsize;

        pageTurn = true;

        for(Integer i=counter;i<(counter+limitSize); i++){
            payHistoryToShow.add(paymentHistoryList.get(i));
        }
        firstEntry = counter+1;
        lastEntry = counter+limitSize;


    }

    public Boolean getDisableNext(){
        if((counter + limitSize) >= totalSize )
            return true ;
        else
            return false ;
    }

    public Boolean getDisablePrevious(){
        if(counter == 0)
            return true ;
        else
            return false ;
    }
}