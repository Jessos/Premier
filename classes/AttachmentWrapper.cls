public class AttachmentWrapper {

    public Id contentVersionId {get;set;}

    public Id contentDocumentId {get;set;}

    public Id attachmentId {get;set;}

    public String candidateName {get;set;}

    public String fileName {get;set;}

    public Boolean attach {get;set;}

    public String createdDateString {get;set;}

    public String jsId {get;set;}

    public Boolean remove {get;set;}

    public Id contentDocumentLinkId {get;set;}

    // this constructor is for use on the application attachment page

    public AttachmentWrapper(Id contentDocumentId, Id attachmentId, String fileName, DateTime createdDate) {

        this.contentDocumentId = contentDocumentId;

        this.attachmentId = attachmentId;

        this.fileName = fileName;

        this.attach = false;

        String dateFormatString = 'MM/dd/yyyy hh:mm aaa';

        String timeZoneString = UserInfo.getTimeZone().toString();

        this.createdDateString = createdDate.format(dateFormatString,timeZoneString);

        if(contentDocumentId != null) {this.jsId = String.valueOf(contentDocumentId);}

        else if (attachmentId != null) {this.jsId = String.valueOf(attachmentId);}

    }   

    // this constructor is for use on the submittals email page

    public AttachmentWrapper(Id contentVersionId, Id attachmentId, String candidateName, String fileName, DateTime createdDate) {

        this.contentVersionId = contentVersionId;

        this.attachmentId = attachmentId;

        this.candidateName = candidateName;

        this.fileName = fileName;

        this.attach = true;

        String dateFormatString = 'MM/dd/yyyy hh:mm aaa';

        String timeZoneString = UserInfo.getTimeZone().toString();

        this.createdDateString = createdDate.format(dateFormatString,timeZoneString);

    }

    // this constructor is for use on the FileDissociationPage

    public AttachmentWrapper(Id contentDocumentLinkId, String fileName, DateTime createdDate) {

        this.contentDocumentLinkId = contentDocumentLinkId;

        this.fileName = fileName;

        this.remove = false;

        String dateFormatString = 'MM/dd/yyyy hh:mm aaa';

        String timeZoneString = UserInfo.getTimeZone().toString();

        this.createdDateString = createdDate.format(dateFormatString,timeZoneString);

    }       

}