public class S3attachmentext {

   public String urlforopen { get; set; }
    public id recid { get; set; }
  


    public void openfile() {
      recid=ApexPages.CurrentPage().getParameters().get('id');
            
            if(recid<>null){
                urlforopen= S3CreateUrl.createSignedGetUrl(recid);
            }
            else{
             ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO,'Record Does not Exists!!!'));
            }
            
    }

}