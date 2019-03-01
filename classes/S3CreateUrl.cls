global class S3CreateUrl{

 webservice static string createSignedGetUrl(string pageId){
        String bucketName;
        String fileObjectKey;
        String AccessKey;
        String SecretKey;   
        
        
        Task_Attachment__c attachment = [select File_name__c,S3_Bucket__c from Task_Attachment__c where Id = :pageId];
        
        //AWSKeys credentials = new AWSKeys(Label.Credential_Name);
        // Reading the Custom settings to get the security credentials. 
      
        // Looping through the custom settings to collect access key and security key.
        for (S3_Archive_Settings__c ss : [select API_Key__c,Value__c from S3_Archive_Settings__c]) {
        
             If( ss.API_Key__c == 's3_public_key'){
          
                  AccessKey = ss.Value__c; 
         
             }
             
             If( ss.API_Key__c == 's3_secret_key'){
          
                  SecretKey = ss.Value__c; 
         
             }
             
        } 
                                                           
        bucketName = attachment.S3_Bucket__c;
        fileObjectKey = attachment.File_name__c;
    
        integer Duration = Integer.valueOf(Label.Duration);
        // Expiration time is measured in seconds
        Long expires = (System.currentTimeMillis() + Duration)/1000;

        //String uri = '/' + bucketName + '/' + encUri;
         String uri = '/' + bucketName + '/' + fileObjectKey;

        // See Amazon S3 documentation for details on URL signing
        // http://docs.amazonwebservices.com/AmazonS3/2006-03-01/RESTAuthentication.html
        String stringToSign = 'GET\n\n\n';
        stringToSign += String.valueOf(expires) + '\n';
        stringToSign += uri;

        //Use the built-in Crypto and EncodingUtil classes
        Blob mac = Crypto.generateMac('HMacSHA1', Blob.valueOf(stringToSign),Blob.valueOf(SecretKey));
        String macUrl = EncodingUtil.urlEncode(EncodingUtil.base64Encode(mac),'UTF-8');
        String url = 'https://s3.amazonaws.com' + uri + '?AWSAccessKeyId='+AccessKey+'&Expires=' +expires+'&Signature=' + macUrl; 
        return url;
               
 }
 
}