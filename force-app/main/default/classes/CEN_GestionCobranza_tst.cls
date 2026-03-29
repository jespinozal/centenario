/**
 * @description       :
 * @author            : @nttdata.com
 * @group             :
 * @last modified on  : 14-12-2023
 * @last modified by  : @nttdata.com
 * Modifications Log
 * Ver   Date         Author         Modification
 * 1.0   14-12-2023   @nttdata.com   Initial Version
**/
@isTest
public with sharing class CEN_GestionCobranza_tst {
    public static String respType = '';
    @TestSetup
    static void SetUp(){

        Tabla_maestra__c distrito = new Tabla_maestra__c();
        distrito.Name='Lima';
        distrito.Departamento__c='Lima';
        distrito.Provincia__c='Lima';
        distrito.CEN_Codigo_departamento__c='15';
        distrito.CEN_Codigo_provincia__c='1501';
        distrito.CEN_Codigo_distrito__c='150105';
        insert distrito;

        Account acc = new Account();
        acc.Salutation = 'Sr.';
        acc.LastName='Perez';
        acc.FirstName='Juan';
        acc.CEN_Estado_civil__pc = 'Casado';
        acc.CEN_Nacionalidad__pc = 'PE';
        acc.CEN_Tipo_de_documento__pc='DNI';
        acc.CEN_N_mero_de_documento__pc='10203040';
        acc.CEN_Lugar_de_nacimiento__pc='';
        acc.CEN_Direccion__pc='Calle San Lorenzo';
        acc.CEN_Referencia_direccion__c='';
        acc.CEN_Tel_fono_Trabajo__pc='987654321';
        acc.PersonMobilePhone='5555000';
        acc.PersonEmail='juan@everis.com';
        acc.RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        acc.CEN_Distrito__pc =distrito.Id;
        acc.CEN_SocietySAP__c = '0010';
        insert acc;

        CEN_AccountReceivable__c cc = new CEN_AccountReceivable__c();
        cc.CEN_Account__c = acc.Id;
        cc.CEN_Sociedad__c = '0010';
        cc.CEN_Proforma__c = '0000017794';
        cc.CEN_FechaGestion__c = Date.today();
        cc.CEN_HoraGestion__c = Time.newInstance(4, 2, 3, 4);
        cc.CEN_TipoGestion__c = '001';
        cc.CEN_Categoria__c = '001';
        cc.CEN_Motivo__c = '002';
        cc.CEN_SubMotivo__c = '001';
        cc.CEN_MotivosNoPago__c = '002';
        cc.CEN_MotivosResolucion__c = 'CUO';
        cc.CEN_ViveLote__c = true;
        cc.CEN_DerivacionPostventa__c = true;
        cc.CEN_DerivacionReprogramacion__c = true;
        cc.CEN_TipoAcuerdo__c = '1';
        cc.CEN_MontoAcuerdo__c = 19000.80;
        cc.CEN_Moneda__c = 'PEN';
        cc.CEN_FechaVencimientoAcuerdoPago__c = Date.today();
        cc.CEN_ComentarioAcuerdoPago__c = 'PAGARÉ A FIN DE MES';
        cc.CEN_ComentarioGestionGeneral__c = 'BUENA GESTION';
        cc.CEN_FechaHoraGestion__c = Datetime.now();
        cc.CEN_TelefonoContacto__c = '983723586';
        cc.CEN_CorreoContacto__c = 'MARIA@GMAIL.COM';
        cc.CEN_DireccionContacto__c = 'PROLONG. SAN LUCAS - 3890';
        cc.CEN_Otros__c = 'PRUEBA DE OTROS DATOS';
        cc.CEN_PersonaResponsablePago__c = 'ANA PAULA CHAVEZ';
        cc.CEN_ParentescoPersonaResponsablePago__c = 'TIO';
        cc.CEN_AnioGestion__c = '2023';
        cc.CEN_MesGestion__c = '11';
        cc.CEN_DerivacionPostventaResolucionMes__c = true;
        cc.CEN_IncumplimientoAcuerdoPagoMes__c = true;
        cc.CEN_SubCategoria__c = '002';

        insert cc;
		// tm.CEN_Codigo_departamento__c = '00001';
        // tm.CEN_Codigo_distrito__c = '00001';
        // tm.CEN_Codigo_provincia__c = '00001';
        // insert tm;
    }

    static testMethod void executeGestionCobranza_doPost() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
     	Test.startTest();
            req.requestURI = URL.getSalesforceBaseUrl().toExternalForm()+'/accountreceivable/';
            req.httpMethod = 'POST';
            Blob strJson = Blob.valueOf('{ "GestionCobranza": [ { "Encabezado": [ { "SOCIEDAD": "10", "PROFORMA": "0000017794", "CODIGO_CLIENTE": "32165497" } ] }, { "Socios": [ { "CODIGO_COPROPIETARIO": "2045471306" }, { "CODIGO_COPROPIETARIO": "C6685411" } ] }, { "Detalle": [ { "NOMBRE_ASESOR_GESTION": "Carlos Javier", "FECHA_GESTION": "06/12/2023", "HORA_GESTION": "09:31:25", "TIPO_GESTION": "002", "TIPIFICACION_GESTION_CATEGORIA": "004", "TIPIFICACION_GESTION_SUBCATEGORIA": "002", "TIPIFICACION_GESTION_MOTIVO": "005", "TIPIFICACION_GESTION_SUBMOTIVO": "006", "MOTIVOS_NO_PAGO": "003", "MOTIVOS_RESOLUCION": "CON", "VIVE_LOTE": true, "DERIVACION_POSTVENTA": true, "DERIVACION_REPROGRAMACION": true, "TIPO_ACUERDO": "2", "MONEDA": "PEN", "MONTO_ACUERDO": 2000.50, "FECHA_VENCIMIENTO_ACUERDO_PAGO": "", "COMENTARIO_ACUERDO_PAGO": "FECHA DE PAGO: 26/12/2023 CUOTA: ABR MAY JUN 23 Nª FINANCIAMIENTO: 42255 MONTO: 7,417.68", "COMENTARIO_GESTION_GENERAL": "COMENTARIO X", "FECHA_Y_HORA_GESTION": "07/12/2023 22:31:25", "TELEFONO_CONTACTO": "+51930306453", "CORREO_CONTACTO": "CAROLINAURIBE0303@GMAIL.COM", "DIRECCION_CONTACTO": "JR CORONEL ZEGARRA 854", "OTROS": "OTRO VALOR", "PERSONA_RESPONSABLE_PAGO": "Andres Javier", "PARENTESCO_PERSONA_RESPONSABLE_PAGO": "Sobrino", "ANIO_GESTION": "2023", "MES_GESTION": "12", "DERIVACION_POSTVENTA_RESOLUCION_MES": true, "INCUMPLIMIENTO_ACUERDO_PAGO_MES": true } ] } ] }');
            req.requestBody = strJson;
            RestContext.request = req;
            RestContext.response= res;
            CEN_AccountReceivableService_cls.doPost();

            CEN_AccountReceivable__c cc = [SELECT Id,CEN_Sociedad__c,CEN_Proforma__c,CEN_Account__r.CEN_N_mero_de_documento__pc FROM CEN_AccountReceivable__c WHERE CEN_Proforma__c = '0000017794' LIMIT 1];
            String sociedad = cc.CEN_Sociedad__c;
            String proforma = cc.CEN_Proforma__c;
            String codigoCliente = cc.CEN_Account__r.CEN_N_mero_de_documento__pc;
            Set<Id> newIds = new Set<Id>();
            newIds.add(cc.Id);
            Set<String> newSocios = new Set<String>();
            newSocios.add('2045471306');
            CEN_GestionCobranza_tst.respType = 'ok';
		    Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
            CEN_GestionCobranzaService_cls.gestionCobranzaAsinc(sociedad,proforma,codigoCliente,newIds,newSocios);

        Test.stopTest();
    }

    public class CEN_HttpCalloutMock_tst implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'text/xml');
            if (CEN_GestionCobranza_tst.respType.equals('ok')) {
                res.setBody('<soap-env:Envelope xmlns:soap-env="http://schemas.xmlsoap.org/soap/envelope/"> <soap-env:Header/> <soap-env:Body> <n0:ZRFC_GESTION_COBRANZA_WSResponse xmlns:n0="urn:sap-com:document:sap:rfc:functions"> <ET_RETURN> <item> <TYPE>I</TYPE> <ID>ZAC_OTC</ID> <NUMBER>165</NUMBER> <MESSAGE>Se guardó el encabezado de la gestión de cobranza Nro 124.</MESSAGE> <LOG_NO/> <LOG_MSG_NO>000000</LOG_MSG_NO> <MESSAGE_V1>124</MESSAGE_V1> <MESSAGE_V2/> <MESSAGE_V3/> <MESSAGE_V4/> <PARAMETER/> <ROW>0</ROW> <FIELD/> <SYSTEM>Q01CLNT100</SYSTEM> </item> <item> <TYPE>I</TYPE> <ID>ZAC_OTC</ID> <NUMBER>166</NUMBER> <MESSAGE>Se guardó el socio de la gestión de cobranza.</MESSAGE> <LOG_NO/> <LOG_MSG_NO>000000</LOG_MSG_NO> <MESSAGE_V1/> <MESSAGE_V2/> <MESSAGE_V3/> <MESSAGE_V4/> <PARAMETER/> <ROW>0</ROW> <FIELD/> <SYSTEM>Q01CLNT100</SYSTEM> </item> <item> <TYPE>I</TYPE> <ID>ZAC_OTC</ID> <NUMBER>167</NUMBER> <MESSAGE>Se guardó el detalle de la gestión de cobranza.</MESSAGE> <LOG_NO/> <LOG_MSG_NO>000000</LOG_MSG_NO> <MESSAGE_V1/> <MESSAGE_V2/> <MESSAGE_V3/> <MESSAGE_V4/> <PARAMETER/> <ROW>0</ROW> <FIELD/> <SYSTEM>Q01CLNT100</SYSTEM> </item> </ET_RETURN> </n0:ZRFC_GESTION_COBRANZA_WSResponse> </soap-env:Body> </soap-env:Envelope>');
                res.setStatusCode(200);
            } else{
                res.setBody('');
                res.setStatusCode(404);
            }
            return res;
        }
    }
}