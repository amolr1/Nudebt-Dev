public class TaskHandler_CreateNoteForDispTask {

    // creates a Note when IsNote checkbox is set to true in a Task that is created from NuDebt Client Page Disposition Bar.
    
    public static void createNotes(List<Task> newList) {
    
        List<Note> notesToBeCreated = new List<Note>();
        List<CaseComment> CommentsToBeCreated = new List<CaseComment>();
        for (Task dispTask : newList) {
            if(dispTask.SOP__c == null){
            
                //Changes done by Uchit for Case Email reply issue: Added condition to bypass the note creation when task is related to Case
                String sObjName = '';
                if(dispTask.WhatId != null)
                    sObjName = dispTask.WhatId.getSObjectType().getDescribe().getName();
                if (String.isNotBlank(dispTask.WhatId) && !'Case'.equalsIgnoreCase(sObjName) && dispTask.IsNote__c == true) {
                    
                    Note taskNote = new Note();
                    taskNote.ParentId = dispTask.WhatId;
                    taskNote.Title = dispTask.Subject;
                    taskNote.Body = dispTask.Description;
                    notesToBeCreated.add(taskNote);
                } /*else if('Case'.equalsIgnoreCase(sObjName) && dispTask.IsNote__c == true){
                    CaseComment cm = new CaseComment();
                    cm.CommentBody = dispTask.Description;
                    cm.ParentId = dispTask.WhatId;
                    cm.IsPublished = true;
                    CommentsToBeCreated.add(cm);
                }*/
            }
            
        }
        if(!notesToBeCreated.isEmpty())
            insert notesToBeCreated;
            
        /*if(!CommentsToBeCreated.isEmpty())
            insert CommentsToBeCreated;*/
    }
}