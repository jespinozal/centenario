/**
 * @description       : Clase test que lista camapañas por codigo de proyecto
 * @author            : Joel Espinoza
 * @group             :
 * @last modified on  : 21-03-2023
 * @last modified by  : Joel Espinoza
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   21-03-2023   Joel Espinoza   Initial Version
 **/
@IsTest
public with sharing class CEN_Campana_Test {

    public static String respType = '';

    @TestSetup
	static void setUp(){
        //---- ACCOUNTS
        Map<String,Integer> mapAcc = new Map<String,Integer>();
        mapAcc.put('PersonAccount', 1);
        List<Account> accs = CEN_DataGenerator_Test.getAccountsDataBasic(mapAcc);
        insert accs;

        //---- PROJECTS
        Map<String,Integer> mapProj = new Map<String,Integer>();
        mapProj.put('myProj', 1);
        List<Proyecto__c> projs =  CEN_DataGenerator_Test.getProjectsDataBasic(mapProj);
        for(Proyecto__c p: projs){
            p.CEN_Sociedad__c = '0019';
            p.CEN_MaximumPaymentDuePeriod__c = 3;
        }
        insert projs;

        //---- LOTE
        Product2 prod2 = new Product2();
        prod2.Name='Lote prueba1';
        prod2.CEN_Proyecto__c=projs[0].Id;
        prod2.CODLOTE__c='123123123';
        prod2.CODCOMPANIA__c='0010';
        prod2.CEN_Tiene_Reserva__c='No';
        prod2.CODESTADOLOTE__c='L';
        prod2.CEN_PRECIOVENTAFUN__c='10000';
        prod2.IsActive=true;
        prod2.MANZANA__c = 'Mz. A1';
        prod2.AREA__c = '100';
        prod2.CEN_TIPOLOGIA__c= 'ESQUINA';
        prod2.CEN_IdLotSAP__c = '00000073';
        insert prod2;

        PricebookEntry precio2= new PricebookEntry();
        precio2.UseStandardPrice=false;
        precio2.IsActive=true;
        precio2.Pricebook2Id=Test.getStandardPricebookId();
        precio2.Product2Id=prod2.Id;
        precio2.UnitPrice=Decimal.valueOf(prod2.CEN_PRECIOVENTAFUN__c);
        insert precio2;

    }

    @isTest static void getCampana_ok() {

        String recordId = [SELECT Id FROM Proyecto__c LIMIT 1].Id;

        Test.startTest();
        CEN_Campana_ctr.respCampanaList resp = new CEN_Campana_ctr.respCampanaList();
        CEN_Campana_Test.respType = 'success';
        Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
        resp = CEN_Campana_ctr.getCampanaList(recordId);
        //System.debug('resp:'+resp);
        //System.assert(resp.strCampanaList.size() > 0, 'Existen campañas para el proyecto.');
        Test.stopTest();

    }

    public class CEN_HttpCalloutMock_tst implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();

            res.setHeader('Content-Type', 'text/xml');
            if (CEN_Campana_Test.respType.equals('success')) {
                res.setBody('<soap-env:Envelope	xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/"><soap-env:Header/><soap-env:Body><n0:ZRFC_OTC_CAMPANA_SF_WSResponse xmlns:n0="urn:sap-com:document:sap:rfc:functions"><DETALLE_CAMPANA><item><COD_CAMPANA>PROMO0014</COD_CAMPANA><NOM_CAMPANA>BENEFICIOS CENTENARIO</NOM_CAMPANA><NIVEL>1</NIVEL><MOTIVO_CAMPANA>DEBE PRESENTAR EL FOTOCHECK DE CENTENARIO</MOTIVO_CAMPANA><PALANCA_PRINCIPAL>PALANCA4</PALANCA_PRINCIPAL><INICIO_VIGENCIA>08.02.2023</INICIO_VIGENCIA><FIN_VIGENCIA>07.04.2023</FIN_VIGENCIA><PORCENTAJE_DESCUENTO>10.0</PORCENTAJE_DESCUENTO><IMPORTE>0.0</IMPORTE><MONEDA/><SUSTENTO>SI</SUSTENTO><SOCIEDAD>0010</SOCIEDAD><PROYECTO>10U1.098E</PROYECTO><COD_PROPIEDAD>00000000</COD_PROPIEDAD></item><item><COD_CAMPANA>PROMO0027</COD_CAMPANA><NOM_CAMPANA>FINANCIAMIENTO MÁS 150 M2</NOM_CAMPANA><NIVEL>1</NIVEL><MOTIVO_CAMPANA>EL FINANCIAMIENTO DEBE SER MAYOR A 150 M2</MOTIVO_CAMPANA><PALANCA_PRINCIPAL>PALANCA4</PALANCA_PRINCIPAL><INICIO_VIGENCIA>08.02.2023</INICIO_VIGENCIA><FIN_VIGENCIA>07.04.2023</FIN_VIGENCIA><PORCENTAJE_DESCUENTO>10.0</PORCENTAJE_DESCUENTO><IMPORTE>0.0</IMPORTE><MONEDA/><SUSTENTO>NO</SUSTENTO><SOCIEDAD>0010</SOCIEDAD><PROYECTO>10U1.098E</PROYECTO><COD_PROPIEDAD>00000000</COD_PROPIEDAD></item><item><COD_CAMPANA>PROMO0028</COD_CAMPANA><NOM_CAMPANA>SANTA MARÍA 10D - CASH</NOM_CAMPANA><NIVEL>1</NIVEL><MOTIVO_CAMPANA>MZ A - 10-20% CASH</MOTIVO_CAMPANA><PALANCA_PRINCIPAL>PALANCA2</PALANCA_PRINCIPAL><INICIO_VIGENCIA>08.02.2023</INICIO_VIGENCIA><FIN_VIGENCIA>07.04.2023</FIN_VIGENCIA><PORCENTAJE_DESCUENTO>5.0</PORCENTAJE_DESCUENTO><IMPORTE>0.0</IMPORTE><MONEDA/><SUSTENTO>NO</SUSTENTO><SOCIEDAD>0010</SOCIEDAD><PROYECTO>10U1.098E</PROYECTO><COD_PROPIEDAD>00000000</COD_PROPIEDAD></item></DETALLE_CAMPANA></n0:ZRFC_OTC_CAMPANA_SF_WSResponse></soap-env:Body></soap-env:Envelope>');
                res.setStatusCode(200);
            }else if (CEN_Campana_Test.respType.equals('warning'))  {
                res.setBody('<soap-env:Envelope	xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/"><soap-env:Header/><soap-env:Body><n0:ZRFC_OTC_CAMPANA_SF_WSResponse xmlns:n0="urn:sap-com:document:sap:rfc:functions"><DETALLE_CAMPANA><item><COD_CAMPANA>PROMO0014</COD_CAMPANA><NOM_CAMPANA>BENEFICIOS CENTENARIO</NOM_CAMPANA><NIVEL>1</NIVEL><MOTIVO_CAMPANA>DEBE PRESENTAR EL FOTOCHECK DE CENTENARIO</MOTIVO_CAMPANA><PALANCA_PRINCIPAL>PALANCA4</PALANCA_PRINCIPAL><INICIO_VIGENCIA>08.02.2023</INICIO_VIGENCIA><FIN_VIGENCIA>07.04.2023</FIN_VIGENCIA><PORCENTAJE_DESCUENTO>10.0</PORCENTAJE_DESCUENTO><IMPORTE>0.0</IMPORTE><MONEDA/><SUSTENTO>SI</SUSTENTO><SOCIEDAD>0010</SOCIEDAD><PROYECTO>10U1.098E</PROYECTO><COD_PROPIEDAD>00000000</COD_PROPIEDAD></item><item><COD_CAMPANA>PROMO0027</COD_CAMPANA><NOM_CAMPANA>FINANCIAMIENTO MÁS 150 M2</NOM_CAMPANA><NIVEL>1</NIVEL><MOTIVO_CAMPANA>EL FINANCIAMIENTO DEBE SER MAYOR A 150 M2</MOTIVO_CAMPANA><PALANCA_PRINCIPAL>PALANCA4</PALANCA_PRINCIPAL><INICIO_VIGENCIA>08.02.2023</INICIO_VIGENCIA><FIN_VIGENCIA>07.04.2023</FIN_VIGENCIA><PORCENTAJE_DESCUENTO>10.0</PORCENTAJE_DESCUENTO><IMPORTE>0.0</IMPORTE><MONEDA/><SUSTENTO>NO</SUSTENTO><SOCIEDAD>0010</SOCIEDAD><PROYECTO>10U1.098E</PROYECTO><COD_PROPIEDAD>00000000</COD_PROPIEDAD></item><item><COD_CAMPANA>PROMO0028</COD_CAMPANA><NOM_CAMPANA>SANTA MARÍA 10D - CASH</NOM_CAMPANA><NIVEL>1</NIVEL><MOTIVO_CAMPANA>MZ A - 10-20% CASH</MOTIVO_CAMPANA><PALANCA_PRINCIPAL>PALANCA2</PALANCA_PRINCIPAL><INICIO_VIGENCIA>08.02.2023</INICIO_VIGENCIA><FIN_VIGENCIA>07.04.2023</FIN_VIGENCIA><PORCENTAJE_DESCUENTO>5.0</PORCENTAJE_DESCUENTO><IMPORTE>0.0</IMPORTE><MONEDA/><SUSTENTO>NO</SUSTENTO><SOCIEDAD>0010</SOCIEDAD><PROYECTO>10U1.098E</PROYECTO><COD_PROPIEDAD>00000000</COD_PROPIEDAD></item></DETALLE_CAMPANA></n0:ZRFC_OTC_CAMPANA_SF_WSResponse></soap-env:Body></soap-env:Envelope>');
                res.setStatusCode(200);
            } else if (CEN_Campana_Test.respType.equals('error'))  {
                res.setBody('<soap-env:Envelope	xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/"><soap-env:Header/><soap-env:Body><n0:ZRFC_OTC_CAMPANA_SF_WSResponse xmlns:n0="urn:sap-com:document:sap:rfc:functions"><DETALLE_CAMPANA><item><COD_CAMPANA>PROMO0014</COD_CAMPANA><NOM_CAMPANA>BENEFICIOS CENTENARIO</NOM_CAMPANA><NIVEL>1</NIVEL><MOTIVO_CAMPANA>DEBE PRESENTAR EL FOTOCHECK DE CENTENARIO</MOTIVO_CAMPANA><PALANCA_PRINCIPAL>PALANCA4</PALANCA_PRINCIPAL><INICIO_VIGENCIA>08.02.2023</INICIO_VIGENCIA><FIN_VIGENCIA>07.04.2023</FIN_VIGENCIA><PORCENTAJE_DESCUENTO>10.0</PORCENTAJE_DESCUENTO><IMPORTE>0.0</IMPORTE><MONEDA/><SUSTENTO>SI</SUSTENTO><SOCIEDAD>0010</SOCIEDAD><PROYECTO>10U1.098E</PROYECTO><COD_PROPIEDAD>00000000</COD_PROPIEDAD></item><item><COD_CAMPANA>PROMO0027</COD_CAMPANA><NOM_CAMPANA>FINANCIAMIENTO MÁS 150 M2</NOM_CAMPANA><NIVEL>1</NIVEL><MOTIVO_CAMPANA>EL FINANCIAMIENTO DEBE SER MAYOR A 150 M2</MOTIVO_CAMPANA><PALANCA_PRINCIPAL>PALANCA4</PALANCA_PRINCIPAL><INICIO_VIGENCIA>08.02.2023</INICIO_VIGENCIA><FIN_VIGENCIA>07.04.2023</FIN_VIGENCIA><PORCENTAJE_DESCUENTO>10.0</PORCENTAJE_DESCUENTO><IMPORTE>0.0</IMPORTE><MONEDA/><SUSTENTO>NO</SUSTENTO><SOCIEDAD>0010</SOCIEDAD><PROYECTO>10U1.098E</PROYECTO><COD_PROPIEDAD>00000000</COD_PROPIEDAD></item><item><COD_CAMPANA>PROMO0028</COD_CAMPANA><NOM_CAMPANA>SANTA MARÍA 10D - CASH</NOM_CAMPANA><NIVEL>1</NIVEL><MOTIVO_CAMPANA>MZ A - 10-20% CASH</MOTIVO_CAMPANA><PALANCA_PRINCIPAL>PALANCA2</PALANCA_PRINCIPAL><INICIO_VIGENCIA>08.02.2023</INICIO_VIGENCIA><FIN_VIGENCIA>07.04.2023</FIN_VIGENCIA><PORCENTAJE_DESCUENTO>5.0</PORCENTAJE_DESCUENTO><IMPORTE>0.0</IMPORTE><MONEDA/><SUSTENTO>NO</SUSTENTO><SOCIEDAD>0010</SOCIEDAD><PROYECTO>10U1.098E</PROYECTO><COD_PROPIEDAD>00000000</COD_PROPIEDAD></item></DETALLE_CAMPANA></n0:ZRFC_OTC_CAMPANA_SF_WSResponse></soap-env:Body></soap-env:Envelope>');
                res.setStatusCode(200);
            }else{
                res.setBody('');
                res.setStatusCode(404);
            }

            return res;
        }
    }
}