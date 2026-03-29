@isTest
public with sharing class ONI_Static_Resource_tst {
    
    @isTest(SeeAllData=true)
    public static void testgetFileFromStaticResource(){
        ONI_StaticResource_cls.Request req = new ONI_StaticResource_cls.Request();
        req.resourceSize='op1';
        Test.startTest();
        ONI_StaticResource_cls.getFileFromStaticResource(new List<ONI_StaticResource_cls.Request>{req});
        Test.stopTest();
    }
}