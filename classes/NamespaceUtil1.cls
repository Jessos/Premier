/*
    Class      : NamespaceUtil  
    Purpose    : util class
    Author     : 2Cloudnine Ying Liu

    Change History 
    ******************************************************************************************************************************************
         SCRUM        ModifiedBy        Date            Requested By                           Description                              Tag
    ******************************************************************************************************************************************
        Sc- 6583      Khushboo.B       07/04/2015       Benoit Legalant           Utility method to retrieve sObject's Label           <T1>                 
*/


public with sharing class NamespaceUtil1 {

    // get Object name
    public static String getObjectName(sObject s){
        return s.getsObjectType().getDescribe().getName();
    }
    /*******************************<T1>*****************************/
    public static String getObjectLabel(sObject s) {
        return s.getsObjectType().getDescribe().getLabel();
    }
    /*******************************<T1>*****************************/
    public static Schema.SObjectField getFieldDescribe(sObject s, String fieldNameWithoutNamespace){
        String label;
        
        //get object name
        String objName = getObjectName(s);
        
        //construct field name with namespace
        String fieldNameWithNamespace = UtilClass1.Namespace + fieldNameWithoutNamespace;
        
        //get fields map
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(objName).getDescribe().fields.getMap();
        
        //search the field, with namespace first, then without namespace
        if(fieldMap.containsKey(fieldNameWithNamespace))
            return fieldMap.get(fieldNameWithNamespace);
        else
            return fieldMap.get(fieldNameWithoutNamespace);
    }
    
}