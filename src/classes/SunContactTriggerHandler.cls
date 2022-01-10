public with sharing class SunContactTriggerHandler {

    private static void updateAttendanceGroup(List<SunContact__c> newRecords, Map<Id, SunContact__c> oldRecordsMap){
        // Get Id's of groups for new/updated records, allow only group assignment for Kid records
        Id recordTypeIdKid = Schema.SObjectType.SunContact__c.getRecordTypeInfosByName().get('Kid').getRecordTypeId();
        Map<Id, Integer> groupsToUpdate = new Map<Id, Integer>();

        for (SunContact__c newContact: newRecords){
            if (newContact.AttendanceGroup__c != null &&
                    (oldRecordsMap == null ||
                            newContact.AttendanceGroup__c != oldRecordsMap.get(newContact.Id).AttendanceGroup__c))
            {
                System.debug(' ========== newContact.RecordTypeId ' + newContact.RecordTypeId);
                if (newContact.RecordTypeId != recordTypeIdKid){
                    newContact.addError(
                    'Could not set or change attendance group to contact of type '
                            + Schema.SObjectType.SunContact__c.getRecordTypeInfosById().get(newContact.RecordTypeId).getDeveloperName()
                    );
                }
                else{
                    if (!groupsToUpdate.containsKey(newContact.AttendanceGroup__c)) {
                        groupsToUpdate.put(newContact.AttendanceGroup__c, 1);
                    }
                    else {
                        groupsToUpdate.put(newContact.AttendanceGroup__c, groupsToUpdate.get(newContact.AttendanceGroup__c) + 1);
                    }
                }
            }
        }
        System.debug(groupsToUpdate);
        // get groups info
        Map<Id, SunGroup__c> currentGroupsSizes = new Map<Id, SunGroup__c>([
                SELECT Id, Name, MaxKidsInGroup__c, (SELECT Id FROM AttendanceGroups__r)
                FROM SunGroup__c
                WHERE Id IN :groupsToUpdate.keySet()
        ]);
        System.debug(currentGroupsSizes);

        // Check if all groups can accept the attendees
        Map<Id, Boolean> groupsCanUpdate = new Map<Id, Boolean>();
        for (Id groupId: groupsToUpdate.keySet()) {
            groupsCanUpdate.put(groupId,
                    currentGroupsSizes.get(groupId).AttendanceGroups__r.size() + groupsToUpdate.get(groupId)
                            <= currentGroupsSizes.get(groupId).MaxKidsInGroup__c);
        }

        // set errors for contacts that cannot be updated
        for (SunContact__c newContact: newRecords) {
            if (newContact.AttendanceGroup__c != null &&
                    (oldRecordsMap == null ||
                            newContact.AttendanceGroup__c != oldRecordsMap.get(newContact.Id).AttendanceGroup__c)) {
                if (newContact.RecordTypeId != recordTypeIdKid){
                    newContact.addError(
                            'Could not set or change attendance group to contact of type '
                                    + Schema.SObjectType.SunContact__c.getRecordTypeInfosById().get(newContact.RecordTypeId).getDeveloperName()
                    );
                } else {
                    if (!groupsCanUpdate.get(newContact.AttendanceGroup__c)) {
                        newContact.addError(
                        'Could not add or change attendance group. Maximum group size reached.'
                        );
                    }
                }
            }
        }
    }

    public static void handle(
            List<SunContact__c> newRecords,
            Map<Id, SunContact__c> oldRecordsMap,
            TriggerOperation operationType)
    {
        switch on operationType {
            when BEFORE_INSERT, BEFORE_UPDATE {
                updateAttendanceGroup(newRecords, oldRecordsMap);
            }
        }
    }
}