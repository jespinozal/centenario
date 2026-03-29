@isTest
public class CEN_AnulationOperationSafe_tst {
public static String respType = '';
    @TestSetup
    static void SetUp(){
        //---- PROJECTS
        Map<String,Integer> mapProj = new Map<String,Integer>();
        mapProj.put('myProj', 1);
        List<Proyecto__c> projs =  CEN_DataGenerator_Test.getProjectsDataBasic(mapProj);
        insert projs;
        
        //---- PRODUCT2
        Map<String,Integer> mapProd2 = new Map<String,Integer>();
        mapProd2.put('urbano', 1);
        List<Product2> prod2s = CEN_DataGenerator_Test.getProduct2DataBasic(mapProd2);
        prod2s[0].CEN_Proyecto__c = projs[0].Id;
        //insert prod2s ;
       
        //---- ACCOUNTS
        Map<String,Integer> mapAcc = new Map<String,Integer>();
        mapAcc.put('PersonAccount', 1);
        List<Account> accs = CEN_DataGenerator_Test.getAccountsDataBasic(mapAcc);
        insert accs;

        //---- OPPORTUNITY
        Map<String,Integer> mapOpp = new Map<String,Integer>();
        mapOpp.put('Urbano', 1);
        List<Opportunity> opps = CEN_DataGenerator_Test.getOpportunitiesDataBasic(mapOpp);
        opps[0].Pricebook2Id = Test.getStandardPricebookId();
        opps[0].CEN_devolucion_saldo_Afavor__c = true;
        opps[0].CEN_LoteEliminado__c = false;
        opps[0].stageName = 'Operación';
        insert opps;
        
        OpportunityLineItem oppItem = new OpportunityLineItem();
        oppItem.Product2Id = prod2s[0].Id;
        oppItem.OpportunityId = opps[0].Id;
        oppItem.Quantity = 1;
           //PricebookEntryId = pbEntry.Id,
        oppItem.TotalPrice = 1000;
        insert oppItem;
        // SELECT Product2Id FROM OpportunityLineItem WHERE Product2.CODESTADOLOTE__c = 'L' AND OpportunityId=:oppData.Id
        //---- PaymentOrder
        List<CEN_PaymentOrder__c> paymentOrderList = new List<CEN_PaymentOrder__c>();
        CEN_PaymentOrder__c oPaymentOrder = new CEN_PaymentOrder__c();
        oPaymentOrder.CEN_FirstName__c = 'test_FirstName';
        oPaymentOrder.CEN_PaymentDescription__c = 'pago de prueba';
        oPaymentOrder.CEN_Opportunity__c = opps[0].Id;
        oPaymentOrder.CEN_Amount__c = 5000;
        oPaymentOrder.CEN_PaymentStatus__c = 'PendienteSAP';
        oPaymentOrder.CEN_PaymentDate__c = Datetime.now();
        paymentOrderList.add(oPaymentOrder);
        insert paymentOrderList;  
    }

   @IsTest static void anulatePaymentSAPSucess_test(){
        //Test.setMock( HttpCalloutMock.class, getMultiMock(200));
        String oppId = [SELECT Id FROM Opportunity LIMIT 1].Id;
        Opportunity oppi = [SELECT Id FROM Opportunity WHERE id =: oppId LIMIT 1];
        oppi.CEN_LoteEliminado__c = false;// Opp
		update oppi;
        Test.startTest();
        CEN_AnulationOperationSafe_tst.respType = 'ok';
        Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
            //Map<String,String> response = CEN_AnulationOperationSafe_ctr.anulatePaymentSAP(oppId);
            //CEN_AnulationOperationSafe_ctr.anulatePaymentOrderProcess(opps);
            CEN_AnulationOperationSafe_ctr.anulatePaymentSAP(oppId);
        Test.stopTest();
    }
    
    @IsTest static void anulatePaymentSAPModSucess_test(){
        Test.startTest();
        
        Opportunity opp = [SELECT Id,CEN_Proforma__c,CEN_devolucion_saldo_Afavor__c FROM Opportunity LIMIT 1]; // Opp
        opp.CEN_devolucion_saldo_Afavor__c = false;
        opp.CEN_Proforma__c = '00010';
        update opp;
        List<Opportunity> opps = new List<Opportunity>{opp};
        CEN_AnulationOperationSafe_tst.respType = 'ok';
        Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
        CEN_AnulationOperationSafe_ctr.anulatePaymentOrderProcess(opps);
        Test.stopTest();
    }

    @IsTest static void anulatePaymentSAPWarning_test(){
        //Test.setMock( HttpCalloutMock.class, getMultiMock(200));
        String oppId = [SELECT Id FROM Opportunity LIMIT 1].Id; // Opp
        Test.startTest();
        CEN_AnulationOperationSafe_tst.respType = 'warning';
        Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
           // Map<String,String> response = 
        CEN_AnulationOperationSafe_ctr.anulatePaymentSAP(oppId);
        Test.stopTest();
    }

    @IsTest static void anulatePaymentSAPError_test(){
        //Test.setMock( HttpCalloutMock.class, getMultiMock(200));
        String oppId = [SELECT Id FROM Opportunity LIMIT 1].Id; // Opp
        Test.startTest();
        CEN_AnulationOperationSafe_tst.respType = 'error';
        Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
           // Map<String,String> response = 
         CEN_AnulationOperationSafe_ctr.anulatePaymentSAP(oppId);
        Test.stopTest();
    }

    public class CEN_HttpCalloutMock_tst implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
    
            res.setHeader('Content-Type', 'text/xml');
            if (CEN_AnulationOperationSafe_tst.respType.equals('ok')) {
                res.setBody('<soap-env:Envelope  xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/"><soap-env:Header/><soap-env:Body><n0:ZRFC_OTC_ANULAR_OPS_WSResponse  xmlns:n0="urn:sap-com:document:sap:rfc:functions"><ET_DOCUMENTOS><item><PROFORMA>0000057919</PROFORMA><BUKRS_PAGO>0019</BUKRS_PAGO><BELNR_PAGO>8400002737</BELNR_PAGO><GJAHR_PAGO>2023</GJAHR_PAGO><VIA_PAGO>TCRE</VIA_PAGO><BUKRS>0019</BUKRS><BELNR>8700005761</BELNR><GJAHR>2023</GJAHR><IMPORTE>500.0</IMPORTE><MONEDA>PEN</MONEDA><TIPO>ANTICIPO</TIPO></item></ET_DOCUMENTOS><ET_RETURN><item><TYPE>S</TYPE><ID>F5</ID><NUMBER>312</NUMBER><MESSAGE>Doc.8700003299 se contabilizó en sociedad 0019</MESSAGE><LOG_NO /><LOG_MSG_NO>000000</LOG_MSG_NO><MESSAGE_V1>8700003299</MESSAGE_V1><MESSAGE_V2>0019</MESSAGE_V2><MESSAGE_V3 /><MESSAGE_V4 /><PARAMETER /><ROW>0</ROW><FIELD /><SYSTEM>Q01CLNT100</SYSTEM></item><item><TYPE>S</TYPE><ID>RW</ID><NUMBER>605</NUMBER><MESSAGE>El documento se ha contabilizado correctamente: 8400000787</MESSAGE><LOG_NO /><LOG_MSG_NO>000000</LOG_MSG_NO><MESSAGE_V1>BKPFF</MESSAGE_V1><MESSAGE_V2>840000078700192021</MESSAGE_V2><MESSAGE_V3>Q01CLNT100</MESSAGE_V3><MESSAGE_V4 /><PARAMETER /><ROW>0</ROW><FIELD /><SYSTEM>Q01CLNT100</SYSTEM></item><item><TYPE>S</TYPE><ID>ZAC_B14</ID><NUMBER>126</NUMBER><MESSAGE>La anulación fue realizada con éxito</MESSAGE><LOG_NO /><LOG_MSG_NO>000000</LOG_MSG_NO><MESSAGE_V1>La anulación fue realizada con éxito</MESSAGE_V1><MESSAGE_V2 /><MESSAGE_V3 /><MESSAGE_V4 /><PARAMETER /><ROW>0</ROW><FIELD /><SYSTEM>Q01CLNT100</SYSTEM></item></ET_RETURN></n0:ZRFC_OTC_ANULAR_OPS_WSResponse></soap-env:Body></soap-env:Envelope>');
                res.setStatusCode(200);
            }else if (CEN_AnulationOperationSafe_tst.respType.equals('warning'))  {
                res.setBody('<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/"><soap-env:Header/><soap-env:Body><n0:ZRFC_OTC_ANULAR_OPS_WSResponse xmlns:n0="urn:sap-com:document:sap:rfc:functions"><ET_RETURN><item><TYPE>E</TYPE><ID>ZAC_B14</ID><NUMBER>133</NUMBER><MESSAGE>El lote tiene un estado no válido. Actualice y verifique.</MESSAGE><LOG_NO/><LOG_MSG_NO>000000</LOG_MSG_NO><MESSAGE_V1/><MESSAGE_V2/><MESSAGE_V3/><MESSAGE_V4/><PARAMETER/><ROW>0</ROW><FIELD/><SYSTEM>Q01CLNT100</SYSTEM></item></ET_RETURN></n0:ZRFC_OTC_ANULAR_OPS_WSResponse></soap-env:Body></soap-env:Envelope>');
                res.setStatusCode(200);   
            } else if (CEN_AnulationOperationSafe_tst.respType.equals('error'))  {
                res.setBody('<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/"><soap-env:Header/><soap-env:Body><n0:ZRFC_OTC_ANULAR_OPS_WSResponse xmlns:n0="urn:sap-com:document:sap:rfc:functions"><ET_RETURN><item><TYPE>E</TYPE><ID>ZAC_OTC</ID><NUMBER>053</NUMBER><MESSAGE>La OCD no se anula porque el pago no fue depositado</MESSAGE><LOG_NO/><LOG_MSG_NO>000000</LOG_MSG_NO><MESSAGE_V1/><MESSAGE_V2/><MESSAGE_V3/><MESSAGE_V4/><PARAMETER/><ROW>0</ROW><FIELD/><SYSTEM>Q01CLNT100</SYSTEM></item></ET_RETURN><E_OK/></n0:ZRFC_OTC_ANULAR_OPS_WSResponse></soap-env:Body></soap-env:Envelope>');
                res.setStatusCode(200);
            }else{
                res.setBody('');
                res.setStatusCode(404);
            }
    
            return res;
        }
    }
}