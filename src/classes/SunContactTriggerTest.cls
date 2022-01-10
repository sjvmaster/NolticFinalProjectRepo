@IsTest
public with sharing class SunContactTriggerTest {
    @IsTest(SeeAllData=true)
    static void testBeforeInsertPositive() {
        // prepare data
        SunGroup__c testGroup = SunContactTriggerTestFactory.generateGroup('Group 1', 15);
        insert testGroup;
        List<SunContact__c> newContacts = SunContactTriggerTestFactory.generateContactsWithGroup(
    15, testGroup, 'Kid'
        );

        Test.startTest();
        insert newContacts;
        Test.stopTest();

        // validate
        List<SunContact__c> insertedContacts = [SELECT Id FROM SunContact__c WHERE AttendanceGroup__c = :testGroup.Id];
        System.assert(insertedContacts.size()==15);
    }

    @IsTest(SeeAllData=true)
    static void testBeforeInsertNegativeNotKid() {
        // prepare data
        SunGroup__c testGroup = SunContactTriggerTestFactory.generateGroup('Group 1', 15);
        insert testGroup;
        List<SunContact__c> newContacts = SunContactTriggerTestFactory.generateContactsWithGroup(
                13, testGroup, 'Kid'
        );
        newContacts.addAll(
            SunContactTriggerTestFactory.generateContactsWithGroup(2, testGroup, 'Parent')
        );

        Test.startTest();
        try {
            insert newContacts;
        }
        catch (DmlException e) {
            System.assert(e.getMessage().contains('Could not set or change attendance group to contact of type'));
        }
        Test.stopTest();

        // validate
        List<SunContact__c> insertedContacts = [SELECT Id FROM SunContact__c WHERE AttendanceGroup__c = :testGroup.Id];
        System.assert(insertedContacts.size()==0);
    }

    @IsTest(SeeAllData=true)
    static void testBeforeInsertNegativeExceedMaximum() {
        // prepare data
        SunGroup__c testGroup = SunContactTriggerTestFactory.generateGroup('Group 1', 15);
        insert testGroup;
        List<SunContact__c> newContacts = SunContactTriggerTestFactory.generateContactsWithGroup(
                16, testGroup, 'Kid'
        );

        Test.startTest();
        try {
            insert newContacts;
        }
        catch (DmlException e) {
            System.assert(e.getMessage().contains('Could not add or change attendance group. Maximum group size reached.'));
        }
        Test.stopTest();

        // validate
        List<SunContact__c> insertedContacts = [SELECT Id FROM SunContact__c WHERE AttendanceGroup__c = :testGroup.Id];
        System.debug(insertedContacts.size());
        System.assert(insertedContacts.size()==0);
    }

    @IsTest(SeeAllData=true)
    static void testBeforeUpdatePositive() {
        // prepare data
        SunGroup__c testGroup1 = SunContactTriggerTestFactory.generateGroup('Group 1', 15);
        SunGroup__c testGroup2 = SunContactTriggerTestFactory.generateGroup('Group 2', 30);
        insert testGroup1;
        insert testGroup2;
        List<SunContact__c> newContacts1 = SunContactTriggerTestFactory.generateContactsWithGroup(
                15, testGroup1, 'Kid'
        );
        List<SunContact__c> newContacts2 = SunContactTriggerTestFactory.generateContactsWithGroup(
                15, testGroup2, 'Kid'
        );

        insert newContacts1;
        insert newContacts2;
        SunContactTriggerTestFactory.updateGroup(newContacts1, testGroup2);

        Test.startTest();
        update newContacts1;
        Test.stopTest();

        // validate
        List<SunContact__c> updatedContacts1 = [SELECT Id FROM SunContact__c WHERE AttendanceGroup__c = :testGroup1.Id];
        List<SunContact__c> updatedContacts2 = [SELECT Id FROM SunContact__c WHERE AttendanceGroup__c = :testGroup2.Id];
        System.assert(updatedContacts1.size()==0);
        System.assert(updatedContacts2.size()==30);
    }

    @IsTest(SeeAllData=true)
    static void testBeforeUpdateNegativeExceedMaximum() {
        // prepare data
        SunGroup__c testGroup1 = SunContactTriggerTestFactory.generateGroup('Group 1', 15);
        SunGroup__c testGroup2 = SunContactTriggerTestFactory.generateGroup('Group 2', 29);
        insert testGroup1;
        insert testGroup2;
        List<SunContact__c> newContacts1 = SunContactTriggerTestFactory.generateContactsWithGroup(
                15, testGroup1, 'Kid'
        );
        List<SunContact__c> newContacts2 = SunContactTriggerTestFactory.generateContactsWithGroup(
                15, testGroup2, 'Kid'
        );

        insert newContacts1;
        insert newContacts2;
        SunContactTriggerTestFactory.updateGroup(newContacts1, testGroup2);

        Test.startTest();
        try {
            update newContacts1;
        }
        catch (DmlException e){
            System.assert(e.getMessage().contains('Could not add or change attendance group. Maximum group size reached.'));
        }
        Test.stopTest();

        // validate
        List<SunContact__c> updatedContacts1 = [SELECT Id FROM SunContact__c WHERE AttendanceGroup__c = :testGroup1.Id];
        List<SunContact__c> updatedContacts2 = [SELECT Id FROM SunContact__c WHERE AttendanceGroup__c = :testGroup2.Id];
        System.assert(updatedContacts1.size()==0);
        System.assert(updatedContacts2.size()==30);
    }

}