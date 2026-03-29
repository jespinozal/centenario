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
public with sharing class CEN_GestionCobranzaService_cls {
    public CEN_GestionCobranzaService_cls() {

    }

    private static String customReq =
        '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:sap-com:document:sap:rfc:functions">' +
        '<soapenv:Header/>' +
        '<soapenv:Body>myBody' +
        '</soapenv:Body>' +
        '</soapenv:Envelope>';

    // @future(callout=true)
    // public static void gestionCobranzaAsinc(Set<Id> newIds, Set<String> socios) {
    //     List<CEN_AccountReceivable__c>  cuentasCobrar = new List<CEN_AccountReceivable__c>();
    //     cuentasCobrar = [SELECT Id FROM CEN_AccountReceivable__c WHERE Id IN:newIds];
    //     //gestionCobranza(listEncabezado, listaDetalle, listaSocios);
    // }

    @future(callout=true)
    public static void gestionCobranzaAsinc(String sociedad, String proforma, String codigoCliente, Set<Id> newIds, Set<String> newSocios) {
        List<CEN_AccountReceivable__c> cuentas = new List<CEN_AccountReceivable__c>();
        cuentas = [SELECT Id,CEN_Account__c,CEN_Account__r.CEN_N_mero_de_documento__pc,CEN_Account__r.CEN_Numero_de_documento_del__c,CEN_Sociedad__c,CEN_Proforma__c,CEN_CodigoCliente__c,CEN_NombreAsesorGestion__c,
                        CEN_FechaGestion__c,CEN_HoraGestion__c,CEN_TipoGestion__c,CEN_Categoria__c,CEN_SubCategoria__c,CEN_Motivo__c,
                        CEN_SubMotivo__c,CEN_MotivosNoPago__c,CEN_MotivosResolucion__c,CEN_ViveLote__c,CEN_DerivacionPostventa__c,
                        CEN_DerivacionReprogramacion__c,CEN_TipoAcuerdo__c,CEN_Moneda__c,CEN_MontoAcuerdo__c,CEN_FechaVencimientoAcuerdoPago__c,
                        CEN_ComentarioAcuerdoPago__c,CEN_ComentarioGestionGeneral__c,CEN_FechaHoraGestion__c,CEN_TelefonoContacto__c,
                        CEN_CorreoContacto__c,CEN_DireccionContacto__c,CEN_Otros__c,CEN_PersonaResponsablePago__c,CEN_ParentescoPersonaResponsablePago__c,
                        CEN_AnioGestion__c,CEN_MesGestion__c,CEN_DerivacionPostventaResolucionMes__c,CEN_IncumplimientoAcuerdoPagoMes__c
                FROM CEN_AccountReceivable__c WHERE Id IN: newIds];

        gestionCobranza(sociedad, proforma, codigoCliente, cuentas,newSocios);
    }

    //public static CEN_GestionCobranzaResponse gestionCobranza(List<Object> listEncabezado, List<Object> listaDetalle, List<Object> listaSocios) {
    public static CEN_GestionCobranzaResponse gestionCobranza(String sociedad, String proforma, String codigoCliente, List<CEN_AccountReceivable__c> cuentas, Set<String> newSocios) {
            CEN_GestionCobranzaResponse resp = new CEN_GestionCobranzaResponse();

            CEN_GestionCobranzaRequest req = new CEN_GestionCobranzaRequest();

            CEN_GestionCobranzaRequest.ZRFC_GESTION_COBRANZA_WS_element reqGestionCobranza = new CEN_GestionCobranzaRequest.ZRFC_GESTION_COBRANZA_WS_element();
            CEN_GestionCobranzaRequest.ZACCO_COBRANZA_CAMPOS reqCobranzaCampos = new CEN_GestionCobranzaRequest.ZACCO_COBRANZA_CAMPOS();
            CEN_GestionCobranzaRequest.ZTT_COBRANZA_FILA reqCobranzaFila = new CEN_GestionCobranzaRequest.ZTT_COBRANZA_FILA();
            CEN_GestionCobranzaRequest.ZTT_SOCIOS_FILA reqSociosFila = new CEN_GestionCobranzaRequest.ZTT_SOCIOS_FILA();

            //CEN_GestionCobranzaRequest.ZACCO_COBRANZA_CAMPOS cabecera = new CEN_GestionCobranzaRequest.ZACCO_COBRANZA_CAMPOS();

            List<CEN_GestionCobranzaRequest.ZACCO_COBRANZA_FILA> listDetalle = new List<CEN_GestionCobranzaRequest.ZACCO_COBRANZA_FILA>();

            List<CEN_GestionCobranzaRequest.ZACCO_SOCIOS_FILA> listSocio = new List<CEN_GestionCobranzaRequest.ZACCO_SOCIOS_FILA>();

            //CABECERA
            //Map<String,Object> encabezado = (Map<String,Object>)listEncabezado[0];
            //reqCobranzaCampos.PROFORMA = (String)encabezado.get('PROFORMA');//'12768';
            //reqCobranzaCampos.SOCIEDAD = (String)encabezado.get('SOCIEDAD');//'0019';
            //reqCobranzaCampos.CODIGO_CLIENTE = (String)encabezado.get('CODIGO_CLIENTE');//'80305321';
            reqCobranzaCampos.PROFORMA = proforma.leftPad(10, '0');
            reqCobranzaCampos.SOCIEDAD = sociedad.leftPad(4, '0');
            reqCobranzaCampos.CODIGO_CLIENTE = codigoCliente;

            //DETALLE
            // for (Object detalleObj : listaDetalle) {
            for (CEN_AccountReceivable__c cuenta : cuentas) {
                CEN_GestionCobranzaRequest.ZACCO_COBRANZA_FILA itemDetalle = new CEN_GestionCobranzaRequest.ZACCO_COBRANZA_FILA();
                //Map<String,Object> detalle = (Map<String,Object>)detalleObj;
                itemDetalle.NOMBRE_ASESOR_GESTION = cuenta.CEN_NombreAsesorGestion__c;//(String)detalle.get('NOMBRE_ASESOR_GESTION');//'JONATHAN';
                itemDetalle.FECHA_GESTION = String.valueOf(cuenta.CEN_FechaGestion__c.day()).leftPad(2, '0') + '/' + String.valueOf(cuenta.CEN_FechaGestion__c.month()).leftPad(2, '0') + '/' + cuenta.CEN_FechaGestion__c.year();//(String)detalle.get('FECHA_GESTION');//'12/10/2023';
                itemDetalle.HORA_GESTION = String.valueOf(cuenta.CEN_HoraGestion__c.hour()).leftPad(2, '0') + ':' + String.valueOf(cuenta.CEN_HoraGestion__c.minute()).leftPad(2, '0') + ':' + String.valueOf(cuenta.CEN_HoraGestion__c.second()).leftPad(2, '0');//(String)detalle.get('HORA_GESTION');//'12:50:20';
                itemDetalle.TIPO_GESTION = cuenta.CEN_TipoGestion__c;//(String)detalle.get('TIPO_GESTION');//'001';
                itemDetalle.TIP_GESTION_CATEGORIA = cuenta.CEN_Categoria__c;//(String)detalle.get('TIP_GESTION_CATEGORIA');//'001';
                itemDetalle.TIP_GESTION_MOTIVO = cuenta.CEN_Motivo__c;//(String)detalle.get('TIP_GESTION_MOTIVO');//'002';
                itemDetalle.TIP_GESTION_SUBMOTIVO = cuenta.CEN_SubMotivo__c;//(String)detalle.get('TIP_GESTION_SUBMOTIVO');//'001';
                itemDetalle.MOTIVO_NO_PAGO = cuenta.CEN_MotivosNoPago__c;//(String)detalle.get('MOTIVO_NO_PAGO');//'002';
                itemDetalle.MOTIVO_RESOLUCION = cuenta.CEN_MotivosResolucion__c;//(String)detalle.get('MOTIVO_RESOLUCION');//'CUO';
                itemDetalle.VIVE_LOTE = cuenta.CEN_ViveLote__c ? 'X' : '';//(Boolean)detalle.get('VIVE_LOTE') ? 'X' : '';//'X';
                itemDetalle.DERIVACION_POSTVENTA = cuenta.CEN_DerivacionPostventa__c ? 'X' : '';//(Boolean)detalle.get('DERIVACION_POSTVENTA') ? 'X' : '';//'X';
                itemDetalle.DERIVACION_REPROGRAMACION = cuenta.CEN_DerivacionReprogramacion__c ? 'X' : '';//(Boolean)detalle.get('DERIVACION_REPROGRAMACION') ? 'X' : '';//'X';
                itemDetalle.TIPO_ACUERDO = cuenta.CEN_TipoAcuerdo__c;//(String)detalle.get('TIPO_ACUERDO');//'1';
                itemDetalle.MONTO_ACUERDO = String.valueOf(cuenta.CEN_MontoAcuerdo__c);//String.valueOf(detalle.get('MONTO_ACUERDO'));//'19000.80';
                itemDetalle.WAERS = cuenta.CEN_Moneda__c;//(String)detalle.get('MONEDA');//'PEN';
                //System.debug(cuenta.CEN_FechaVencimientoAcuerdoPago__c);
                if(cuenta.CEN_FechaVencimientoAcuerdoPago__c!=null){ itemDetalle.FECHA_VENC = String.valueOf(cuenta.CEN_FechaVencimientoAcuerdoPago__c.day()).leftPad(2, '0') + '/' + String.valueOf(cuenta.CEN_FechaVencimientoAcuerdoPago__c.month()).leftPad(2, '0') + '/' + cuenta.CEN_FechaVencimientoAcuerdoPago__c.year();}//(String)detalle.get('FECHA_VENCIMIENTO_ACUERDO_PAGO');//'22/11/2023';
                itemDetalle.COMENTARIO_ACUERDO_PAGO = cuenta.CEN_ComentarioAcuerdoPago__c;//(String)detalle.get('COMENTARIO_ACUERDO_PAGO');//'PAGARÉ A FIN DE MES';
                itemDetalle.COMENTARIO_GESTION = cuenta.CEN_ComentarioGestionGeneral__c;//(String)detalle.get('COMENTARIO_GESTION_GENERAL');//'BUENA GESTION';
                Datetime dt = cuenta.CEN_FechaHoraGestion__c;//Datetime.now();
                Long fechaHoraGestionUT = dt.getTime();
                itemDetalle.FECHA_Y_HORA_GESTION = String.valueOf(fechaHoraGestionUT).substring(0, 10);//(String)detalle.get('FECHA_Y_HORA_GESTION');//'4567899028';
                itemDetalle.TELEFONO_CONTACTO = cuenta.CEN_TelefonoContacto__c;//(String)detalle.get('TELEFONO_CONTACTO');//'983723586';
                itemDetalle.CORREO_CONTACTO = cuenta.CEN_CorreoContacto__c;//(String)detalle.get('CORREO_CONTACTO');//'MARIA@GMAIL.COM';
                itemDetalle.DIRECCION_CONTACTO = cuenta.CEN_DireccionContacto__c;//(String)detalle.get('DIRECCION_CONTACTO');//'PROLONG. SAN LUCAS - 3890';
                itemDetalle.OTROS = cuenta.CEN_Otros__c;//(String)detalle.get('OTROS');//'PRUEBA DE OTROS DATOS';
                itemDetalle.RESPONSABLE_PAGO = cuenta.CEN_PersonaResponsablePago__c;//(String)detalle.get('PERSONA_RESPONSABLE_PAGO');//'ANA PAULA CHAVEZ';
                itemDetalle.PARENT_RESPONSABLE_PAGO = cuenta.CEN_ParentescoPersonaResponsablePago__c;//(String)detalle.get('PARENTESCO_PERSONA_RESPONSABLE_PAGO');//'TIO';
                itemDetalle.ANIO_GESTION = cuenta.CEN_AnioGestion__c;//(String)detalle.get('ANIO_GESTION');//'2023';
                itemDetalle.MES_GESTION = cuenta.CEN_MesGestion__c;//(String)detalle.get('MES_GESTION');//'11';
                itemDetalle.DERIVACION_POSTVENTA_RES_MES = cuenta.CEN_DerivacionPostventaResolucionMes__c ? 'X' : '';//(Boolean)detalle.get('DERIVACION_POSTVENTA_RESOLUCION_MES')? 'X' : '';//'X';
                itemDetalle.INCUMP_ACUERDO_PAGO_MES = cuenta.CEN_IncumplimientoAcuerdoPagoMes__c ? 'X' : '';//(Boolean)detalle.get('INCUMPLIMIENTO_ACUERDO_PAGO_MES')? 'X' : '';//'X';
                itemDetalle.TIPO_CLIENTE = cuenta.CEN_SubCategoria__c;//(String)detalle.get('TIPIFICACION_GESTION_SUBCATEGORIA');//'002';
                listDetalle.add(itemDetalle);
            }
            reqCobranzaFila.item = listDetalle;

            //SOCIOS
            //for (Object socioObj : listaSocios) {
            System.debug('newSocios: '+ newSocios);
            for(String socio : newSocios){
                CEN_GestionCobranzaRequest.ZACCO_SOCIOS_FILA itemSocio = new CEN_GestionCobranzaRequest.ZACCO_SOCIOS_FILA();
                //Map<String,Object> socio = (Map<String,Object>)socioObj;
                System.debug('socio: '+ socio);
                itemSocio.CODIGO_COPROPIETARIO = socio;//(String)socio.get('CODIGO_COPROPIETARIO');//'45558712';
                listSocio.add(itemSocio);
            }
            System.debug('listSocio: '+ listSocio);
            reqSociosFila.item = listSocio;

            reqGestionCobranza.IS_CAB_COBRANZA = reqCobranzaCampos;
            reqGestionCobranza.IT_FILA_COBRANZA = reqCobranzaFila;
            reqGestionCobranza.IT_FILA_SOCIOS = reqSociosFila;

            req.ZRFC_GESTION_COBRANZA_WS = reqGestionCobranza;

            resp = callGestionCobranzaApi(req);
            system.debug('req:' + req);

            return resp;
    }

    private static CEN_GestionCobranzaResponse callGestionCobranzaApi(
        CEN_GestionCobranzaRequest reqProcess
    ) {
        String customReqBody;
        CEN_GestionCobranzaResponse resp = new CEN_GestionCobranzaResponse();
        XMLSerializer serializerXML = new XMLSerializer();
        customReqBody = serializerXML.serialize(reqProcess);
        customReqBody = customReqBody.replace(
            'ZRFC_GESTION_COBRANZA_WS',
            'urn:ZRFC_GESTION_COBRANZA_WS'
        );
        try {
            System.debug('customReqBody: ' + customReqBody);

            CEN_Callout_cls callApi = new CEN_Callout_cls('CEN_GestionCobranza');
            Dom.Document docReq = new Dom.Document();
            System.debug('customReqBody: ' + customReqBody);
            String setReq = customReq.replace('myBody', customReqBody);
            setReq = setReq.replace('&', '&amp;');
            docReq.load(setReq);

            callApi.setRequestBody(docReq);
            if(!Test.isRunningTest()){
                callApi.setTimeout(50000);
            }
            resp = (CEN_GestionCobranzaResponse) callApi.makeCallout().getParsedResponse();
            System.debug('resp: ' + resp);
        } catch (Exception ex) {
            System.debug('callGestionCobranzaApi-Error: ' + ex.getMessage() + '-' + ex.getLineNumber());
        }
        return resp;
    }
}