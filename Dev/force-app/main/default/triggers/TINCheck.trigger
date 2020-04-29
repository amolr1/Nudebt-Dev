trigger TINCheck on Account (before insert) {
    dupeCheck.checkforDupes(trigger.New);
}