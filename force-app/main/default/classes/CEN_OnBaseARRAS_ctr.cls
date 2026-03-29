/**
 * @description       : 
 * @author            : augusto.nayib.tamayo.bedregal@everis.nttdata.com
 * @group             : 
 * @last modified on  : 07-25-2021
 * @last modified by  : @everis.com
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   06-13-2021   @everis.com   Initial Version
**/
public class CEN_OnBaseARRAS_ctr {
    public static final List < String > listaEstadoPermitidos = new List < String > {'',null,'PEND. ADJ. ARCH.','OBSERVADO','ATENDIDO'};
      public static final List < String > listaEstadoPermitidosString = new List < String > {'"Sin estado"','PEND. ADJ. ARCH.','OBSERVADO','ATENDIDO'};
    
      @AuraEnabled
      public static ResponseInit validarDatosDeOnbase(String OportunidadId) {
        System.debug('<!--validarDatosDeOnbase inicia');
        ResponseInit respuesta = new ResponseInit();
        respuesta.esSolicitudOnbase = false;
        respuesta.etapaEsPreliminar = false;
        respuesta.noTieneContrato = false;
        respuesta.esSolicitudOnBaseArras = false;
        respuesta.isVisible = false;
    
        Opportunity oportunidad = null;
        try {
          oportunidad = [
            SELECT
            Id,
            CEN_onbase_id_bandeja_arras__c,
            CEN_Onbase_documento_id_arras__c,
            CEN_Nro_solicitud_presolicitud_arras__c,
            CEN_correo__c,
            CEN_CorreoAuxi__c,
            CEN_Bandeja_onbase_de_solicitud__c,
            CEN_Bandeja_onbase_de_solicitud_arras__c,
            CEN_Supervisor__c,
            CEN_Supervisor__r.Name,
            StageName,
            CEN_Sub_estado__c,
            CEN_sub_etapa_ARRAS__c,
            Description,
            CEN_Description_arras__c,
            CEN_Tipo_de_solicitud__c,
            CEN_Tipo_de_solicitud_arras__c,
            CEN_Monto_cuota_de_inicial_de_precio__c,
            CEN_StatusLot__c,
            CEN_Nro_solicitud_presolicitud__c,
            CEN_Onbase_documento_id__c,
            CEN_onbase_id_bandeja__c
            FROM Opportunity
            WHERE Id =: OportunidadId
            LIMIT 1
          ];
        } catch (Exception ex) {
          System.debug(
            'Exception trying get data: ' +
            ex.getMessage() +
            '. Line: ' +
            ex.getLineNumber() +
            '. Type: ' +
            ex.getTypeName()
          );
        }
        if (oportunidad != null) {
          respuesta.oportunidad = oportunidad;
          /*if (String.isNotBlank(String.valueOf(oportunidad.CEN_onbase_id_bandeja_arras__c)) &&
                String.isNotBlank(oportunidad.CEN_Onbase_documento_id_arras__c) &&
                String.isNotBlank(oportunidad.CEN_Nro_solicitud_presolicitud_arras__c) &&
                String.isBlank(oportunidad.CEN_sub_etapa_ARRAS__c)) {
                respuesta.esSolicitudOnbase = true;
          }*/
          if (String.isNotBlank( String.valueOf(oportunidad.CEN_onbase_id_bandeja__c)  ) || String.isNotBlank(String.valueOf(oportunidad.CEN_onbase_id_bandeja_arras__c)) ) {
            respuesta.isVisible = true;
          }
          if (String.isNotBlank(oportunidad.CEN_Onbase_documento_id_arras__c) &&
            String.isBlank(oportunidad.CEN_sub_etapa_ARRAS__c)) {
            respuesta.esSolicitudOnbase = true;
          }
          respuesta.etapaEsPreliminar = (oportunidad.StageName == 'Preliminar' ? true : false);
          AggregateResult[] groupedResults = [SELECT SUM(CEN_Amount__c) payment FROM CEN_PaymentOrder__c WHERE CEN_PaymentStatus__c in ('Pagado')
            AND CEN_Opportunity__c =: OportunidadId
          ];
          Decimal paymentSum = (Decimal) groupedResults[0].get('payment');
          Decimal rounded = paymentSum != null? paymentSum.setScale(2) : 0;
         
          if (oportunidad.CEN_StatusLot__c == 'DE ARRAS A CVG' && String.isBlank(oportunidad.CEN_Onbase_documento_id_arras__c)) {
            respuesta.isVisible = false;
          } else if(!respuesta.isVisible){
            respuesta.isVisible = rounded >= (oportunidad.CEN_Monto_cuota_de_inicial_de_precio__c).setScale(2) ? true : false;
          }

          if (String.isBlank(oportunidad.CEN_Onbase_documento_id_arras__c)) {
            respuesta.noTieneContrato = true;
          }
          respuesta.esSolicitudOnBaseArras = String.isNotBlank(oportunidad.CEN_sub_etapa_ARRAS__c) ? true : false;
        }
        
        return respuesta;
      }
      //  GENERAR CONTENIDO PARA ONBASE
      @TestVisible
      private static String generarContenidoSolicitudOnbase(
        Response respuesta,
        Opportunity oportunidad,
        Boolean esParaActualizar
      ) {
        String body = '';
        respuesta.listaFaltantes = new List < FaltantesWrapper > ();
        if (oportunidad.AccountId != null && oportunidad.Account.IsPersonAccount) {
          CEN_cls_solicitudNatural obj = new CEN_cls_solicitudNatural(
            oportunidad.Id,
            esParaActualizar
          );
          //  validar si hay registros faltantes
          if (obj.mapEntidad_faltantes != null && !obj.mapEntidad_faltantes.isEmpty()) {
              for (String key: obj.mapEntidad_faltantes.keySet()) {
              respuesta.listaFaltantes.add(new FaltantesWrapper(key,String.join(obj.mapEntidad_faltantes.get(key), ', ')));
            }
          }
          //  validar si los registros encontrados les falta campos
          obj.validarData();
          if (obj.mapEntidad_faltantes != null && !obj.mapEntidad_faltantes.isEmpty()) {
              for (String key: obj.mapEntidad_faltantes.keySet()) {
              respuesta.listaFaltantes.add(new FaltantesWrapper(key,String.join(obj.mapEntidad_faltantes.get(key), ', ')) );
            }
          }
          if (respuesta.listaFaltantes != null && respuesta.listaFaltantes.isEmpty()) {
            //  set la data que si supero
            obj.setData();
            body = obj.getXMLsolicitud();
          }
        } else if (oportunidad.AccountId != null && !oportunidad.Account.IsPersonAccount) {
          CEN_cls_solicitudJuridica obj = new CEN_cls_solicitudJuridica(
            oportunidad.Id,
            esParaActualizar
          );
          if (obj.mapEntidad_faltantes != null && !obj.mapEntidad_faltantes.isEmpty()) {
            for (String key: obj.mapEntidad_faltantes.keySet()) {
              respuesta.listaFaltantes.add( new FaltantesWrapper(key,String.join(obj.mapEntidad_faltantes.get(key), ', ')));
            }
          }
          //  validar si los registros encontrados les falta campos
          obj.validarData();
          if ( obj.mapEntidad_faltantes != null && !obj.mapEntidad_faltantes.isEmpty() ) {
            for (String key: obj.mapEntidad_faltantes.keySet()) {
              respuesta.listaFaltantes.add(new FaltantesWrapper(key,String.join(obj.mapEntidad_faltantes.get(key), ', ')));
            }
          }
            system.debug('ERROR TEST AQUI: ' + respuesta.listaFaltantes);
          if (
            respuesta.listaFaltantes != null && respuesta.listaFaltantes.isEmpty()
          ) {
            //  set la data que si supero
            obj.setData();
            body = obj.getXMLsolicitud();
          }
        }
        return body;
      }
      //  CREAR SOLICITUD DE OPORTUNIDAD EN ONBASE
      @AuraEnabled
      public static Response enviarOportunidad_a_OnBase(String OportunidadId) {
        System.debug('<!--enviarOportunidad_a_OnBase inicia ' + OportunidadId);
        Response respuesta = new Response();
        respuesta.estado = 'error';
        respuesta.mensaje = 'Hubo un problema. Por favor, inténtelo más tarde.';
        respuesta.url = '';
    
        Opportunity oportunidad = null;
        try {
          oportunidad = [
            SELECT Id, OwnerId, AccountId, Account.IsPersonAccount
            FROM Opportunity
            WHERE Id =: OportunidadId
            LIMIT 1
          ];
        } catch (Exception ex) {System.debug('Exception trying get data: ' + ex.getMessage() +'. Line: ' +ex.getLineNumber() +'. Type: ' +ex.getTypeName());}
        //  VALIDACION DE ENTRADA
        if (
          oportunidad != null &&
          oportunidad.OwnerId != System.UserInfo.getUserId()
        ) {
          respuesta.oportunidad = oportunidad;
          respuesta.mensaje = 'No puede enviarse a Onbase. Debe ser el propietario de la Oportunidad.';
          return respuesta;
        }
        String body = '';
        try {
          body = generarContenidoSolicitudOnbase(respuesta, oportunidad, false);
            system.debug('Entrada xml: ' + body);
        } catch (Exception ex) {
          System.debug('Exception generando data xml: ' +ex.getMessage() +'. Line: ' +ex.getLineNumber() +'. Type: ' +ex.getTypeName());
          respuesta.oportunidad = oportunidad;
          respuesta.mensaje = 'No puede enviarse a Onbase. Ocurrió un error tratando los datos.';
          respuesta.detalle =
            respuesta.mensaje +
            ex.getMessage() +
            ex.getStackTraceString();
          return respuesta;
        }
    
        System.debug(LoggingLevel.FINEST, body);
        if (!respuesta.listaFaltantes.isEmpty()) {
          respuesta.faltanCampos = true;
          respuesta.mensaje = 'No puede enviarse a Onbase. Al parecer faltan algunos datos. ';
          respuesta.detalle = respuesta.mensaje;
          return respuesta;
        }
    
        CEN_WS_SolicitudContratoVenta service = new CEN_WS_SolicitudContratoVenta();
        CEN_WS_SolicitudContratoVenta.ResponseController respuesta_api = service.M_GenerarSolicitudPreSolicitud(
          body
        );
        System.debug('ResponseAPI: ' + respuesta_api);
        if (respuesta_api.ok) {
          if (respuesta_api.responseSolicitud != null) {
            //  Actualizar oportunidad
            oportunidad = null;
            try {
              oportunidad = [
                SELECT
                Id,
                CEN_onbase_id_bandeja_arras__c,
                CEN_Onbase_documento_id_arras__c,
                CEN_Nro_solicitud_presolicitud_arras__c,
                CEN_Sub_estado__c,
                CEN_Bandeja_onbase_de_solicitud_arras__c,
                Description,
                CEN_Tipo_de_solicitud__c
                FROM Opportunity
                WHERE Id =: OportunidadId
                LIMIT 1
              ];
              respuesta.oportunidad = oportunidad;
            } catch (Exception ex) { System.debug('Exception trying get data: ' +ex.getMessage() +'. Line: ' +ex.getLineNumber() +'. Type: ' + ex.getTypeName());}
            if (oportunidad != null) {
              try {
                oportunidad.CEN_onbase_id_bandeja_arras__c = Decimal.valueOf(
                  respuesta_api.responseSolicitud.IDBandeja
                );
                oportunidad.CEN_Onbase_documento_id_arras__c = respuesta_api.responseSolicitud.IDDocumento;
                oportunidad.CEN_Nro_solicitud_presolicitud_arras__c = respuesta_api.responseSolicitud.NroSolicitud;
                respuesta.oportunidad = oportunidad;
                update oportunidad;
                respuesta.oportunidad = oportunidad;
              } catch (Exception ex) {System.debug( 'Exception trying set data: ' +ex.getMessage() +'. Line: ' + ex.getLineNumber() +'. Type: ' + ex.getTypeName());}
              respuesta.estado = 'OK';
              respuesta.mensaje = 'Se envió exitósamente';
              respuesta.url =
                label.CEN_url_bandeja_onbase +
                label.CEN_lbl_rutaAppOnbase +
                '/Workflow/WFLogin.aspx?LifeCycleID=' +
                label.CEN_onbase_Id_ciclovida +
                '&QueueID=' +
                respuesta_api.responseSolicitud.IDBandeja +
                '&DocID=' +
                respuesta_api.responseSolicitud.IDDocumento;
              oportunidad.CEN_Link_Solicitud_Arras__c = respuesta.url;
              update oportunidad;
            }
          }
        } else {
          respuesta.mensaje = respuesta_api.message;
        }
        System.debug('respuesta: ' + respuesta);
        System.debug('-->enviarOportunidad_a_OnBase termina ' + OportunidadId);
        return respuesta;
      }
      //  enviar la solicitud a onbase para actualizar
      @AuraEnabled
      public static Response enviarActualizacionSolicitudOnbase(
        String OportunidadId
      ) {
        System.debug('<!--enviarActualizacionSolicitudOnbase inicia ' + OportunidadId);
        Response respuesta = new Response();
        respuesta.estado = 'error';
        respuesta.mensaje = 'Hubo un problema. Por favor, inténtelo más tarde.';
        respuesta.url = '';
    
        Opportunity oportunidad = null;
        try {
          oportunidad = [
            SELECT
            Id,
            OwnerId,
            AccountId,
            Account.IsPersonAccount,
            StageName,
            CEN_Sub_estado__c
            FROM Opportunity
            WHERE Id =: OportunidadId
            LIMIT 1
          ];
        } catch (Exception ex) {System.debug('Exception trying get data: ' +ex.getMessage() +'. Line: ' +ex.getLineNumber() +'. Type: ' +ex.getTypeName());}
        //  VALIDACION DE LIMITAR ACTUALIZACION A CIERTO SUB ESTADO 'PEND. ADJ. ARCH.', 'OBSERVADO', 'ATENDIDO'
        if (oportunidad != null && oportunidad.StageName == 'Preliminar' && !listaEstadoPermitidos.contains(oportunidad.CEN_Sub_estado__c)){
          respuesta.oportunidad = oportunidad;
          respuesta.mensaje =
            'No puede enviarse a actualizar a Onbase. El estado de la solicitud debe ser: ' +
            String.join(listaEstadoPermitidosString, ',');
          respuesta.detalle = respuesta.mensaje;
          return respuesta;
        } else if (oportunidad != null && oportunidad.StageName != 'Preliminar') {
          respuesta.oportunidad = oportunidad;
          respuesta.mensaje =
            'No puede enviarse a actualizar a Onbase. La etapa de la solicitud debe ser Preliminar.';
          respuesta.detalle = respuesta.mensaje;
          return respuesta;
        }
        //  VALIDACION DE PROPIEDAD
        if (oportunidad != null && oportunidad.OwnerId != System.UserInfo.getUserId() ) {
          respuesta.oportunidad = oportunidad;
          respuesta.mensaje = 'No puede enviarse a Onbase. Debe ser el propietario de la Oportunidad.';
          return respuesta;
        }
        String body = '';
        try {
          body = generarContenidoSolicitudOnbase(respuesta, oportunidad, true);
        } catch (Exception ex) {
          System.debug('Exception generando data xml: ' +ex.getMessage() +'. Line: ' + ex.getLineNumber() + '. Type: ' + ex.getTypeName());
          respuesta.oportunidad = oportunidad;
          respuesta.mensaje = 'No puede enviarse a Onbase. Ocurrió un error tratando los datos.';
          respuesta.detalle = respuesta.mensaje + ex.getMessage();
          return respuesta;
        }
        System.debug(LoggingLevel.FINEST, body);
        if (!respuesta.listaFaltantes.isEmpty()) {
          respuesta.faltanCampos = true;
          respuesta.mensaje = 'No puede enviarse a Onbase. Al parecer faltan algunos datos. ';
          respuesta.detalle = respuesta.mensaje;
          return respuesta;
        }
    
        CEN_WS_SolicitudContratoVenta service = new CEN_WS_SolicitudContratoVenta();
        CEN_WS_SolicitudContratoVenta.ResponseController respuesta_api = service.M_ActualizarSolicitudPreSolicitud(
          body
        );
        if (respuesta_api.ok) {
          if (respuesta_api.responseUpdateSolicitud != null) {
            //  Actualizar oportunidad
            oportunidad = null;
            try {
              oportunidad = [
                SELECT
                Id,
                CEN_onbase_id_bandeja_arras__c,
                CEN_Onbase_documento_id_arras__c,
                CEN_Nro_solicitud_presolicitud_arras__c,
                CEN_Sub_estado__c,
                CEN_Bandeja_onbase_de_solicitud_arras__c,
                Description,
                CEN_Tipo_de_solicitud__c,
                CEN_Link_Solicitud_arras__c
                FROM Opportunity
                WHERE Id =: OportunidadId
                LIMIT 1
              ];
              respuesta.oportunidad = oportunidad;
            } catch (Exception ex) {System.debug('Exception trying get data: ' + ex.getMessage() + '. Line: ' + ex.getLineNumber() +'. Type: ' +ex.getTypeName());}
            if (oportunidad != null) {
              respuesta.estado = 'OK';
              respuesta.mensaje = 'Se envió exitósamente';
              respuesta.url = oportunidad.CEN_Link_Solicitud_arras__c;
            }
          }
        } else {
          respuesta.mensaje = respuesta_api.message;
        }
        System.debug('respuesta: ' + respuesta);
        System.debug('-->enviarActualizacionSolicitudOnbase termina ' + OportunidadId);
        return respuesta;
      }
      //  ver la solicitude de onbase
      @AuraEnabled
      public static Response abrirSolicitud_en_OnBase(String OportunidadId) {
        System.debug('<!--abrirSolicitud_en_OnBase inicia ' + OportunidadId);
        Response respuesta = new Response();
        respuesta.estado = 'error';
        respuesta.mensaje = 'Hubo un problema. Por favor, inténtelo más tarde.';
        respuesta.url = '';
        String idbandeja = '';
        Opportunity oportunidad = null;
        try {
          oportunidad = [
            SELECT
            Id,
            CEN_onbase_id_bandeja_arras__c,
            CEN_Onbase_documento_id_arras__c,
            CEN_Nro_solicitud_presolicitud_arras__c,
            CEN_Tipo_de_solicitud__c,
            CEN_Link_Solicitud_arras__c
            FROM Opportunity
            WHERE Id =: OportunidadId
            LIMIT 1
          ];
          respuesta.oportunidad = oportunidad;
        } catch (Exception ex) {System.debug('Exception trying get data: ' +ex.getMessage() + '. Line: ' + ex.getLineNumber() + '. Type: ' +ex.getTypeName()); }
        if (oportunidad != null) {
          if (String.isNotBlank(oportunidad.CEN_Link_Solicitud_arras__c)) {
            respuesta.estado = 'OK';
            respuesta.mensaje = '';
            respuesta.url = oportunidad.CEN_Link_Solicitud_arras__c;
          } else if (
            String.isNotBlank(
              String.valueOf(oportunidad.CEN_onbase_id_bandeja_arras__c)
            ) &&
            String.isNotBlank(oportunidad.CEN_Onbase_documento_id_arras__c) &&
            String.isNotBlank(oportunidad.CEN_Nro_solicitud_presolicitud_arras__c)
          ) {
            idbandeja = String.valueOf(
              Integer.valueOf(oportunidad.CEN_onbase_id_bandeja_arras__c)
            );
            respuesta.estado = 'OK';
            respuesta.mensaje = '';
            respuesta.url = label.CEN_url_bandeja_onbase +label.CEN_lbl_rutaAppOnbase + '/Workflow/WFLogin.aspx?LifeCycleID=' + label.CEN_onbase_Id_ciclovida + '&QueueID=' +idbandeja +'&DocID=' + oportunidad.CEN_Onbase_documento_id_arras__c;
            oportunidad.CEN_Link_Solicitud_Arras__c = respuesta.url;
            update oportunidad;
          }
        }
        System.debug('-->abrirSolicitud_en_OnBase termina ' + OportunidadId);
        return respuesta;
      }
      //  ver los documentos de onbase
      @AuraEnabled
      public static Response abrirDocumentos_en_Onbase(String OportunidadId) {
        System.debug('<!--abrirDocumentos_en_Onbase inicia ' + OportunidadId);
        Response respuesta = new Response();
        respuesta.estado = 'error';
        respuesta.mensaje = 'Hubo un problema. Por favor, inténtelo más tarde.';
        respuesta.url = '';
        Opportunity oportunidad = null;
        try {
          oportunidad = [
            SELECT
            Id,
            CEN_onbase_id_bandeja_arras__c,
            CEN_Onbase_documento_id_arras__c,
            CEN_Nro_solicitud_presolicitud_arras__c,
            CEN_Tipo_de_solicitud__c,
            AccountId,
            Account.IsPersonAccount,
            Account.CEN_Numero_de_documento_del__c,
            Account.CEN_N_mero_de_documento__pc
            FROM Opportunity
            WHERE Id =: OportunidadId
            LIMIT 1
          ];
          respuesta.oportunidad = oportunidad;
        } catch (Exception ex) {System.debug('Exception trying get data: ' +ex.getMessage() +'. Line: ' + ex.getLineNumber() +'. Type: ' + ex.getTypeName()); }
        if (
          oportunidad != null &&
          String.isNotBlank(
            String.valueOf(oportunidad.CEN_Nro_solicitud_presolicitud_arras__c)
          ) &&
          String.isNotBlank(oportunidad.AccountId)
        ) {
          respuesta.estado = 'OK';
          respuesta.mensaje = '';
          if (oportunidad.Account.IsPersonAccount) {
            respuesta.url =
              label.CEN_url_bandeja_onbase + label.CEN_lbl_rutaAppOnbase + label.CEN_Onbase_FP_p_natural;
            System.debug('respuesta.url inicial: ' + respuesta.url);
            if (String.isNotBlank(respuesta.url)) {
              respuesta.url = respuesta.url.replace('YYYYY',oportunidad.Account.CEN_N_mero_de_documento__pc);
              respuesta.url = respuesta.url.replace('XXXXX',oportunidad.CEN_Nro_solicitud_presolicitud_arras__c);
              System.debug('respuesta.url tratado: ' + respuesta.url);
            }
          } else {
            respuesta.url =label.CEN_url_bandeja_onbase + label.CEN_lbl_rutaAppOnbase + label.CEN_Onbase_FP_p_juridica;
            System.debug('respuesta.url inicial: ' + respuesta.url);
            if (String.isNotBlank(respuesta.url)) {
              respuesta.url = respuesta.url.replace('YYYYY', oportunidad.Account.CEN_Numero_de_documento_del__c);
              respuesta.url = respuesta.url.replace( 'XXXXX',oportunidad.CEN_Nro_solicitud_presolicitud_arras__c );
              System.debug('respuesta.url tratado: ' + respuesta.url);
            }
          }
        }
        System.debug('-->abrirDocumentos_en_Onbase termina ' + OportunidadId);
        return respuesta;
      }
    
      public class Response {
        @AuraEnabled
        public String estado { get; set; }
        @AuraEnabled
        public String mensaje { get; set; }
        @AuraEnabled
        public String detalle { get; set; }
        @AuraEnabled
        public String url { get; set; }
        @AuraEnabled
        public Opportunity oportunidad { get; set; }
        @AuraEnabled
        public List<FaltantesWrapper> listaFaltantes { get; set; }
        @AuraEnabled
        public Boolean faltanCampos { get; set; }
      }
      public class ResponseInit {
        @AuraEnabled
        public Boolean esSolicitudOnbase { get; set; }
        @AuraEnabled
        public Boolean etapaEsPreliminar { get; set; }
        @AuraEnabled
        public Boolean isVisible { get; set; }
        @AuraEnabled
        public Opportunity oportunidad { get; set; }
        @AuraEnabled
        public Boolean noTieneContrato { get; set; }
        @AuraEnabled
        public Boolean esSolicitudOnBaseArras { get; set; }
      } 
      public class FaltantesWrapper {    
        @AuraEnabled
        public String key;
        @AuraEnabled
        public String camposFaltantes;
        public FaltantesWrapper(String key, String campos) {
          this.key = key;
          this.camposFaltantes = campos;
        }
      }
}