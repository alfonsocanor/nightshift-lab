trigger ContactTrigger on Contact(before insert) {
    // ns:scn CN-01, CN-02, CN-03
    ContactTriggerHandler.beforeInsert(Trigger.new);
}
