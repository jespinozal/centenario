/*
 * @Version: v.1.1
 * @Autor: Adolfo Crispin - Protiviti
 * @Ultima Modificacion: 27/05/2020 
*/
public class CEN_cls_Agregar_Lote_Interaccion {
   
    public class Response{
        @AuraEnabled public String estado {get;set;}
        @AuraEnabled public String mensaje {get;set;}
        @AuraEnabled public List<Product2> lotes {get;set;}
        @AuraEnabled public List<Lote> lotesstr {get;set;}
        @AuraEnabled public Case caso {get;set;}
    }
    public class Lote{
        @AuraEnabled public String Id {get;set;}
        @AuraEnabled public String Name {get;set;}
        @AuraEnabled public String Url {get;set;}
        @AuraEnabled public String Origen {get;set;}
        @AuraEnabled public Boolean EnabledView {get;set;}
    }
    @AuraEnabled
    public static Response GetDataCase(String caseId){
        Response respuesta = new Response();
        respuesta.estado='ERROR';
        respuesta.mensaje='No se pudo encontrar los lotes del contacto.';
        respuesta.lotes = new List<Product2>();
        respuesta.lotesstr = new List<Lote>();
        List<CEN_WS_Lotes_por_Cliente.ZGR_SF_INFO_LOTES> lotes = null;
        Case caso = null;
        try{
            caso = [SELECT Id, AccountId, Account.Name, Account.PersonContactId, ContactId, Contact.Name, Contact.AccountId, CEN_Lotes__c FROM Case WHERE Id=:caseId LIMIT 1];
            respuesta.caso= caso;
            respuesta.estado='OK';
            respuesta.mensaje='';
            if(String.isNotBlank(caso.CEN_Lotes__c)){
                System.debug('Lotes: '+caso.CEN_Lotes__c);
                respuesta.lotesstr=unParseLotes(caso.CEN_Lotes__c);      
                System.debug('respuesta.lotes: '+respuesta.lotesstr);
            }
        }catch(Exception ex){
            System.debug('Exception ex: '+ex.getMessage()+'. Line: '+ex.getLineNumber()+'. Type: '+ex.getTypeName());
        }
        return respuesta;
    }
    public static List<Lote> unParseLotes(String CEN_Lotes){
        List<Lote> lotes = new List<Lote>();
        if(String.isNotBlank(CEN_Lotes)){
            Map<String, Object> lotes_map = (Map<String,Object>)JSON.deserializeUntyped(CEN_Lotes);        
            System.debug('respuesta.lotes: '+lotes_map);
            System.debug('respuesta.lotes.size: '+lotes_map.size());
            for(Object obj:lotes_map.values()){
                Map<String, Object> onj = (Map<String, Object>)obj;
                Lote lt = new Lote();
                lt.Id = String.valueOf(onj.get('Id'));
                lt.Name = String.valueOf(onj.get('Name'));
                lt.Origen = String.valueOf(onj.get('Origen'));
                //	*** Para lotes registrados en el caso previamente a v.1.1
                if(String.isBlank(lt.Origen)){
                    lt.Origen = 'SAP';
                }
                //	***
                if(String.isBlank(lt.Id)||(lt.Id!=null&&lt.Id.indexOf('undefined')>-1)){
                    lt.EnabledView=false;
                    lt.Url='';
                }else{
                    lt.EnabledView=true;
                    lt.Url='/lightning/r/'+lt.Id+'/view';
                }
                lotes.add(lt);
            }
        }
        System.debug('lotes.size: '+lotes.size());
        return lotes;
    }
    @AuraEnabled
    public static Response BuscarLotesPorCasoTipoCliente(String caseId, String tipo){        
        Response respuesta = new Response();
        List<CEN_WS_Lotes_por_Cliente.ZGR_SF_INFO_LOTES> lotes = null;
        if(String.isNotBlank(caseId)&&String.isNotBlank(tipo)){
            Case caso = null;
            try{
                caso = [SELECT Id, AccountId, Account.Name, Account.CEN_N_mero_de_documento__pc, Account.CEN_Numero_de_documento_del__c, 
                        Account.CEN_Tipo_de_documento__c, Account.CEN_Tipo_de_documento__pc, Account.IsPersonAccount, Account.Comentario__c, 
                        Account.CEN_Origen__c, ContactId, Contact.Name, Contact.CEN_Tipo_de_documento__c, 
                        Contact.CEN_N_mero_de_documento__c, Contact.AccountId FROM Case WHERE Id=:caseId LIMIT 1];
                System.debug('Caso: '+caso);
                if(tipo=='CT'){
                    System.debug('CEN_Lotes_Cliente.LotesPorClientSAP('+caso.Contact.CEN_Tipo_de_documento__c+', '+caso.Contact.CEN_N_mero_de_documento__c+');');
                    lotes = CEN_Lotes_Cliente.LotesPorClientSAP(caso.Contact.CEN_Tipo_de_documento__c, caso.Contact.CEN_N_mero_de_documento__c);
                    if(caso.Contact.AccountId==caso.AccountId){
                        respuesta.lotesstr = getLotesOracleFromComentariosCuenta(caso.Account);
                    }else{
                        try{
                            Account cuenta_del_contacto = [SELECT Id,CEN_Origen__c, Comentario__c FROM Account WHERE Id=:caso.Contact.AccountId LIMIT 1];
                            respuesta.lotesstr = getLotesOracleFromComentariosCuenta(cuenta_del_contacto);
                        }catch(Exception ex){
                            System.debug('Exception ex: '+ex.getMessage()+'. Line: '+ex.getLineNumber()+'. Type: '+ex.getTypeName());
                        }                        
                    }
                }
                else{
                    if(caso.AccountId!=null&&caso.Account.IsPersonAccount){
                        System.debug('CEN_Lotes_Cliente.LotesPorClientSAP('+caso.Account.CEN_Tipo_de_documento__pc+', '+caso.Account.CEN_N_mero_de_documento__pc+');');
                        lotes = CEN_Lotes_Cliente.LotesPorClientSAP(caso.Account.CEN_Tipo_de_documento__pc, caso.Account.CEN_N_mero_de_documento__pc);
                    }else if(caso.AccountId!=null){
                        System.debug('CEN_Lotes_Cliente.LotesPorClientSAP('+caso.Account.CEN_Tipo_de_documento__c+', '+caso.Account.CEN_Numero_de_documento_del__c+');');
                        lotes = CEN_Lotes_Cliente.LotesPorClientSAP(caso.Account.CEN_Tipo_de_documento__c, caso.Account.CEN_Numero_de_documento_del__c);
                    }
                    respuesta.lotesstr = getLotesOracleFromComentariosCuenta(caso.Account);
                }                
                if(lotes!=null){
                    System.debug('lotes.size para '+tipo+': '+lotes.size());
                    List<String> cod_lotes= new List<String>();
                    for(CEN_WS_Lotes_por_Cliente.ZGR_SF_INFO_LOTES lote_sap:lotes){
                        cod_lotes.add(String.valueOf(Integer.valueOf(lote_sap.ID_MATERIAL)));
                    }
                    respuesta.lotes = [SELECT Id, Name, CEN_Proyecto__r.Name, DESCRIPCIONLOTE__c, DESCRIPCIONCORTA__c, CODLOTE__c, CODESTADOLOTE__c 
                                       FROM Product2 WHERE CODLOTE__c IN :cod_lotes LIMIT 45000];
                }
            }catch(Exception ex){
                System.debug('Exception ex: '+ex.getMessage()+'. Line: '+ex.getLineNumber()+'. Type: '+ex.getTypeName());
            }        
            if((respuesta.lotes==null||respuesta.lotes.size()==0)&&(respuesta.lotesstr==null||respuesta.lotesstr.size()==0)){
                respuesta.estado='ERROR';
                respuesta.mensaje='No se pudo encontrar los lotes.';
                respuesta.lotes = new List<Product2>();
            }else{
                respuesta.estado='OK';
                respuesta.mensaje='';
            }
        }else{
            respuesta.estado='ERROR';
            respuesta.mensaje='Hubo un problema. Por favor, intentelo otra vez.';
            respuesta.lotes = new List<Product2>();
        }
        return respuesta;
    }   
    @AuraEnabled
    public static Response ActualizarLotes(String caseId, List<Lote> lotes){
        Response respuesta = new Response();
        System.debug('caseid: '+caseId);
        respuesta.estado='ERROR';
        Case caso = null;
        try{
            caso = [SELECT Id, ProductId, CEN_Lotes__c, CEN_Lotes_asignados__c FROM Case WHERE Id=:caseId LIMIT 1];
        }catch(Exception ex){
            System.debug('Exception ex: '+ex.getMessage()+'. Line: '+ex.getLineNumber()+'. Type: '+ex.getTypeName());
            respuesta.mensaje='No se encontró la interacción.';
        }
        System.debug('lotes: '+lotes);
        if(lotes==null||lotes.size()==0){
            try{
                caso.ProductId=null;
                caso.CEN_Lotes__c = null;
                caso.CEN_Lotes_asignados__c = null;
                update caso;
                 respuesta.estado='OK';
                respuesta.mensaje='Se actualizó la interacción.';
            }catch(Exception ex){
                System.debug('Exception ex: '+ex.getMessage()+'. Line: '+ex.getLineNumber()+'. Type: '+ex.getTypeName());
                respuesta.mensaje='No se pudo actualizar la interacción.';
        	} 
        }else{
            String lotesConcatenados='';
            Map<String, Lote> lotes_map = new Map<String,Lote>();
            for(Lote lt: lotes){
                lotes_map.put(lt.Id, lt);
                lotesConcatenados+=lt.Name+'/';
            }
            Product2 lote = null;
            try{
                lote = [SELECT Id FROM Product2 WHERE Id=:lotes[0].Id];
            }catch(Exception ex){
                System.debug('Exception no se encontro lote: '+ex.getMessage()+'. Line: '+ex.getLineNumber()+'. Type: '+ex.getTypeName());
            }   
            try{                
                if(lote!=null){
                    caso.ProductId=lotes[0].Id;
                }else{
                    caso.ProductId = null;
                }
                caso.CEN_Lotes__c = JSON.serializePretty(lotes_map);
                caso.CEN_Lotes_asignados__c = lotesConcatenados;
                System.debug('caso.CEN_Lotes__c: '+caso.CEN_Lotes__c);
                System.debug('caso.CEN_Lotes_asignados__c: '+caso.CEN_Lotes_asignados__c);
                update caso;
                respuesta.estado='OK';
                respuesta.mensaje='Se actualizó la interacción.';
            }catch(Exception ex){
                System.debug('Exception ex: '+ex.getMessage()+'. Line: '+ex.getLineNumber()+'. Type: '+ex.getTypeName());
                respuesta.mensaje='No se pudo actualizar la interacción. '+ex.getMessage();
            }   
        }        
        return respuesta;
    }
    @AuraEnabled
    public static List<Lote> getDataCliente(String recordId){
        System.debug('<!--getDataCliente recordId: '+recordId);
        List<Lote> lotes = new List<Lote>();
        List<CEN_WS_Lotes_por_Cliente.ZGR_SF_INFO_LOTES> lotessap = null;
        if(String.isNotBlank(recordId)){
            Account cuenta = null;
            try{
                cuenta = [SELECT Id, CEN_Tipo_de_documento__pc, CEN_Tipo_de_documento__c, CEN_N_mero_de_documento__pc, CEN_Origen__c, 
                          CEN_Numero_de_documento_del__c, CreatedDate, Name, IsPersonAccount, Comentario__c FROM Account WHERE Id=:recordId LIMIT 1];
                if(cuenta!=null&&cuenta.IsPersonAccount){
                    System.debug('CEN_Lotes_Cliente.LotesPorClientSAP('+cuenta.CEN_Tipo_de_documento__pc+', '+cuenta.CEN_N_mero_de_documento__pc+');');
                    lotessap = CEN_Lotes_Cliente.LotesPorClientSAP(cuenta.CEN_Tipo_de_documento__pc, cuenta.CEN_N_mero_de_documento__pc);
                }else{
                    System.debug('CEN_Lotes_Cliente.LotesPorClientSAP('+cuenta.CEN_Tipo_de_documento__c+', '+cuenta.CEN_Numero_de_documento_del__c+');');
                    lotessap = CEN_Lotes_Cliente.LotesPorClientSAP(cuenta.CEN_Tipo_de_documento__c, cuenta.CEN_Numero_de_documento_del__c);
                }
            }catch(Exception ex){
                System.debug('Exception ex: '+ex.getMessage()+'. Line: '+ex.getLineNumber()+'. Type: '+ex.getTypeName());
            }
            if(lotessap!=null&&lotessap.size()>0){
                System.debug('lotessap.size:'+lotessap.size());
                List<String> cod_lotes= new List<String>();
                for(CEN_WS_Lotes_por_Cliente.ZGR_SF_INFO_LOTES lote_sap:lotessap){
                    if(String.isNotBlank(lote_sap.ID_MATERIAL)){
                        cod_lotes.add(String.valueOf(Integer.valueOf(lote_sap.ID_MATERIAL)));
                    }else if(String.isNotBlank(lote_sap.DESCRIPCION_LARGA)){
                        cod_lotes.add(lote_sap.DESCRIPCION_LARGA);
                    }
                    
                }
                List<Product2> plotes = [SELECT Id, Name, CEN_Proyecto__r.Name, DESCRIPCIONLOTE__c, DESCRIPCIONCORTA__c, CODLOTE__c, CODESTADOLOTE__c 
                                         FROM Product2 WHERE CODLOTE__c IN :cod_lotes OR DESCRIPCIONLOTE__c IN: cod_lotes LIMIT 45000];
                for(Product2 prod:plotes){
                    Lote lt = new Lote();
                    lt.Id=prod.Id;
                    lt.Name = prod.DESCRIPCIONLOTE__c;
                    lt.Url='/lightning/r/'+prod.Id+'/view';
                    lt.Origen='SAP';
                    lt.EnabledView=true;
                    lotes.add(lt);
                }
            }

            List<Lote> lotesoracle = getLotesOracleFromComentariosCuenta(cuenta);
            if(lotesoracle!=null&&lotesoracle.size()>0){
                lotes.addAll(lotesoracle);
            }
           
        }
        System.debug('-->getDataCliente lotes.size(): '+(lotes!=null?lotes.size():0));
        return lotes;
    }
    
    private static List<Lote> getLotesOracleFromComentariosCuenta(Account cuenta){
        System.debug('Buscar lotes a cuenta de oracle');
        try{
            if(cuenta!=null&&String.isNotBlank(cuenta.Comentario__c)){
                    String comentario = cuenta.Comentario__c+'|||';
                    List<String> lstr = new List<String>();
                    String ltsq = '';
                    do{
                        ltsq = comentario.substringBefore('|||');   
                        if(String.isNotBlank(ltsq)){
                            lstr.add(ltsq);
                            comentario = comentario.remove(ltsq+'|||');
                        }
                    }while(String.isNotBlank(comentario)&&comentario!='|||');
                    List<String> lotesstr = new List<String>();
                    String lt_s_p='';
                    String lt_s='';
                    String lt_s_l='';
                    List<Lote> lotesoracle = new List<Lote>();
                    for(String lts:lstr){
                        lt_s=lts.substringBetween('Proyecto:', '|');
                        if(String.isNotBlank(lt_s)){
                            lt_s = lt_s.trim();
                            lt_s_p = lt_s.substringBefore(' Mz.');
                            lt_s_l = lt_s.remove(lt_s_p);
                            lt_s = WordToUpperCase.ConvertWord(lt_s_p)+lt_s_l;
                            Lote lt = new Lote();
                            lt.Name = lt_s.trim();
                            lt.Url='';
                            lt.Origen='Oracle';
                            lt.EnabledView=false;
                            lotesoracle.add(lt);
                            lotesstr.add(lt_s);
                        }
                    }
                    System.debug('lotesstr: '+lotesstr);
                    if(lotesstr.size()>0){
                        List<Product2> plotes = [SELECT Id, Name, CEN_Proyecto__r.Name, DESCRIPCIONLOTE__c, DESCRIPCIONCORTA__c, CODLOTE__c, CODESTADOLOTE__c 
                                             FROM Product2 WHERE DESCRIPCIONLOTE__c IN :lotesstr LIMIT 45000];
                        if(plotes.size()>0){
                            lotesoracle = new List<Lote>();
                            for(Product2 prod:plotes){
                                Lote lt = new Lote();
                                lt.Id=prod.Id;
                                lt.Name = prod.DESCRIPCIONLOTE__c;
                                lt.Url='/lightning/r/'+prod.Id+'/view';
                                lt.Origen='Oracle';
                                lt.EnabledView=true;
                                lotesoracle.add(lt);
                            }
                        }
                    }
                    return lotesoracle;
                }
        }catch(Exception ex){
            System.debug('Exception: '+ex.getMessage()+'. Line: '+ex.getLineNumber()+'. Type: '+ex.getTypeName());
        }
        return null;
    }
}