global class Placement implements comparable{
        public String Customer ='' ;
        public id PlacementId ;
        
        public String ClassRef ='' ;
        public String ToBePrinted ='' ;
        public String BillToLine1 ='' ;
        public String BillToLine2 ='' ;
        public String BillToLine3 ='' ;
        public String BillToLine4 ='' ;
        public String BillToCity ='' ;
        public String BillToState ='' ;
        public String BillToPostalCode ='' ;
        public String BillToCountry ='' ;
        public String Item ='' ;
        public Decimal Quantity =0.0 ;
        public String Description ='' ;
        public Decimal Price =0.0 ;
        public String ItemLineClass ='' ;
        public String ToBeEMailed ='' ;
        public String TempService ='' ;
        public String PONumber ='' ;
        public String RefNumber = '';
    	public String ServiceDate = '';
        public Placement(id PlaceId,String CustomerN,String BillToLine1N,String ToBePrintedN,String itemN,Decimal QuantityN,String DescriptionN,Decimal PriceN,String ToBeEMailedN,String BillToCityN,String BillToStateN,String BillToPostalCodeN,String BillToCountryN,String BillingStreetN,String BillToLine2N,String BillToLine2Actual, String ClassRefN, String PONumberN, String RefNumberN , String dept){
            Customer= CustomerN;    
            Quantity= QuantityN;
            BillToLine1=BillToLine1N;
            ToBePrinted=ToBePrintedN;
            item=itemN;
            PlacementId=PlaceId;
            Description=DescriptionN;
            Price= PriceN;
            ToBeEMailed=ToBeEMailedN;
            
            if(dept == null)
            	TempService = 'Temp Service';
            else if(dept == 'East Bay')
            	TempService = 'East Bay Temp Service';
            else if (dept == 'Peninsula')
            	TempService = 'Peninsula Service';
			else 
            	TempService = 'Temp Service';

            if(BillToCityN != null)
            BillToCity=BillToCityN;
            else
            BillToCity = '';
            
            if(BillToStateN != null)
            BillToState=BillToStateN;
            else
            BillToState = '';
            
            if(BillToPostalCodeN != null)
            BillToPostalCode=BillToPostalCodeN;
            else
            BillToPostalCode = '';
            
            if(BillToCountryN != null)
            BillToCountry=BillToCountryN;
            else
            BillToCountry = '';
            BillToLine2 = (BillToLine2Actual == null ? '' : BillToLine2Actual);
            BillToLine3 = (BillToLine2N == null ? '' : BillToLine2N);
            BillToLine4 = (BillingStreetN == null ? '' : BillingStreetN);
            
            ClassRef = ClassRefN;
            
            if(PONumberN != null)
              PONumber=PONumberN;
            else
              PONumber=' ';
            if(RefNumberN != null)
              RefNumber = RefNumberN;
            else
              RefNumber = '';
            
            ServiceDate = getServiceDate(dept);
        }
        global Integer compareTo(Object objToCompare){
        	Placement plc2 = (Placement) objToCompare;
        	//sort by Customer asc, RefNumber asc
        	if(Customer.compareTo(plc2.Customer) != 0)
        		return Customer.compareTo(plc2.Customer);
        	else
        		return RefNumber.compareTo(plc2.RefNumber); //SC-2319. Note that previously sorted by Description asc, Item desc
        }
    
    private String getServiceDate(String dept){
        String result = '';
        if(String.isBlank(dept.trim())){
            return result;
        }else if(dept.equals('Silicon Valley Contract/Temp')){
            result = 'Contract Team:SV Contract Team';            
        }else if(dept.equals('East Bay Contract/Temp')){
            result = 'Contract Team:EB Contract Team';
        }else if(dept.equals('San Francisco Contract/Temp')){
            result = 'Contract Team:SF Contract Team';
        }else if(dept.equals('New York Contract/Temp')){
            result = 'Contract Team:NY Contract Team';
        }
        return result;
    }   
}