/*
	Author  : 2C9
	Purpose	: General utility methods
*/
public with sharing class UtilClass {
	// get all record type for the sObjectType
	public static Map <String, Id> getRecordTypeMap(String sObjectType){
        Map <String, Id> RecordTypeMap = new Map <String, Id>(); // stores the name and id for the Object type

        List<RecordType> rlist = [Select Id, Name from RecordType where SobjectType =: sObjectType ];
        for (RecordType a : rlist){
            RecordTypeMap.put(a.name, a.id);
        }
        
        return RecordTypeMap;
    }

	// get record type Id for the sObjectType, and RecordTypeName
	public static Id getRecordTypeId(String sObjType, String RecordTypeName){
        
        List<RecordType> a = [Select Id from RecordType where SobjectType =: sObjType and  Name =: RecordTypeName ];
        if (a != null && a.size() > 0){
            return a[0].Id;
        }
        return null;
    }
	
	public Boolean isValidId(String s) {
	    Id validId;
	    try {
	       validId = s;
	       return true; 
	    } 
	    catch (Exception ex) {
	        return false;
	    }
	}
	
}