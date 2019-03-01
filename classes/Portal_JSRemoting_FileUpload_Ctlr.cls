/**
 * Created by Adelaide Greenaway on 21/11/17.
 *
 * Copyright © 2017 2cloudnine Pty Ltd - Strictly Confidential.
 * Not to be distributed without authorisation
 *
 * JS Remoting Controller to handle all documents uploaded via the Portal, used by:
 *  - Super Details SMSF documentation
 *
 *
 * Test Class:
 */

//global with sharing class Portal_JSRemoting_FileUpload_Ctlr {
global without sharing class Portal_JSRemoting_FileUpload_Ctlr {
    @RemoteAction
    global static String doUploadAttachment(String parentId, String attachmentBody, String attachmentName, String attachmentId, String attachmentDesc) {

        String fileType = '';

        if(parentId != null) {

            if(attachmentBody != null) {
                system.debug('came inside attachmentBody');
                Attachment att;
                if(attachmentId != null)
                    att = getAttachment(attachmentId);
                else
                        att = new Attachment();
                String newBody = '';
                if(att.Body != null) {
                    newBody = EncodingUtil.base64Encode(att.Body);
                }
                Integer existlen = newBody.length();
                Integer newlen = attachmentBody.length();

                if(attachmentName.right(3) =='JPG' || attachmentName.right(3) =='jpg' || attachmentName.right(4) =='JPEG' || attachmentName.right(4) =='jpeg' ){
                    fileType = 'image/jpeg';
                    system.debug('image/jpeg');
                }

                if(attachmentName.right(3) =='GIF' || attachmentName.right(3) == 'gif'){
                    fileType = 'image/gif';
                }

                if(attachmentName.right(3) =='PDF' || attachmentName.right(3) =='pdf'){
                    fileType = 'application/pdf';
                }

                if(attachmentName.right(3) =='DOC' || attachmentName.right(3) =='doc' || attachmentName.right(4) =='DOCX' || attachmentName.right(4) =='docx'){
                    fileType = 'application/msword';
                }

                if(attachmentName.right(3) =='XLS' || attachmentName.right(3) =='xls' || attachmentName.right(4) =='XLSX' || attachmentName.right(4) =='xlsx'){
                    fileType = 'application/vnd.ms-excel';
                }

                newBody += attachmentBody;
                system.debug('newBody'+newBody);
                att.Body = EncodingUtil.base64Decode(newBody);

                //if we are uploading a new profile avatar, remove the old one first
                if(attachmentName.left(12) == 'portalAvatar'){
                    List<Attachment> portalAvatar = [
                            SELECT Id, Name, ParentId, Description
                                    FROM Attachment
                                    WHERE ParentId = :parentId
                                    AND Name LIKE 'portalAvatar%'
                    ];
                    //system.debug('111. AVATAR portalAvatar:'+portalAvatar);
                    //system.debug('111. parentId:'+parentId);
                    if(portalAvatar.size()>0) {
                        //system.debug('delete AVATAR portalAvatar:'+portalAvatar);
                        delete portalAvatar;
                    }
                }

                if(attachmentId == null) {
                    system.debug('creating new attachment');
                    att.Name = attachmentName;
                    att.Description = attachmentDesc;
                    att.parentId = parentId;
                    att.ContentType = fileType;
                }
                upsert att;
                return att.Id;
            } else {
                return 'Attachment Body was null';
            }

        } else {
            return 'Parent Id was null';
        }
    }

//    @RemoteAction
//    public static String doUploadPortalAvatar(String parentId, String attachmentBody, String attachmentName, String attachmentId, String attachmentDesc) {
//
//        String fileType = '';
//        //String attachmentName = 'portalAvatar';
//
//        if(parentId != null) {
//
//            if(attachmentBody != null) {
//                system.debug('came inside attachmentBody');
//                Attachment att;
//                if(attachmentId != null)
//                    att = getAttachment(attachmentId);
//                else
//                        att = new Attachment();
//                String newBody = '';
//                if(att.Body != null) {
//                    newBody = EncodingUtil.base64Encode(att.Body);
//                }
//                Integer existlen = newBody.length();
//                Integer newlen = attachmentBody.length();
//
//                if(attachmentName.right(3) =='JPG' || attachmentName.right(3) =='jpg' || attachmentName.right(3) =='JPEG' || attachmentName.right(3) =='jpeg' ){
//                    fileType = 'image/jpeg';
//                }
//
//                if(attachmentName.right(3) =='GIF' ){
//                    fileType = 'image/gif';
//                }
//
//                if(attachmentName.right(3) =='PDF' || attachmentName.right(3) =='pdf'){
//                    fileType = 'application/pdf';
//                }
//
//                if(attachmentName.right(3) =='DOC' || attachmentName.right(3) =='doc' || attachmentName.right(3) =='DOCX' || attachmentName.right(3) =='docx'){
//                    fileType = 'application/msword';
//                }
//
//                if(attachmentName.right(3) =='XLS' || attachmentName.right(3) =='xls' || attachmentName.right(3) =='XLSX' || attachmentName.right(3) =='xlsx'){
//                    fileType = 'application/vnd.ms-excel';
//                }
//
//                newBody += attachmentBody;
//                system.debug('newBody'+newBody);
//                att.Body = EncodingUtil.base64Decode(newBody);
//
//                if(attachmentId == null && (fileType == 'image/gif' || fileType =='image/jpeg' )) {
//                    att.Name = attachmentName;
//                    att.Description = 'profile photo for the Employee Portal';
//                    att.parentId = parentId;
//                    att.ContentType = fileType;
//                }
//                upsert att;
//                return att.Id;
//            } else {
//                return 'cannot upload this file as a portal avator, please try again with a jpg/jpeg or gif file';
//            }
//
//        } else {
//            return 'Parent Id was null';
//        }
//    }

    private static Attachment getAttachment(String attId) {
        list<Attachment> attachments = [SELECT Id, Body, Description
                FROM Attachment
                WHERE Id =: attId];
        if(attachments.isEmpty()) {
            Attachment a = new Attachment();
            return a;
        } else {
            return attachments[0];
        }
    }
}