/**
 * @description       :
 * @author            : @nttdata.com
 * @group             :
 * @last modified on  : 07-11-2023
 * @last modified by  : @nttdata.com
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   07-11-2023   @nttdata.com  Initial Version
**/
@RestResource(urlMapping='/accountreceivable/*')
global class CEN_AccountReceivableService_cls {

    @HttpPost
    global static List<ResponseWrap> doPost() {

        List<ResponseWrap> listResp = new List<ResponseWrap>();
        String jsonString = RestContext.request.requestBody.toString();
        //paymentoderreq payorder = new paymentoderreq();
        Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(RestContext.request.requestBody.toString());
        try{

            List<Object> accountReceivableObjectsMeta = (List<Object>)params.get('GestionCobranza');
            List<Object> accountReceivableObjects = new List<Object>();

            Map<String, Object> encabezadoMeta = (Map<String, Object>)accountReceivableObjectsMeta[0];
            Map<String, Object> sociosMeta = (Map<String, Object>)accountReceivableObjectsMeta[1];
            Map<String, Object> detalleMeta = (Map<String, Object>)accountReceivableObjectsMeta[2];

            List<Object> listEncabezado = (List<Object>)encabezadoMeta.get('Encabezado');
            List<Object> listaSocios = (List<Object>)sociosMeta.get('Socios');
            List<Object> listaDetalle = (List<Object>)detalleMeta.get('Detalle');

            List<CEN_AccountReceivable__c> cuentasCobrar = new List<CEN_AccountReceivable__c>();

            Map<String,Object> encabezado = (Map<String,Object>)listEncabezado[0];
            String sociedad = (String) encabezado.get('SOCIEDAD');
            String proforma = (String) encabezado.get('PROFORMA');
            String codigoCliente = (String) encabezado.get('CODIGO_CLIENTE');
            
            //if(String.isEmpty(codigoCliente)){throw new AccountReceivableServiceException('El código de cliente es obligatorio [CODIGO_CLIENTE]');}
            proforma = proforma.leftPad(10, '0');
            String idAccount = [SELECT Id FROM Account WHERE (CEN_Numero_de_documento_del__c=:codigoCliente OR CEN_N_mero_de_documento__pc=:codigoCliente) AND Id IN (SELECT AccountId FROM Opportunity WHERE CEN_Proforma__c =:proforma)]?.Id;
            //if(idAccount==null){throw new AccountReceivableServiceException('No existe cliente en Salesforce ' + codigoCliente + ', comunicarse con el administrador.');}

            String cadena;
            List<String> arreglo;
            DateTime formatDateTime;
            Date formatDate;
            Time formatTime;
            Set<Id> newIds = new Set<Id>();
            Set<String> newSocios = new Set<String>();

            for (Object detalleObj : listaDetalle) {
                Map<String,Object> detalle = (Map<String,Object>)detalleObj;
                CEN_AccountReceivable__c cuentaCobrar = new CEN_AccountReceivable__c();
                if(idAccount!=null){cuentaCobrar.CEN_Account__c = idAccount;}
                cuentaCobrar.CEN_Sociedad__c = sociedad;
                cuentaCobrar.CEN_Proforma__c = proforma;
                cuentaCobrar.CEN_CodigoCliente__c = codigoCliente;
                cuentaCobrar.CEN_NombreAsesorGestion__c = (String)detalle.get('NOMBRE_ASESOR_GESTION');
                cadena = (String)detalle.get('FECHA_GESTION');
                arreglo = cadena.split('/');
                formatDate = Date.newInstance(Integer.valueOf(arreglo[2]), Integer.valueOf(arreglo[1]), Integer.valueOf(arreglo[0]));
                cuentaCobrar.CEN_FechaGestion__c = formatDate;
                cadena = (String)detalle.get('HORA_GESTION');
                arreglo = cadena.split(':');
                formatTime = Time.newInstance(Integer.valueOf(arreglo[0]), Integer.valueOf(arreglo[1]), Integer.valueOf(arreglo[2]),0);
                cuentaCobrar.CEN_HoraGestion__c = formatTime;
                cuentaCobrar.CEN_TipoGestion__c = (String)detalle.get('TIPO_GESTION');
                cuentaCobrar.CEN_Categoria__c = (String)detalle.get('TIPIFICACION_GESTION_CATEGORIA');
                cuentaCobrar.CEN_SubCategoria__c = (String)detalle.get('TIPIFICACION_GESTION_SUBCATEGORIA');
                cuentaCobrar.CEN_Motivo__c = (String)detalle.get('TIPIFICACION_GESTION_MOTIVO');
                cuentaCobrar.CEN_SubMotivo__c = (String)detalle.get('TIPIFICACION_GESTION_SUBMOTIVO');
                cuentaCobrar.CEN_MotivosNoPago__c = (String)detalle.get('MOTIVOS_NO_PAGO');
                cuentaCobrar.CEN_MotivosResolucion__c = (String)detalle.get('MOTIVOS_RESOLUCION');
                cuentaCobrar.CEN_ViveLote__c = (Boolean)detalle.get('VIVE_LOTE');
                cuentaCobrar.CEN_DerivacionPostventa__c = (Boolean)detalle.get('DERIVACION_POSTVENTA');
                cuentaCobrar.CEN_DerivacionReprogramacion__c = (Boolean)detalle.get('DERIVACION_REPROGRAMACION');
                cuentaCobrar.CEN_TipoAcuerdo__c = (String)detalle.get('TIPO_ACUERDO');
                cuentaCobrar.CEN_Moneda__c = (String)detalle.get('MONEDA');
                cuentaCobrar.CEN_MontoAcuerdo__c = (Double)detalle.get('MONTO_ACUERDO');
                cadena = (String)detalle.get('FECHA_VENCIMIENTO_ACUERDO_PAGO');
                if(String.isNotEmpty(cadena)){
                    arreglo = cadena.split('/');
                    formatDate = Date.newInstance(Integer.valueOf(arreglo[2]), Integer.valueOf(arreglo[1]), Integer.valueOf(arreglo[0]));
                    cuentaCobrar.CEN_FechaVencimientoAcuerdoPago__c = formatDate;
                }
                cuentaCobrar.CEN_ComentarioAcuerdoPago__c = (String)detalle.get('COMENTARIO_ACUERDO_PAGO');
                cuentaCobrar.CEN_ComentarioGestionGeneral__c = (String)detalle.get('COMENTARIO_GESTION_GENERAL');
                cadena = (String)detalle.get('FECHA_Y_HORA_GESTION');
                List<String> dateAndTimeList = cadena.split(' ');
                List<String> dateList = dateAndTimeList[0].split('/');
                List<string> timeList = dateAndTimeList[1].split(':');
                formatDateTime = DateTime.newInstance(Integer.valueOf(dateList[2]), Integer.valueOf(dateList[1]), Integer.valueOf(dateList[0]), Integer.valueOf(timeList[0]), Integer.valueOf(timeList[1]), Integer.valueOf(timeList[2].split('\\.')[0]));
                cuentaCobrar.CEN_FechaHoraGestion__c = formatDateTime;
                cuentaCobrar.CEN_TelefonoContacto__c = (String)detalle.get('TELEFONO_CONTACTO');
                cuentaCobrar.CEN_CorreoContacto__c = (String)detalle.get('CORREO_CONTACTO');
                cuentaCobrar.CEN_DireccionContacto__c = (String)detalle.get('DIRECCION_CONTACTO');
                cuentaCobrar.CEN_Otros__c = (String)detalle.get('OTROS');
                cuentaCobrar.CEN_PersonaResponsablePago__c = (String)detalle.get('PERSONA_RESPONSABLE_PAGO');
                cuentaCobrar.CEN_ParentescoPersonaResponsablePago__c = (String)detalle.get('PARENTESCO_PERSONA_RESPONSABLE_PAGO');
                cuentaCobrar.CEN_AnioGestion__c = (String)detalle.get('ANIO_GESTION');
                cuentaCobrar.CEN_MesGestion__c = (String)detalle.get('MES_GESTION');
                cuentaCobrar.CEN_DerivacionPostventaResolucionMes__c = (Boolean)detalle.get('DERIVACION_POSTVENTA_RESOLUCION_MES');
                cuentaCobrar.CEN_IncumplimientoAcuerdoPagoMes__c = (Boolean)detalle.get('INCUMPLIMIENTO_ACUERDO_PAGO_MES');
                cuentasCobrar.add(cuentaCobrar);
            }

            System.debug(cuentasCobrar);
            insert cuentasCobrar;

            for(CEN_AccountReceivable__c cc : cuentasCobrar){
                ResponseWrap resp = new ResponseWrap();
                resp.id = cc.Id;
                resp.mensaje = 'Se creó el registro correctamente';
                resp.estado = 'Success';
                newIds.add(cc.Id);
                listResp.add(resp);
            }

            if(listaSocios.size()>0){
                for(Object socioObj : listaSocios){
                    Map<String,Object> socio = (Map<String,Object>)socioObj;
                    newSocios.add((String) socio.get('CODIGO_COPROPIETARIO'));
                }
            }

            if(listResp.size()>0){
                CEN_GestionCobranzaService_cls.gestionCobranzaAsinc(sociedad, proforma, codigoCliente, newIds, newSocios);
            }

            return listResp;

        } catch (Exception ex) {
            //List<ResponseWrap> listResp = new List<ResponseWrap>();
            ResponseWrap resp = new ResponseWrap();
            resp.Id = null;
            resp.mensaje = ex.getMessage() + ' ' + ex.getLineNumber() + ', Comunicar al equipo de Salesforce';
            resp.estado = 'Error';
            listResp.add(resp);
            return listResp;
        }
    }

    global class ResponseWrap{
        Public String id { get; set; }
        Public String mensaje { get; set; }
        Public String estado { get; set; }
    }

    public class AccountReceivableServiceException extends Exception {}

}