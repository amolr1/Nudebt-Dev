public class TaskHandler_CreateNoteForDispTask {

    // creates a Note when IsNote checkbox is set to true in a Task that is created from NuDebt Client Page Disposition Bar.
    
    public static void createNotes(List<Task> newList) {
    
        List<Note> notesToBeCreated = new List<Note>();
        
        for (Task dispTask : newList) {
        
            if (String.isNotBlank(dispTask.WhatId) && dispTask.IsNote__c == true) {
            
                Note taskNote = new Note();
                taskNote.ParentId = dispTask.WhatId;
                taskNote.Title = dispTask.Subject;
                taskNote.Body = dispTask.Description;
                notesToBeCreated.add(taskNote);
            }
        }
        insert notesToBeCreated;
    }
}