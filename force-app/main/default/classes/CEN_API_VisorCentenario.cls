@RestResource(urlMapping='/OpportunityLineItem/*')
global with sharing class CEN_API_VisorCentenario {
    //	Seteando el Pricebook2Id
    static Double cantidad = 1;
    
    @HttpPost
    global static void createOpportunityLineItem() {
        Boolean success = false;
        String jsonResponse = '';
               
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        res.headers.put('Content-Type','application/json;charset=UTF-8');
        //	READING DATA
        String OpportunityId = null;
        String CodLote = null;        

        System.debug('Body Request:' + req.requestBody.toString());
        RequestBodyObject body = (RequestBodyObject)JSON.deserialize(req.requestBody.toString(), RequestBodyObject.class);
        System.debug('Body Request:' + body);
        PricebookEntry libro_de_precios =null;
        Opportunity oportunidad = null;
        Product2 lote = null;
        Pricebook2 libro=null;    
        if(String.isBlank(body.OpportunityId) && String.isBlank(body.CodLote)){
            res.statusCode = 400;
            res.responseBody = Blob.valueOf('{"id":"","mensaje":"OpportunityId y CodLote son obligatorios."}');
        }else if(String.isBlank(body.CodLote)){
            res.statusCode = 400;
            res.responseBody = Blob.valueOf('{"id":"","mensaje":"CodLote es obligatorio."}');
        }else if(String.isBlank(body.OpportunityId)){
            res.statusCode = 400;
            res.responseBody = Blob.valueOf('{"id":"","mensaje":"OpportunityId es obligatorio."}');
        }else{
            try{
                lote = [SELECT Id, CODLOTE__c, CEN_PRECIOVENTAFUN__c, CEN_Proyecto__c FROM Product2 WHERE CODLOTE__c=:body.CodLote LIMIT 1];
            }catch(Exception ex){
                System.debug('ex: '+ex.getMessage()+'. Line: '+ex.getLineNumber());
            }
            if(lote==null){
                try{
                    String codlote_conv = String.valueOf(Integer.valueOf(body.CodLote));
                    lote = [SELECT Id, CODLOTE__c, CEN_PRECIOVENTAFUN__c, CEN_Proyecto__c FROM Product2 WHERE CODLOTE__c=:codlote_conv LIMIT 1];
                }catch(Exception ex){
                    System.debug('ex: '+ex.getMessage()+'. Line: '+ex.getLineNumber());
                    if(lote==null){
                        res.statusCode = 400;
                        res.responseBody = Blob.valueOf('{"id":"","mensaje":"No se encontró un Lote con el CodLote '+body.CodLote+'. '+ex.getMessage()+'"}');
                        return;
                    }
                }
            }
            try{
                //Reading data
                oportunidad = [SELECT Id, CEN_Proyecto__c FROM Opportunity WHERE Id=:body.OpportunityId LIMIT 1];
                if(Test.isRunningTest()){
                    libro = new Pricebook2(Id=Test.getStandardPricebookId());
                }else{
                    libro = [SELECT Id FROM Pricebook2 WHERE IsStandard=true LIMIT 1];
                }                
            }catch(Exception ex){
                res.statusCode = 400;
                if(oportunidad==null){                   
                    res.responseBody = Blob.valueOf('{"id":"","mensaje":"No se encontró una Oportunidad con el Id '+body.OpportunityId+'. '+ex.getMessage()+'"}');
                }else if(libro==null){
                    res.responseBody = Blob.valueOf('{"id":"","mensaje":"No se encontró un Libro de Precio estándar. '+ex.getMessage()+'"}');
                }
                return;
            }
            
            try{
                libro_de_precios = [SELECT Id, Pricebook2Id, Product2Id, UnitPrice FROM PricebookEntry WHERE Product2Id=:lote.Id LIMIT 1];
            }catch(Exception ex){
                if(libro_de_precios==null){
                    System.debug('Exception libro de precio estandar: '+ex.getMessage());
                }else{
                    System.debug('Exception: '+ex.getMessage());
                }
            }
            
            try{
                    //Set data into salesforce
                    if(libro_de_precios==null){
                        String precio_lote = lote.CEN_PRECIOVENTAFUN__c;
                        precio_lote = precio_lote.replace(',', '.');
                        precio_lote = precio_lote.replace(' ', '');
                        Decimal precio_de_venta_del_lote = Decimal.valueOf(precio_lote);
                        libro_de_precios = new PricebookEntry(Product2Id=lote.Id,
                                                              Pricebook2Id=libro.Id,
                                                              IsActive=true, 
                                                              UseStandardPrice=false,
                                                              UnitPrice=precio_de_venta_del_lote);
                        insert libro_de_precios;
                        PricebookEntry libro_de_precios_inserted = [SELECT Id FROM PricebookEntry WHERE Id=:libro_de_precios.Id LIMIT 1];
                        if(libro_de_precios_inserted.Id==null){
                            res.statusCode = 400;
                            res.responseBody = Blob.valueOf('{"id":"","mensaje":"No se pudo registrar un PricebookEntry necesario relacionado al Lote."}');
                            return;
                        }
                    }
                    //Save data
                    OpportunityLineItem oportunidad_lote = null;
                    try{
                        oportunidad_lote = [SELECT Id, OpportunityId, PricebookEntryId, Quantity, UnitPrice 
                                            FROM OpportunityLineItem WHERE OpportunityId=:oportunidad.Id AND PricebookEntryId=:libro_de_precios.Id LIMIT 1];
                    }catch(Exception ex){
                        System.debug('Ex: '+ex.getMessage()+'. Line: '+ex.getLineNumber());
                    }
                    if(oportunidad_lote==null){
                        oportunidad_lote = new OpportunityLineItem(OpportunityId=oportunidad.Id,
                                                                   PricebookEntryId=libro_de_precios.Id,
                                                                   Quantity=cantidad,
                                                                   Description='Origen: visor',
                                                                   UnitPrice=libro_de_precios.UnitPrice);
                        List<OpportunityLineItem> lotes_de_oportunidad = [SELECT Id, Description, OpportunityId 
                                                                          FROM OpportunityLineItem WHERE OpportunityId=:oportunidad.Id];
                        delete lotes_de_oportunidad;
                        insert oportunidad_lote;
                        oportunidad.CEN_Proyecto__c = lote.CEN_Proyecto__c;
                        oportunidad.CEN_con_lote_desde_visor__c =true;
                        update oportunidad;
                        if(oportunidad_lote.Id==null){
                            res.statusCode = 400;
                            res.responseBody = Blob.valueOf('{"id":"","mensaje":"No se pudo registrar un Lote relacionado a la Oportunidad."}');
                            return;
                        }else{
                            res.statusCode = 201;
                            res.responseBody = Blob.valueOf('{"id":"'+oportunidad_lote.Id+'","mensaje":"El Lote '+body.CodLote+
                                                            ' fue relacionado con la Oportunidad '+body.OpportunityId+
                                                            ' exitosamente. Creando el Lote de Oportunidad '+oportunidad_lote.Id+'."}');
                            return;
                        }
                    }else{
                        res.statusCode = 201;
                        res.responseBody = Blob.valueOf('{"id":"'+oportunidad_lote.Id+'","mensaje":"El Lote '+body.CodLote+
                                                        ' fue relacionado con la Oportunidad '+body.OpportunityId+
                                                        ' exitosamente. Creando el Lote de Oportunidad '+oportunidad_lote.Id+'."}');
                        return;
                    }           
            }catch(Exception ex){
                res.statusCode = 400;
            	res.responseBody = Blob.valueOf('{"id":"","mensaje":"'+ex.getMessage()+'"}');
            }
        }
        return;
    }   
    global class RequestBodyObject{
        String OpportunityId{get; set;}
        String CodLote{get; set;}
    }    
}