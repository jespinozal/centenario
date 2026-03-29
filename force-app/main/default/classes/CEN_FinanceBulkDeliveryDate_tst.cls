/**
 * @description       : 
 * @author            : @everis.com
 * @group             : 
 * @last modified on  : 07-19-2021
 * @last modified by  : @everis.com
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   05-12-2021   @everis.com   Initial Version
**/
@isTest
public with sharing class CEN_FinanceBulkDeliveryDate_tst {

    public static String respType = '';
    @TestSetup
    static void SetUp(){

        Proyecto__c proyecto = new Proyecto__c();
        proyecto.Name = 'Proyecto X';
        proyecto.CEN_CODIGOSAP__c = '10U1.219E';
        insert proyecto;
    }

    @IsTest 
    static void getProjectData_test(){
        String proyectoId = [SELECT Id FROM Proyecto__c LIMIT 1].Id;
        Test.startTest();
        CEN_FinanceBulkDeliveryDate_ctr.getProjectData(proyectoId);
        Test.stopTest();
    }

    @IsTest 
    static void getFinancingSuccess_test(){
        Id proyectoId = [SELECT Id  FROM Proyecto__c LIMIT 1].Id;
        Test.startTest();

        Tabla_maestra__c distrito = new Tabla_maestra__c(Name='Lima', Departamento__c='Lima', Provincia__c='Lima', 
                                                         CEN_Codigo_departamento__c='15', CEN_Codigo_provincia__c='1501', CEN_Codigo_distrito__c='150105');
        insert distrito;
        Account cuenta = new Account(CEN_Tipo_de_documento__pc='DNI', CEN_N_mero_de_documento__pc='10100010002', LastName='Maximule', FirstName='Max',
                                     PersonEmail='ad@es.es', CEN_Tel_fono_Trabajo__pc='9853636', Phone='6543245',
                                     CEN_Direccion__pc='av siempre viva', CEN_Estado__c='Cuenta Potencial', 
                                     RecordTypeId='0124T0000000qqgQAA', CEN_Distrito__pc =distrito.Id);
        insert cuenta;
        try{
            Contact contacto = new Contact(LastName=cuenta.LastName, FirstName=cuenta.FirstName, AccountId=cuenta.Id, CEN_Tipo_de_documento__c=cuenta.CEN_Tipo_de_documento__pc);
        	insert contacto;
        }catch(Exception ex){
            System.debug('ex: '+ ex);
        }
        Opportunity oportunidad=new Opportunity(AccountId=cuenta.Id, StageName='Operación', CEN_Sub_Estado__c='Segura', Name='Opo 1', CloseDate=Date.today());
        insert oportunidad;
        Proyecto__c proyecto= new Proyecto__c(Name='Proyecto 1',CEN_CODIGOSAP__c='10U.11E');
        insert proyecto;
        Product2 lote = new Product2(name='Lote prueba1', CEN_Proyecto__c=proyecto.Id, CODLOTE__c='840001257', CODCOMPANIA__c='0010', 
                                     CEN_Tiene_Reserva__c='No', CODESTADOLOTE__c='L', CEN_PRECIOVENTAFUN__c='10000', IsActive=true);
        insert lote;
        PricebookEntry precio2= new PricebookEntry(UseStandardPrice=false, IsActive=true, Pricebook2Id=Test.getStandardPricebookId(), 
                                                   Product2Id=lote.Id, UnitPrice=Decimal.valueOf(lote.CEN_PRECIOVENTAFUN__c));
        insert precio2;
        OpportunityLineItem item = new OpportunityLineItem(OpportunityId=oportunidad.Id, PricebookEntryId=precio2.Id,Quantity=1, TotalPrice=precio2.UnitPrice);
        insert item;
        List<CEN_Lote_desde_Visor.Requests> request = new List<CEN_Lote_desde_Visor.Requests>();
        CEN_Lote_desde_Visor.Requests req = new CEN_Lote_desde_Visor.Requests();
        req.recorIdrequest = oportunidad.Id;
        request.add(req);
        List<CEN_Lote_desde_Visor.Result> result = CEN_Lote_desde_Visor.ObtenerIdLoteOportunidad(request);
        // CEN_Lote_desde_Visor.Result actual = result[0];
        CEN_Lote_desde_Visor.Result expected = new CEN_Lote_desde_Visor.Result();
        CEN_ResponseContentVisorLotes response = new CEN_ResponseContentVisorLotes();
        response.Codlote='840001257';
        response.Idproyecto='10U1.011E';
        response.Descripcionlote='LA PLANICIE ETAPA 2 Mz.A1 Lt.1';
        response.Manzana='A1';
        response.Codestadolote='E';
        response.Codsituacionlote='NI';
        response.Area=142.42;
        response.Precioventafun = 108438.59;
        response.FillerStr02='ESQUINA CALLE';
        expected.loteContentResponse = new List<CEN_ResponseContentVisorLotes>();
        expected.loteContentResponse.add(response);

        List<CEN_FinanceBulkDeliveryDate_ctr.BatchWrapper> resp = CEN_FinanceBulkDeliveryDate_ctr.getBatchList(proyectoId);
        CEN_FinanceBulkDeliveryDate_ctr.rWrapper respPag = CEN_FinanceBulkDeliveryDate_ctr.getBatchPagination(resp, '10', '1');
        
        Test.stopTest();
    }

    @IsTest 
    static void ModifyFinancingSuccess_test(){
        CEN_FinanceBulkDeliveryDate_ctr.BatchWrapper wrapper = new CEN_FinanceBulkDeliveryDate_ctr.BatchWrapper();
        List<CEN_FinanceBulkDeliveryDate_ctr.BatchWrapper> listWrapper = new List<CEN_FinanceBulkDeliveryDate_ctr.BatchWrapper>();
        wrapper.Id = '001';
        wrapper.Descripcionlote = 'EL HARAS ETAPA 2 Mz.A2 Lt.1';
        wrapper.Codestadolote = 'E';
        wrapper.Desestadolote = 'Entregado';
        wrapper.Codsituacionlote = '001';
        wrapper.Fecentrega = '0000-00-00';
        wrapper.Numeroletra = '1';
        wrapper.Manzana = 'A2';
        wrapper.Proforma = '0000027520';
        wrapper.CodigoSAP = '10U1.219E';
        listWrapper.add(wrapper);
        Test.startTest();
        CEN_FinanceBulkDeliveryDate_tst.respType = 'ok';
        Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
        String respFin = CEN_FinanceBulkDeliveryDate_ctr.updateDeliveryDate(listWrapper, '2022-01-05');
        Test.stopTest();
    }

    public class CEN_HttpCalloutMock_tst implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/xml');
            if (CEN_FinanceBulkDeliveryDate_tst.respType.equals('ok')) {
                String result = '<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/">';
                result += '<soap-env:Header/>';
                result += '<soap-env:Body>';
                result += '<n0:ZRFC_OTC_MODIF_DATOS_FINANC_WSResponse xmlns:n0="urn:sap-com:document:sap:rfc:functions">';
                result += '<ET_RETURN>';
                result += '<item>';
                result += '<TYPE>S</TYPE>';
                result += '<ID>ZAC_OTC</ID>';
                result += '<NUMBER>084</NUMBER>';
                result += '<MESSAGE>Se realizó correctamente la modificación de datos. Proforma: 0000026584.</MESSAGE>';
                result += '<LOG_NO/>';
                result += '<LOG_MSG_NO>000000</LOG_MSG_NO>';
                result += '<MESSAGE_V1>0000026584</MESSAGE_V1>';
                result += '<MESSAGE_V2/>';
                result += '<MESSAGE_V3/>';
                result += '<MESSAGE_V4/>';
                result += '<PARAMETER/>';
                result += '<ROW>0</ROW>';
                result += '<FIELD/>';
                result += '<SYSTEM>Q01CLNT100</SYSTEM>';
                result += '</item>';
                result += '</ET_RETURN>';
                result += '<E_OK>X</E_OK>';
                result += '</n0:ZRFC_OTC_MODIF_DATOS_FINANC_WSResponse>';
                result += '</soap-env:Body>';
                result += '</soap-env:Envelope>';
                res.setBody(result);
                res.setStatusCode(200);
            } else if (CEN_FinanceBulkDeliveryDate_tst.respType.equals('error'))  {
                String result = '<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/">';
                result += '<soap-env:Header/>';
                result += '<soap-env:Body>';
                result += '<n0:ZRFC_OTC_MODIF_DATOS_FINANC_WSResponse xmlns:n0="urn:sap-com:document:sap:rfc:functions">';
                result += '<ET_RETURN>';
                result += '<item>';
                result += '<TYPE>E</TYPE>';
                result += '<ID>ZAC_OTC</ID>';
                result += '<NUMBER>087</NUMBER>';
                result += '<MESSAGE>El estado del financiamiento: 0000026584  no es el correcto.</MESSAGE>';
                result += '<LOG_NO/>';
                result += '<LOG_MSG_NO>000000</LOG_MSG_NO>';
                result += '<MESSAGE_V1>0000026584</MESSAGE_V1>';
                result += '<MESSAGE_V2/>';
                result += '<MESSAGE_V3/>';
                result += '<MESSAGE_V4/>';
                result += '<PARAMETER/>';
                result += '<ROW>0</ROW>';
                result += '<FIELD/>';
                result += '<SYSTEM>Q01CLNT100</SYSTEM>';
                result += '</item>';
                result += '</ET_RETURN>';
                result += '<E_OK/>';
                result += '</n0:ZRFC_OTC_MODIF_DATOS_FINANC_WSResponse>';
                result += '</soap-env:Body>';
                result += '</soap-env:Envelope>';
                res.setBody(result);
                res.setStatusCode(200);
            }else{
                res.setBody('');
                res.setStatusCode(404);
            }
            return res;
        }
    } 

}