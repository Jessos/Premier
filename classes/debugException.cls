public class debugException extends Exception{

    public String classMethodName;
    public List<Id> errorIds ;
    public List<String> message;
    public List<ErrorWrapper> listOfErrors;
    
    
    public debugException(List<String> message, String clsName,List<Id> errIds){
        this.classMethodName = clsName;
        this.message = message;
        
    }
    
    public debugException(String clsName,List<ErrorWrapper> listOfErrors){
        this.classMethodName = clsName;
        this.listOfErrors= listOfErrors;
        
    }
    
    public class ErrorWrapper{
        public Id tseID;
        public String errMessage;
        public String recordType;
        public String combo;
    
        public ErrorWrapper(Id tseID , String errMessage,String recordType ){
            this.tseID = tseID;
            this.errMessage = errMessage;
            this.recordType = recordType;
        }
        
        public ErrorWrapper(String combo , String errMessage,String recordType ){
            this.combo = combo;
            this.errMessage = errMessage;
            this.recordType = recordType;
        }
    }
}