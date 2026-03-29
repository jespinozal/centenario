/**
 * @description 
 * @version 8.0 - 
 * @author      juancarlos.medinaorihuela@emeal.nttdata.com
 * @date        0
 * @see       
 */
@isTest
public class CEN_MilestonesByOwner_tst {
	
    @isTest
    public static void test1(){
        insert new Case();
        
        Case c = [SELECT Id,Status FROM Case LIMIT 1];
        c.status ='Pendiente';
        update c;
        Test.startTest();
        CEN_MilestonesByOwner_ctr.getHistory(c.Id);
        //CEN_MilestonesByOwner_ctr.getHistory2(c.Id);
        CEN_MilestonesByOwner_ctr.getCase(c.Id);
        Test.stopTest();
    }
    @isTest
    public static void test2(){
        insert new Case();
        
        Case c = [SELECT Id,Status FROM Case LIMIT 1];
        c.status ='Pendiente';
        update c;
        Test.startTest();
        try{
        CEN_MilestonesByOwner_ctr.getHistory(null);
        }catch(Exception e){
            
        }
        try{
        CEN_MilestonesByOwner_ctr.getHistory2(null);
        }catch(Exception e){
            
        }
        try{
        CEN_MilestonesByOwner_ctr.getCase(null);
        }catch(Exception e){
            
        }
       
        Test.stopTest();
    }
    @isTest
    public static void try1(){
        Test.startTest();
        try{
        CEN_MilestonesByOwner_ctr.getHistory('006RL00000GTVHSYA5');
        }catch(Exception e){
            
        }
        Test.stopTest();
    }
    @isTest
    public static void try2(){
        Test.startTest();
        try{
        CEN_MilestonesByOwner_ctr.getHistory2('006RL00000GTVHSYA5');
        }catch(Exception e){
            
        }
        Test.stopTest();
    }
    @isTest
    public static void try3(){
        insert new Case();
        Case c = [SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        try{
        CEN_MilestonesByOwner_ctr.getCase(c.Id);
        }catch(Exception e){
            
        }
        Test.stopTest();
    }
}