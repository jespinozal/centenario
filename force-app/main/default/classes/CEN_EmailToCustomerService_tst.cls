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
public class CEN_EmailToCustomerService_tst {
    
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
        
        Proyecto__c pro = new Proyecto__c();
        pro.Name ='Proyecto 1';
        pro.CEN_CODIGOSAP__c ='10U.11E';
        insert pro;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'Test Opp1';
        opp.CloseDate = System.today();
        opp.StageName='Cotización';          
        opp.CEN_Tipo_de_solicitud__c='Solicitud';
        opp.CEN_Tiene_Reserva__c='No';
        opp.CEN_Con_sustento__c='No';
        opp.CEN_Medio_Publicitario__c='Radio';
        opp.CEN_Tipo_de_venta__c='CD';
        opp.Amount=1000;
        opp.AccountId = acc.id;
        opp.CEN_Monto_cuota_de_inicial_de_precio__c = 1000;
        opp.CEN_Proyecto__c = pro.Id;
        insert opp;
        
        Date currentDay = system.today();
        CEN_PaymentOrder__c pyOrder = new CEN_PaymentOrder__c();
        pyOrder.CEN_Amount__c = 100;
        pyOrder.CEN_CurrencyCode__c = 'PEN';
        pyOrder.CEN_PaymentDescription__c = 'Test payment 1';
        pyOrder.CEN_Opportunity__c = opp.Id;
        pyOrder.CEN_CreationDateTo__c = Date.newInstance(currentDay.year(), currentDay.month(), currentDay.day()+3);
        DateTime myDateTime = DateTime.now();
        pyOrder.CEN_PaymentDate__c = myDateTime;
        insert pyOrder;
        
    }
    
    /********************************************************************* 
* @description: Método para consumo api Post. 
*********************************************************************/     
    @isTest
    public static void doSendEmailSupervisor(){
        List<Account> lstAccount = [Select id, CEN_N_mero_de_documento__pc from Account where FirstName = 'Test acc1'];
        if(lstAccount.size() > 0){
            RestRequest request = new RestRequest();
            request.requestUri ='/services/apexrest/sendEmailMessage/';
            request.httpMethod = 'POST';
            request.requestBody = Blob.valueOf('{"templateName": "CEN_WebTerrenoAdviser","documentNumber": "'+lstAccount[0].CEN_N_mero_de_documento__pc+'"}');
            RestContext.request = request;
            String resp = CEN_EmailToCustomerService_cls.doSendEmail();
            System.debug(resp);
            system.assertEquals(resp.contains('Success'), true);
        }
    }
    
    @isTest
    public static void doSendEmailSupervisorError(){
        RestRequest request = new RestRequest();
        request.requestUri ='/services/apexrest/sendEmailMessage/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('{"templateName": "CEN_WebTerrenoAdviser","documentNumber": "87654321"}');
        RestContext.request = request;
        String resp = CEN_EmailToCustomerService_cls.doSendEmail();
        System.debug(resp);
        system.assertEquals(resp.contains('Error'), true);
    }
    
    @isTest
    public static void doSendEmailCodigo(){
        List<Account> lstAccount = [Select id, CEN_Numero_de_documento_del__c from Account where Name = 'Test acc2'];
        if(lstAccount.size() > 0){
            RestRequest request = new RestRequest();
            request.requestUri ='/services/apexrest/sendEmailMessage/';
            request.httpMethod = 'POST';
            request.requestBody = Blob.valueOf('{"templateName": "CEN_WebTerrenoVerificationCode","documentNumber": "'+lstAccount[0].CEN_Numero_de_documento_del__c+'","verificationCode": "102030"}');
            RestContext.request = request;
            String resp = CEN_EmailToCustomerService_cls.doSendEmail();
            System.debug(resp);
            system.assertEquals(resp.contains('Success'), true);
        }
    }
    
    @isTest
    public static void doSendEmailCodigoError(){
        RestRequest request = new RestRequest();
        request.requestUri ='/services/apexrest/sendEmailMessage/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('{"templateName": "CEN_WebTerrenoVerificationCode","documentNumber": "87654321","verificationCode": "102030"}');
        RestContext.request = request;
        String resp = CEN_EmailToCustomerService_cls.doSendEmail();
        System.debug(resp);
        system.assertEquals(resp.contains('Error'), true);
    }
    
    @isTest
    public static void doSendEmailConfirmacion(){
        List<CEN_PaymentOrder__c> lstPaymentOrder = [Select id, Name from CEN_PaymentOrder__c where CEN_PaymentDescription__c = 'Test payment 1'];
        if(lstPaymentOrder.size() > 0){
            RestRequest request = new RestRequest();
            request.requestUri ='/services/apexrest/sendEmailMessage/';
            request.httpMethod = 'POST';
            request.requestBody = Blob.valueOf('{"templateName": "CEN_WebTerrenoConfirmation","numberOrderPayment": "'+lstPaymentOrder[0].Name+'"}');
            RestContext.request = request;
            String resp = CEN_EmailToCustomerService_cls.doSendEmail();
            System.debug(resp);
            //system.assertEquals(resp.contains('Success'), true);  
        }
    }
    
    @isTest
    public static void doSendEmailConfirmacionError(){
        RestRequest request = new RestRequest();
        request.requestUri ='/services/apexrest/sendEmailMessage/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('{"templateName": "CEN_WebTerrenoConfirmation","numberOrderPayment": "P000-123"}');
        RestContext.request = request;
        String resp = CEN_EmailToCustomerService_cls.doSendEmail();
        System.debug(resp);
        system.assertEquals(resp.contains('Error'), true); 
    }
    
    @isTest
    public static void templateError(){
        RestRequest request = new RestRequest();
        request.requestUri ='/services/apexrest/sendEmailMessage/';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf('{"templateName": "ERRORPLANTILLA","numberOrderPayment": "P000-123"}');
        RestContext.request = request;
        String resp = CEN_EmailToCustomerService_cls.doSendEmail();
        System.debug(resp);
        system.assertEquals(resp.contains('Error'), true); 
    }
    
}