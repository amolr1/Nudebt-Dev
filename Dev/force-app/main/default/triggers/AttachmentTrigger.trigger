trigger AttachmentTrigger on Attachment (after insert) {

    Attorney_AttachmentHandler.pushAttachmentsToNDS();
    
}