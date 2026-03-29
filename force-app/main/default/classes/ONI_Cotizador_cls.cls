public with sharing class ONI_Cotizador_cls {


    public class LoteWrapper {
    public String zona;
    public String proyecto;
    public String sociedad;
    public String descripcionSociedad;
    public String descripcionTipologia;
    public String descripcionUbicacion;
    public String nroLotes;
    public String manzana;
    public String lote;
    public String estadoActualLote;
    public Decimal precioMt2;
    public Decimal areaMt2;
    public Decimal precioVenta;
    public String monedaLote;
    public String descripcionForma;
    public String tipologiaProductos;
    public String idCrm;

     public String codLote;
    public String codCompania;
    public String descripcionCorta;
    public String descripcionLote;
    public Integer idLote;
    public String linderoDerecha;
    public String linderoFondo;
    public String linderoFrente;
    public String linderoIzquierda;
    public String medidaDerecha;
    public String medidaFondo;
    public String medidaFrente;
    public String medidaIzquierda;

       
    }


    public static List<LoteWrapper> getLotesFromEndpoint(String proyecto) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();

        
        // Reemplaza con tu URL real y configura el Named Credential
        request.setEndpoint('callout:OFI_nc_SAPOficinaWs/sap/bc/rest/zws_lotes?sap-client=100');
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json');
        request.setBody(JSON.serialize(new Map<String,String>{'proyecto'=>proyecto}));

        try {
            HttpResponse response = http.send(request);
            System.debug(response.getBody());
            if (response.getStatusCode() == 200) {
                return (List<LoteWrapper>) System.JSON.deserialize(response.getBody(), List<LoteWrapper>.class);
            } else {
                System.debug('Error en la respuesta: ' + response.getStatus());
                return new List<LoteWrapper>();
            }
        } catch (Exception e) {
            System.debug('Excepción durante la llamada: ' + e.getMessage());
            return new List<LoteWrapper>();
        }
    }




    public static List<PricebookEntry> addToPricebook(List<Product2> p2List,Pricebook2 pb){
        Id  standardPricebookId = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1].Id;
        List<PricebookEntry> speList = new List<PricebookEntry>();
        List<PricebookEntry> pbeList = new List<PricebookEntry>();
        
        for(Product2 p2:p2List){

        PricebookEntry spe = new PricebookEntry(
                    Pricebook2Id = standardPricebookId,
                    Product2Id = p2.Id,
                    UnitPrice = Decimal.valueOf(p2.CEN_PRECIOVENTAFUN__c),
                    IsActive = false
                );
                speList.add(spe);


                PricebookEntry pbe = new PricebookEntry(
                    Product2Id=p2.Id,
                    Pricebook2Id=pb.Id,
                    UnitPrice=Decimal.valueOf(p2.CEN_PRECIOVENTAFUN__c),
                    IsActive=true
                    );
                pbeList.add(pbe);

        }

        Database.insert(speList,AccessLevel.SYSTEM_MODE);
        Database.insert(pbeList,AccessLevel.SYSTEM_MODE);

        List<Id> idList = new List<Id>();
        for(PricebookEntry pbe:pbeList){
            idList.add(pbe.Id);
        }
        
        return  [SELECT Id,Product2Id,Product2.CEN_PRECIOVENTAFUN__c,Product2.Name,Product2.CODLOTE__c FROM PricebookEntry  WHERE Id IN :idList AND IsActive=true WITH USER_MODE];

        
    }

    public static Boolean isNumber(String input) {
        if (input == null || String.isBlank(input)) {
            return false;
        }
        try {
            Decimal.valueOf(input);
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    @AuraEnabled
    public static Boolean save(Id opportunityId,List<String> lotList,Map<String,String> qData,Map<String,List<String>> qliPrice,Boolean isIndustrial){
        System.debug('id1 Oppty: '+opportunityId);
        System.debug('id2 LotList: '+lotList);
        System.debug('id3: QLiPrc'+qliPrice);
        System.debug('id4: QData'+qData);

        Id recordTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName()
        .get(isIndustrial?'ONI_rt_Cotizacion_Industrial':'ONI_rt_Cotizacion_Oficina')
        ?.getRecordTypeId();

        System.debug('P1');
   //     Proyecto__c pro = [SELECT Id,CEN_CODIGOSAP__c FROM Proyecto__c WHERE Name = 'MacrOpolis' LIMIT 1];
        System.debug('P2');
        Pricebook2 pb2 ;
        System.debug('P3');
        if(isIndustrial){
            System.debug('P4');
            pb2 = [SELECT Id FROM Pricebook2 WHERE Name='MacrOpolis' WITH USER_MODE LIMIT 1];
            System.debug('P5');
        }else{
            System.debug('P6');
            pb2 = [SELECT Id FROM Pricebook2 WHERE Name='Oficinas' WITH USER_MODE LIMIT 1];
        }
        System.debug('P7');

        

        List<Product2> p2ListNew=new List<Product2>();
        //List<PricebookEntry> pbeListNew = new List<PricebookEntry>();
        List<Product2> p2ListE =[SELECT Id,CODLOTE__c FROM Product2 WHERE CODLOTE__c in:lotList WITH USER_MODE];
        List<String> p2CodeList = new List<String>();
        Map<String, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName();
        Id rtIndustrial = rtMap.get('OFI_rt_Product2_Industrial').getRecordTypeId();

        for(Product2 p2:p2ListE){
            p2CodeList.add(p2.CODLOTE__c);
        }
        for(String lot:lotList){
            if(lot.contains('row') && !p2CodeList.contains(lot)){
                Product2 p2 = new Product2(
                    Name=qliPrice.get(lot)[3],
                    Description=qliPrice.get(lot)[3],
                    ONI_fld_Producto_PrecioM2__c=qliPrice.get(lot)[0],
                    CEN_PRECIOVENTAFUN__c=qliPrice.get(lot)[1],
                    AREA__c =qliPrice.get(lot)[2],
                    CODLOTE__c=lot,
                    recordTypeId=rtIndustrial,
           //         CEN_Proyecto__c=pro.Id,
                    OFI_fld_Product2_Estado__c='L'
                    
                    //CODMONEDAFUNCIONAL__c=qliPrice,get(lot)
                    );

                    if(!Test.isRunningTest()){
                    p2.ONI_fld_Producto_Oportunidad__c=opportunityId;
                    }

                p2ListNew.add(p2);
            }
        }
        System.debug('Producto Rustico>');
        System.debug(p2ListNew);
        Database.insert(p2ListNew,AccessLevel.USER_MODE);

        List<PricebookEntry> pbeListNew = addToPricebook(p2ListNew,pb2);

        
       List<Quote> qList ;
        Boolean opportunityRoot = false;
       if(opportunityId.getSObjectType() == Opportunity.SObjectType){
            
            opportunityRoot=true;
        }else{
            opportunityRoot=false;
        }

         qList = opportunityRoot?[SELECT Id,Name FROM Quote  WHERE OpportunityId=:opportunityId WITH USER_MODE ORDER BY Createddate DESC]:
         [SELECT Id,Name FROM Quote  WHERE ONI_fld_Quote_Lead__c=:opportunityId WITH USER_MODE ORDER BY Createddate DESC];
        Quote qn = null;
        if(qList.size()>0){
            qn=qList[0];
        }
        
        Quote q=null;
        if(qn==null){
            q = new Quote(Name='1');
            
            if(opportunityRoot){
                q.OpportunityId=opportunityId;
            }else{
                q.ONI_fld_Quote_Lead__c=opportunityId;
            }
            
            q.Pricebook2Id=pb2.Id;
            q.ONI_fld_Quote_FormaPago__c=qData.get('typeSale');
                q.IND_fld_Quote_MontoPagadoFirma__c=isNumber(qData.get('directPayment'))?Decimal.valueOf(qData.get('directPayment')):null;
            //    q.ONI_fld_Quote_FormaPago__c=qData.get('paymentMethod');
                q.CEN_Area__c=Decimal.valueOf(qData.get('totalArea'));
                q.IND_fld_Quote_MontoFraccionado__c=isNumber(qData.get('installmentPayment'))?Decimal.valueOf(qData.get('installmentPayment')):null;
                q.IND_fld_Quote_CantidadCuotasFraccionadas__c=isNumber(qData.get('installmentNumber'))?Integer.valueOf(qData.get('installmentNumber')):null;
                q.CEN_Saldo_del_precio__c=isNumber(qData.get('chunkPayment'))?Decimal.valueOf(qData.get('chunkPayment')):null;
                q.CEN_N_cuotas_del_saldo_de_precio__c=isNumber(qData.get('chunkNumber'))?Integer.valueOf(qData.get('chunkNumber')):null;
                q.IND_fld_Quote_Tea__c=isNumber(qData.get('chunkTEA'))?Integer.valueOf(qData.get('chunkTEA')):null;
                q.CEN_Fecha_de_vencimiento__c=isNumber(qData.get('chunkDate'))?Date.valueOf(qData.get('chunkDate')):null;
                q.IND_fld_Cotizacion_Condiciones__c      =qData.get('conditions');
                q.IND_fld_Cotizacion_Fraccionamiento__c      =qData.get('installments');
                q.recordTypeId=recordTypeId;
        } else {
            q = qn.clone(false, true, false, false);
            q.Name=String.valueOf(Integer.valueOf(q.Name)+1);
            if(opportunityRoot){
                q.OpportunityId=opportunityId;
            }else{
                q.ONI_fld_Quote_Lead__c=opportunityId;
            }
                q.Pricebook2Id=pb2.Id;
                q.ONI_fld_Quote_FormaPago__c=qData.get('typeSale');
                q.IND_fld_Quote_MontoPagadoFirma__c=isNumber(qData.get('directPayment'))?Decimal.valueOf(qData.get('directPayment')):null;
            //    q.ONI_fld_Quote_FormaPago__c=qData.get('paymentMethod');
                q.CEN_Area__c=qData.get('totalArea')!=null?Decimal.valueOf(qData.get('totalArea')):null;
                q.IND_fld_Quote_MontoFraccionado__c=isNumber(qData.get('installmentPayment'))?Decimal.valueOf(qData.get('installmentPayment')):null;
                q.IND_fld_Quote_CantidadCuotasFraccionadas__c=isNumber(qData.get('installmentNumber'))?Integer.valueOf(qData.get('installmentNumber')):null;
                q.CEN_Saldo_del_precio__c=isNumber(qData.get('chunkPayment'))?Decimal.valueOf(qData.get('chunkPayment')):null;
                q.CEN_N_cuotas_del_saldo_de_precio__c=qData.get('chunkNumber')!=null?Integer.valueOf(qData.get('chunkNumber')):null;
                q.IND_fld_Quote_Tea__c=qData.get('chunkTEA')!=null?Integer.valueOf(qData.get('chunkTEA')):null;
                q.CEN_Fecha_de_vencimiento__c=qData.get('chunkDate')!=null?Date.valueOf(qData.get('chunkDate')):null;
                q.IND_fld_Cotizacion_Condiciones__c      =qData.get('conditions');
                q.IND_fld_Cotizacion_Fraccionamiento__c      =qData.get('installments');
                q.recordTypeId=recordTypeId;
            }

         Boolean needApproval =false;
        for (String k : qliPrice.keySet()) {
            needApproval = needApproval || Boolean.valueOf(qliPrice.get(k)[4]);
        }

        q.status=needApproval?'In Review':'Accepted';
        

        q.CEN_TypeOfSale__c=qData.get('typeSale');
        if(q.CEN_TypeOfSale__c=='CO'){
            q.CEN_Monto_cuota_de_inicial_de_precio__c=Decimal.valueOf(qData.get('totalPayment'));
        }
        
        
        System.debug(q);
        try{
            System.debug('q idOpportunity: ' + q.OpportunityId);
            System.debug('q Pricebook Id: ' + q.Pricebook2Id);
            //q.OpportunityId = opportunityId;
        Database.insert(q,AccessLevel.USER_MODE);
        }catch(DmlException e){
            System.debug(e.getMessage());
        }

        if(opportunityRoot){
        Opportunity o = [SELECT Id,SyncedQuoteId, Pricebook2Id FROM Opportunity WHERE Id =: opportunityId LIMIT 1];
        o.SyncedQuoteId=q.Id;
        System.debug('Opportunity Pricebook: '+ o.Pricebook2Id);
        //o.OFI_fld_Opportunity_Edificio__c=
        Database.update(o,AccessLevel.SYSTEM_MODE);
        }
        List<Map<String,String>> milestoneList = ( List<Map<String,String>> )JSON.deserialize(qData.get('milestoneList'),List<Map<String,String>>.class);
        List<ONI_obj_Hito__c> hList = new List<ONI_obj_Hito__c>();
        for(Map<String,String> m:milestoneList){
            ONI_obj_Hito__c hito = new ONI_obj_Hito__c(
                Name=m.get('name'),
                // IND_fld_Hito_FechaEstimada__c=Date.valueOf( m.get('date')),
                IND_fld_Hito_Monto__c=Decimal.valueOf(m.get('amount')),
                IND_fld_Hito_Cotizacion__c=q.Id
                );
                hList.add(hito);
        }
        Database.insert(hList,AccessLevel.USER_MODE);

       

     



        List<PricebookEntry > pbeList=null;
        if(isIndustrial){
            pbeList = [SELECT Id,Product2Id,Product2.CEN_PRECIOVENTAFUN__c,Product2.Name,Product2.CODLOTE__c FROM PricebookEntry  WHERE Product2.CODLOTE__c IN :lotList AND IsActive=true WITH USER_MODE];
        }else{
            pbeList = [SELECT Id,Product2Id,Product2.CEN_PRECIOVENTAFUN__c,Product2.Name,Product2.CODLOTE__c FROM PricebookEntry  WHERE Id IN :lotList AND IsActive=true WITH USER_MODE];
        }
        
       // pbeList.addAll(pbeListNew);

        System.debug('pbeList'+':::'+pbeList);
        
        List<QuoteLineItem> qliList = new List<QuoteLineItem>();
        for(PricebookEntry pbe : pbeList){
            System.debug(q.Id);
            System.debug(pbe.Id);
            System.debug(pbe.Product2Id);
            System.debug(pbe.Product2.Name);
            System.debug(pbe.Product2.CEN_PRECIOVENTAFUN__c);
            QuoteLineItem qli;
            if(isIndustrial){
             qli= new QuoteLineItem(
                QuoteId=q.Id,
                PricebookEntryId=pbe.Id,
                Product2Id=pbe.Product2Id, 
                UnitPrice = Decimal.valueOf(qliPrice.get(pbe.Product2.CODLOTE__c)[1]),
                Quantity=1,
                CEN_precio_m2_cotizado_lote__c=Decimal.valueOf(qliPrice.get(pbe.Product2.CODLOTE__c)[0]),
                CEN_precio_venta_cotizado_lote__c=Decimal.valueOf(qliPrice.get(pbe.Product2.CODLOTE__c)[1])
                );
            }else{
                qli = new QuoteLineItem(
                QuoteId=q.Id,
                PricebookEntryId=pbe.Id,
                Product2Id=pbe.Product2Id, 
                UnitPrice = Decimal.valueOf(qliPrice.get(pbe.Id)[1]),
                Quantity=1,
                CEN_precio_m2_cotizado_lote__c=Decimal.valueOf(qliPrice.get(pbe.Id)[0]),
                CEN_precio_venta_cotizado_lote__c=Decimal.valueOf(qliPrice.get(pbe.Id)[1])
                );
            }


            qliList.add(qli);
        }
        
        Database.insert(qliList,AccessLevel.USER_MODE);


		if(needApproval && !Test.isRunningTest()){
                Approval.ProcessSubmitRequest submitRequest = new Approval.ProcessSubmitRequest();
                submitRequest.setObjectId(q.Id);
                if (isIndustrial) {
                    submitRequest.setProcessDefinitionNameOrId('IND_ap_Cotizacion_Descuento');
                }else{
                    submitRequest.setProcessDefinitionNameOrId('OFI_ap_Cotizacion_Descuento');
                }
                submitRequest.setSkipEntryCriteria(true);
                //Approval.LockResult lr = Approval.lock(opportunityId);
                Approval.ProcessResult result = Approval.process(submitRequest);
        }else{

        }


        generatePdf(q.Id,opportunityId);
        return true;
    }

    @AuraEnabled
    public static List<QuoteLineItem> getQuote(Id opportunityId){
        List<Quote> qList = [SELECT Id,Name FROM Quote  WHERE OpportunityId=:opportunityId WITH USER_MODE ORDER BY Createddate DESC];
        Id qId=null;
        if(qList.size()>0){
            qId=qList[0].Id;
        }
        else{
            return null;
        }
        List<QuoteLineItem> qliList = [SELECT 
            QuoteId,
            PricebookEntry.UnitPrice,
            Product2.Name,
            Product2.Id,
            Product2.CODLOTE__c ,
            Product2.CEN_IdLotSAP__c,
            Product2.ONI_fld_Producto_PrecioM2__c,
            Product2.CEN_PRECIOVENTAFUN__c,
            Product2.AREA__c,
            Product2.CODMONEDAFUNCIONAL__c,
            Product2.OFI_fld_Product2_DescSociedad__c,
            Product2.OFI_fld_Product2_BaseMedida__c,
            tolabel(Product2.OFI_fld_Product2_Estado__c),
            PricebookEntryId


            FROM QuoteLineItem WHERE Quote.OpportunityId=:opportunityId AND QuoteId=:qId WITH USER_MODE];
        // List<String> lotList = new List<String>();
        // for(QuoteLineItem qli:qliList){
        //     lotList.add(qli.Product2.CODLOTE__c);
        // }
        return qliList;
    }

    @AuraEnabled
    public static List<Object> getOffice(Id projectId,String typeProduct){
        Id newProjectId = projectId;
        /*
        if(Test.isRunningTest()){
            List<Proyecto__c> proyecto = [SELECT Id, Name FROM Proyecto__c WHERE Name LIKE 'Torre%' LIMIT 1];
            newProjectId = proyecto[0].Id;
        }*/
        
        List<PricebookEntry> pbe2List= new List<PricebookEntry>();
        List<OFI_obj_Medida__c> medList=new List<OFI_obj_Medida__c>();
        Map<String,OFI_obj_Medida__c> medMap = new Map<String,OFI_obj_Medida__c>();
        Map<String,String> socMap = new Map<String,String>();
        System.debug('TYPE PRODUCT: '+typeProduct);
        if(typeProduct!=''){
            Decimal tp=Decimal.valueOf(typeProduct);
            pbe2List = [SELECT 
                Product2.Id,
                UnitPrice,
                Product2.OFI_fld_Product2_DescSociedad__c,
                Product2.Name,
                Product2.CEN_IdLotSAP__c,
                Product2.CODLOTE__c,
                Product2.ONI_fld_Product_TipoObjetoAlquiler__c,
                Product2.ONI_fld_Producto_PrecioM2__c,
                Product2.CEN_PRECIOVENTAFUN__c,
                Product2.AREA__c,
                Product2.OFI_fld_Product2_DescClaseObj__c,
                Product2.OFI_fld_Product2_DescEdificio__c,
                Product2.OFI_fld_Product2_Clase__c,
                Product2.OFI_fld_Product2_BaseMedida__c,
                Product2.OFI_fld_Product2_IdSociedad__c,
                Product2.OFI_fld_Producto_NombreEdificio__r.ONI_fld_Proyecto_EdificioExternalId__c,
                Product2.OFI_fld_Product2_IdSAP__c,
                tolabel(Product2.OFI_fld_Product2_Estado__c)
                FROM PricebookEntry 
                WHERE  Product2.RecordType.DeveloperName='OFI_rt_Product2_Oficina' 
                AND isActive=true
                AND Product2.OFI_fld_Producto_NombreEdificio__c = :newProjectId
                AND Product2.OFI_fld_Product2_Estado__c in ('L','Libre')
                AND product2.OFI_fld_Product2_Clase__c =:tp    
                WITH USER_MODE];
        }
         else{
             pbe2List = [SELECT 
                Product2.Id,
                UnitPrice,
                Product2.OFI_fld_Product2_DescSociedad__c,
                Product2.Name,
                Product2.CEN_IdLotSAP__c,
                Product2.CODLOTE__c,
                Product2.ONI_fld_Product_TipoObjetoAlquiler__c,
                Product2.ONI_fld_Producto_PrecioM2__c,
                Product2.CEN_PRECIOVENTAFUN__c,
                Product2.AREA__c,
                Product2.OFI_fld_Product2_DescClaseObj__c,
                Product2.OFI_fld_Product2_DescEdificio__c,
                Product2.OFI_fld_Product2_BaseMedida__c,
                Product2.OFI_fld_Product2_IdSociedad__c,
                Product2.OFI_fld_Product2_Clase__c,
                Product2.OFI_fld_Producto_NombreEdificio__r.ONI_fld_Proyecto_EdificioExternalId__c,
                Product2.OFI_fld_Product2_IdSAP__c,
                tolabel(Product2.OFI_fld_Product2_Estado__c)
                FROM PricebookEntry 
                WHERE  Product2.RecordType.DeveloperName='OFI_rt_Product2_Oficina' 
                AND isActive=true
                AND Product2.OFI_fld_Producto_NombreEdificio__c = :newProjectId
                AND Product2.OFI_fld_Product2_Estado__c in ('L','Libre')
                AND  product2.OFI_fld_Product2_Clase__c != 19
        		WITH USER_MODE];
        }

        // change UnitPrice, by getMaestroPrecios according to OFI_fld_Product2_DescEdificio__c
        System.debug('Before for: '+newProjectId);
        for(PricebookEntry pbe2:pbe2List){
            System.debug(pbe2);
            System.debug(pbe2.Product2Id);
            System.debug(pbe2.Product2.OFI_fld_Product2_DescEdificio__c);
            OFI_obj_MaestroPrecioEdificio__c mp = getMaestroPrecios(pbe2.Product2.OFI_fld_Product2_DescEdificio__c);
            if(mp!=null){
                if(pbe2.Product2.OFI_fld_Product2_DescClaseObj__c == 'En casco'){
                    pbe2.UnitPrice = mp.OFI_fld_MtroPrecioEdif_PrecioCascoGris__c;
                }
                else if(pbe2.Product2.OFI_fld_Product2_DescClaseObj__c == 'Implementada Ex Cliente'){
                    pbe2.UnitPrice = mp.OFI_fld_MtroPrecioEdif_PrecioImplExCli__c;
                }
                else if(pbe2.Product2.OFI_fld_Product2_DescClaseObj__c == 'Implementada Centenario'){
                    pbe2.UnitPrice = mp.OFI_fld_MtroPrecioEdif_PrecioImplCen__c;
                }
            }
        }

        return new List<Object>{pbe2List};
    }


    @AuraEnabled
    public static List<PricebookEntry> getIndustrial(String projectId,String typeProduct,Id opportunityId){
        List<PricebookEntry> pb2List = [SELECT 
        Product2.Id,
        Product2.Name,
        Product2.CEN_IdLotSAP__c,
        Product2.CODLOTE__c,
        Product2.ONI_fld_Product_TipoObjetoAlquiler__c,
        Product2.ONI_fld_Producto_PrecioM2__c,
        Product2.CEN_PRECIOVENTAFUN__c,
        Product2.AREA__c,
        Product2.CODMONEDAFUNCIONAL__c,
        tolabel(Product2.OFI_fld_Product2_Estado__c)
        FROM PricebookEntry 
        WHERE  Pricebook2.Name='MacrOpolis'
        AND Product2.OFI_fld_Product2_Estado__c='L'
        AND (Product2.ONI_fld_Producto_Oportunidad__c = null OR Product2.ONI_fld_Producto_Oportunidad__c =:opportunityId)
        AND Product2.CEN_Proyecto__r.CEN_CODIGOSAP__c =: projectId
        WITH USER_MODE];
        
        //p2List = [SELECT Id,Name,CEN_IdLotSAP__c,ONI_fld_Product_TipoObjetoAlquiler__c,ONI_fld_Producto_PrecioM2__c,CEN_PRECIOVENTAFUN__c,AREA__c FROM Product2 WHERE priec WITH USER_MODE ];
        return pb2List;
    }

    @AuraEnabled
    public static OFI_obj_MaestroPrecioEdificio__c getMaestroPrecios(String name){
        System.debug('NAME: '+name);
        try {
            OFI_obj_MaestroPrecioEdificio__c  mp = [SELECT Id, Name, OFI_fld_MtroPrecioEdif_PrecioCascoGris__c, OFI_fld_MtroPrecioEdif_PrecioImplCen__c, OFI_fld_MtroPrecioEdif_PrecioImplExCli__c FROM OFI_obj_MaestroPrecioEdificio__c WHERE Name=:name ORDER BY CreatedDate DESC LIMIT 1];
            return mp;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }


    @future(callout=true)
    public static void generatePDF(String idCotizacion, String idOportunidad) {
        List<Attachment> listAttachments = new List<Attachment>();
        Datetime now = Datetime.now();
        Integer offset = UserInfo.getTimezone().getOffset(now);
        Datetime local = now.addSeconds(offset / 1000);
        Blob pdfGenerado = null;
        
        
        List<Quote> qList = [SELECT RecordType.DeveloperName FROM Quote WHERE Id =:idCotizacion];
        Quote q = null;
        if(qList.size()>0){
            q = qList[0];
        }
        System.debug('BEFORE PAGE');
        PageReference pdfPage;
        
        if(q.RecordType.DeveloperName=='ONI_rt_Cotizacion_Oficina'){
            pdfPage = (PageReference) Page.OFI_vf_PdfPlantillaCotizador;
        }else{
            pdfPage = (PageReference) Page.IND_vf_PdfPlantillaCotizador;
        }
        System.debug('AFTER PAGE');
        
        //PageReference pdfPage = (PageReference) (q.RecordType.DeveloperName=='ONI_rt_Cotizacion_Industrial'?Page.IND_vf_PdfPlantillaCotizador:Page.OFI_vf_PdfPlantillaCotizador);

        pdfPage.getParameters().put('Id', idCotizacion);
        
        try {
            if (Test.isRunningTest()) {pdfGenerado = blob.valueOf('Unit.Test');}
            else {
                System.debug('togenerate');
                pdfGenerado = pdfPage.getContentAsPDF(); 
            }
            System.debug(pdfGenerado);
            if (pdfGenerado != null && String.isNotBlank(idCotizacion)) {
                Attachment objAttachment = new Attachment();
                objAttachment.parentId = idCotizacion;
                objAttachment.Name = 'Cotización PDF' + local + '.pdf';
                objAttachment.body = pdfGenerado;
                objAttachment.contentType = 'application/pdf';
                objAttachment.isPrivate = false;
                listAttachments.add(objAttachment);
            }
            if (pdfGenerado != null && String.isNotBlank(idCotizacion)) {
                Attachment objAttachment = new Attachment();
                objAttachment.parentId = idOportunidad;
                objAttachment.Name = 'Cotización PDF' + local + '.pdf';
                objAttachment.body = pdfGenerado;
                objAttachment.contentType = 'application/pdf';
                objAttachment.isPrivate = false;
                listAttachments.add(objAttachment);
            }

            insert listAttachments;
        } catch (Exception e) {
            System.debug('No se pudo generar el PDF: ' + e.getMessage() + '. Type: ' +e.getTypeName() + '. Line: ' +e.getLineNumber());
            System.debug(LoggingLevel.ERROR,'No se pudo generar el PDF: ' + e.getMessage() + '. Type: ' +e.getTypeName() + '. Line: ' +e.getLineNumber());
        }
    }

    @AuraEnabled(cacheable=true)
    public static ONI_cs_Cotizador__c getCustomSetting() {
        
        return ONI_cs_Cotizador__c.getOrgDefaults();
    }
    
    @AuraEnabled(cacheable=true)
    public static ONI_Obj_Configuracion__c getConfiguration(){
        List<ONI_obj_Configuracion__c> confList = [SELECT Id, ONI_fld_Configuracion_DescuentoMaximoIND__c, ONI_fld_Configuracion_DescuentoMaximoOFI__c,ONI_fld_Configuracion_EstPrecio__c FROM ONI_obj_Configuracion__c ORDER BY CreatedDate DESC LIMIT 1];
        
        return confList.size()>0?confList.get(0):null;
    }

    @AuraEnabled(cacheable=true)
    public static String getRecordTypeName(Id opportunityId){

        Boolean opportunityRoot = false;
        String recordTypeName;
        if(opportunityId.getSObjectType() == Opportunity.SObjectType){
            Opportunity opp = [SELECT Id,RecordType.Name FROM Opportunity WHERE Id =: opportunityId];   
            recordTypeName=opp.RecordType.Name;
            opportunityRoot=true;
        }else{
            opportunityRoot=false;
            Lead lead = [SELECT Id,RecordType.Name FROM Lead WHERE Id =: opportunityId] ;   
            recordTypeName=lead.RecordType.Name;
        }

        
        
        return recordTypeName;
    }

}