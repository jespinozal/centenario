/********************************************************************* 
* @author: Alan Alvarez (aalvarpe@everis.com) 
* @date: 2021-04-22 
* @description: Clase Test que instancia clase Api de CEN_AccountAPI. 
* 
* VERSION      DATE                 AUTOR                   ACTION 
* 0.1          2021-04-22           Alan Alvarez            Creación 
*  
*********************************************************************/
@isTest
public class CEN_AccountService_tst {
    
    @testSetup
    public static void setup(){
        
        Account acc = new Account();
        acc.FirstName = 'Test acc1';
        acc.LastName = 'Apellido acc1';
        acc.PersonEmail = 'acc1@tst.com';
        acc.PersonMobilePhone = '987654321';
        acc.CEN_N_mero_de_documento__pc = '12345678';
        insert acc;
        
        Account acc2 = new Account();
        acc2.Name = 'Test acc2';
        acc2.CEN_fld_Correo_empresa__c = 'acc2@tst.com';
        acc2.Phone = '999888777';
        acc2.CEN_Numero_de_documento_del__c = '10203040501';
        insert acc2;
        
    }
    
    /********************************************************************* 
* @description: Método para consumo api Get. 
*********************************************************************/
    
    @isTest
    public static void CallApiGetPerson(){
        RestRequest request = new RestRequest();
        request.requestUri ='/services/apexrest/account/12345678';
        request.httpMethod = 'GET';
        RestContext.request = request;
        List<CEN_AccountService_cls.accountresp> lstAccount = CEN_AccountService_cls.doGet();
        system.assert(lstAccount.size() > 0);  
    }
    
    @isTest
    public static void CallApiGetCompany(){
        RestRequest request = new RestRequest();
        request.requestUri ='/services/apexrest/account/10203040501';
        request.httpMethod = 'GET';
        RestContext.request = request;
        List<CEN_AccountService_cls.accountresp> lstAccount = CEN_AccountService_cls.doGet();
        system.assert(lstAccount.size() > 0);  
    }
    
}