trigger SunContactTrigger on SunContact__c (
        before insert,
        before update,
        before delete,
        after insert,
        after update,
        after delete,
        after undelete)
{
    System.debug('Running Case trigger for :' + Trigger.operationType);
    SunContactTriggerHandler.handle(Trigger.new, Trigger.oldMap, Trigger.operationType);
}