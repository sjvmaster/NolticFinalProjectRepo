/**
 * Created by Ivan.Sokolov on 10.01.2022.
 */

public with sharing class AttendanceSheetController {
    @AuraEnabled(Cacheable=true)
    public static List<SunContact__c> getContactsByGroupId(Id groupId, String dateStr){
        Date dt = Date.valueOf(dateStr);
        return [SELECT Id, Name, (SELECT Id, ArrivalTime__c, LeavingTime__c, Superior__c FROM SunVisits__r WHERE Date__c=:dt) FROM SunContact__c WHERE AttendanceGroup__c=:groupId];
    }

    @AuraEnabled(Cacheable=true)
    public static List<SunContact__c> getParentContacts(){
        Id parentId = Schema.SObjectType.SunContact__c.getRecordTypeInfosByName().get('Parent').getRecordTypeId();
        return [SELECT Id, Name FROM SunContact__c WHERE RecordTypeId=:parentId];
    }

    @AuraEnabled
    public static void addVisit(String visitorId, String visitDate, String arrivalTime, String leavingTime, String superiorId){
        String[] arrivalTimeSplit = arrivalTime.split(':');
        String[] leavingTimeSplit = leavingTime.split(':');
        insert new SunVisit__c(
                Visitor__c=Id.valueOf(visitorId),
                Date__c=Date.valueOf(visitDate),
                ArrivalTime__c=Time.newInstance(
                        Integer.valueOf(arrivalTimeSplit[0]),
                        Integer.valueOf(arrivalTimeSplit[1]),
                        0,
                        0
                ),
                LeavingTime__c=Time.newInstance(
                        Integer.valueOf(leavingTimeSplit[0]),
                        Integer.valueOf(leavingTimeSplit[1]),
                        0,
                        0
                ),
                Superior__c=Id.valueOf(superiorId)
        );
    }
}