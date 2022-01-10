public with sharing class SampleDataGenerator {

    public static void GenerateSampleData(){
        List<SunGroup__c> groups = generateGroups(false);
        List<SunContact__c> teachers = generateTeachers(groups, false);
        List<SunContact__c> parents = generateParents(false);
        List<SunContact__c> kids = generateKids(parents, groups, true);
    }

    public static List<SunGroup__c> generateGroups(Boolean generateNew) {
        List<String> groupNames = new List<String>{
                '1A',
                '1B'
        };
        List<SunGroup__c> groups = new List<SunGroup__c>();
        if (generateNew) {
            for (String name : groupNames) {
                groups.add(new SunGroup__c(
                        Name = name
                ));
            }
            insert groups;
        }
        else{
            groups = [SELECT Id FROM SunGroup__c WHERE Name IN :groupNames];
        }
        return groups;
    }

    public static List<SunContact__c> generateTeachers(List<SunGroup__c> groups, Boolean generateNew) {
        Id recordTypeIdTeacher = Schema.SObjectType.SunContact__c.getRecordTypeInfosByName().get('Teacher').getRecordTypeId();
        List<String> teacherNames = new List<String> {
                'Good Teacher',
                'Best Teacher'
        };
        List<SunContact__c> teachers = new List<SunContact__c>();
        if (generateNew) {
            Integer index = 0;
            for (String name:teacherNames) {
                teachers.add(new SunContact__c(
                        Name=name,
                        RecordTypeId=recordTypeIdTeacher,
                        AssignedGroup__c=groups[index].Id)
                );
                index++;
            }
            insert teachers;
        }
        else {
            teachers = [SELECT Id FROM SunContact__c WHERE RecordTypeId=:recordTypeIdTeacher AND Name IN :teacherNames];
        }
        return teachers;
    }

    public static List<SunContact__c> generateParents(Boolean generateNew) {
        Id recordTypeIdParent = Schema.SObjectType.SunContact__c.getRecordTypeInfosByName().get('Parent').getRecordTypeId();
        List<String> parentNames = new List<String> {
                'Angela Smith',
                'John Smith',
                'Cornelius Anderson',
                'Michael Peterson'
        };
        List<SunContact__c> parents = new List<SunContact__c>();
        if (generateNew) {
            for (String name : parentNames) {
                parents.add(new SunContact__c(
                        Name = name,
                        RecordTypeId = recordTypeIdParent,
                        Email__c = name.replace(' ', '.') + '@testfakemail.com')
                );
            }
            insert parents;
        }
        else {
            parents = [SELECT Id FROM SunContact__c WHERE RecordTypeId=:recordTypeIdParent AND Name IN :parentNames];
        }
        return parents;
    }

    public static List<SunContact__c> generateKids(List<SunContact__c> parents, List<SunGroup__c> groups, Boolean generateNew){
        Id recordTypeIdParent = Schema.SObjectType.SunContact__c.getRecordTypeInfosByName().get('Parent').getRecordTypeId();
        Id recordTypeIdKid = Schema.SObjectType.SunContact__c.getRecordTypeInfosByName().get('Kid').getRecordTypeId();
        List<String> kidNames = new List<String> {
                'Mark Smith',
                'Anna Smith',
                'Jillian Anderson',
                'Timothy Anderson',
                'Jim Peterson',
                'Jack Peterson',
                'Jeremy Peterson'
        };
        List<SunContact__c> kids = new List<SunContact__c>();
        if (generateNew) {
            Integer index = 0;
            for (String name : kidNames) {
                String likeLastName = '%' + name.split(' ')[1];
                List<SunContact__c> kidsParents = [SELECT Id FROM SunContact__c WHERE RecordTypeId = :recordTypeIdParent AND Name LIKE :likeLastName];
                System.debug('kidsParents: '+ kidsParents);
                SunContact__c kid = null;
                if (kidsParents.size() == 1) {
                    kid = new SunContact__c(
                            Name = name,
                            RecordTypeId = recordTypeIdKid,
                            PrimaryParent__c = kidsParents[0].Id
                    );
                } else if (kidsParents.size() > 1) {
                    kid = new SunContact__c(
                            Name = name,
                            RecordTypeId = recordTypeIdKid,
                            PrimaryParent__c = kidsParents[0].Id,
                            SecondaryParent__c = kidsParents[1].Id
                    );
                } else {
                    System.debug('no parents for: ' + likeLastName);
                }
                if (index <= 4) {
                    kid.AttendanceGroup__c = groups[0].Id;
                } else {
                    kid.AttendanceGroup__c = groups[1].Id;
                }
                kids.add(kid);
                index++;
            }
            insert kids;
        }
        else {
            kids = [SELECT Id FROM SunContact__c WHERE RecordTypeId=:recordTypeIdKid AND Name IN :kidNames];
        }
        System.debug(kids);
        return kids;
    }
}