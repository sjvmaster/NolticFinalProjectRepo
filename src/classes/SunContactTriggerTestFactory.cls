public with sharing class SunContactTriggerTestFactory {
    public static List<SunContact__c> generateContactsWithGroup(Integer numCases, SunGroup__c newGroup, String recordTypeStr){
        Id recordTypeId = Schema.SObjectType.SunContact__c.getRecordTypeInfosByName().get(recordTypeStr).getRecordTypeId();
        List<SunContact__c> contacts = new List<SunContact__c>();
        for (Integer i=0; i<numCases; i++){
            contacts.add(
                new SunContact__c(
                    Name='Test' + i,
                    RecordTypeId=recordTypeId,
                    AttendanceGroup__c = newGroup.Id
                )
            );
        }
        return contacts;
    }

    public static SunGroup__c generateGroup(String groupName, Integer maxKids){
        SunGroup__c newGroup = new SunGroup__c(
            Name='TestGroup',
            MaxKidsInGroup__c=maxKids
        );
        return newGroup;
    }

    public static void updateGroup(List<SunContact__c> contacts, SunGroup__c newGroup){
        for (SunContact__c c:contacts){
            c.AttendanceGroup__c = newGroup.Id;
        }
    }
}