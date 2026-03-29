public class CEN_Campana_ctr {


    public class wrapCampanas {

        @AuraEnabled
        public String COD_CAMPANA;
        @AuraEnabled
        public String NOM_CAMPANA;
        @AuraEnabled
        public String NIVEL;
        @AuraEnabled
        public String MOTIVO_CAMPANA;
        @AuraEnabled
        public String PALANCA_PRINCIPAL;
        @AuraEnabled
        public String INICIO_VIGENCIA;
        @AuraEnabled
        public String FIN_VIGENCIA;
        @AuraEnabled
        public String PORCENTAJE_DESCUENTO;
        @AuraEnabled
        public String IMPORTE;
        @AuraEnabled
        public String MONEDA;
        @AuraEnabled
        public String SUSTENTO;
        @AuraEnabled
        public String SOCIEDAD;
        @AuraEnabled
        public String PROYECTO;
    }
    
    public class respCampanaList {

        @AuraEnabled
        public List<wrapCampanas> strCampanaList {get; set;}
        @AuraEnabled
        public string msgResp {get; set;}
    }


    @AuraEnabled()
    public static respCampanaList getCampanaList(String oppId) {

        respCampanaList respCampana = new respCampanaList();

        //Consumo API
        List<wrapCampanas> lstResp = new List<wrapCampanas>();
        //CEN_AdvanceListObjectResponse resp = CEN_AdvanceList_cls.getAdvanceListbyClient(oppId);
        CEN_CampanaObjectResponse resp = CEN_Campana_cls.getCampanabyProject(oppId);
        //Obtenemos Lista de Campañas
        wrapCampanas wCampanas;
        if(resp.DETALLE_CAMPANA != null){

            for(CEN_CampanaObjectResponse.ZACCO_DETALLE_PALANCA r :resp.DETALLE_CAMPANA.item){

                wCampanas = new wrapCampanas();
                wCampanas.COD_CAMPANA = r.COD_CAMPANA;

                wCampanas.NOM_CAMPANA = r.NOM_CAMPANA;
                
                wCampanas.NIVEL = r.NIVEL;
                
                wCampanas.MOTIVO_CAMPANA = r.MOTIVO_CAMPANA;
                
                wCampanas.PALANCA_PRINCIPAL = r.PALANCA_PRINCIPAL;
                 
                string sString='';
                
                sString = r.INICIO_VIGENCIA;
                sString  = sString.replace('.','-');
                string[] splitted = sString.split('-');
                sString = splitted[2] + '-' + splitted[1] + '-' + splitted[0];
               // Date x = Date.valueOf(sString);
               // system.debug('Date.valueOf :' + x);
                
                wCampanas.INICIO_VIGENCIA =  sString ;

                sString = r.FIN_VIGENCIA;
                sString  = sString.replace('.','-');
                string[] splitted2 = sString.split('-');
                sString = splitted2[2] + '-' + splitted2[1] + '-' + splitted2[0];
              //  Date x2 = Date.valueOf(sString);
               // system.debug('Date.valueOf :' + x2);
                
                wCampanas.FIN_VIGENCIA = sString;
                
                wCampanas.PORCENTAJE_DESCUENTO = String.valueOf(Decimal.valueOf(r.PORCENTAJE_DESCUENTO)/100.00);
                
                
                wCampanas.IMPORTE = r.IMPORTE;
                
                wCampanas.MONEDA = r.MONEDA;
                
                wCampanas.SUSTENTO = r.SUSTENTO;
                
                wCampanas.SOCIEDAD = r.SOCIEDAD;
                
                wCampanas.PROYECTO = r.PROYECTO;
                    lstResp.add(wCampanas);
         
            }

        }

        system.debug('lstResp.size() : '+ lstResp.size());
        if(lstResp.size() > 0){
    
            respCampana.strCampanaList = lstResp;
        }else {
            respCampana.msgResp = JSON.serialize(resp);
        }
        system.debug('strCampanaList : '+ respCampana.strCampanaList);

        system.debug('msgResp : '+ respCampana.msgResp);

        system.debug('resp : ');

        system.debug(resp);

        return respCampana;
    }
    
}