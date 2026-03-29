public with sharing class ONI_Inventario_cls implements Queueable, Database.AllowsCallouts  {

    private Id proyectId;

    public ONI_Inventario_cls(Id proyectId) {
        this.proyectId = proyectId;
    }

    public void callProducts(Proyecto__c pro) {
        System.debug('Proyecto actual: ' + pro.CEN_CODIGOSAP__c);

        try {
            Map<String, Schema.RecordTypeInfo> recordTypeInfoMap = Schema.getGlobalDescribe()
            .get('Product2')
            .getDescribe()
            .getRecordTypeInfosByDeveloperName();
            Schema.RecordTypeInfo rtInfo = recordTypeInfoMap.get('OFI_rt_Product2_Industrial');
            Id rtId = rtInfo.getRecordTypeId();
            
            List<ONI_Cotizador_cls.LoteWrapper> objList = (List<ONI_Cotizador_cls.LoteWrapper>) ONI_Cotizador_cls.getLotesFromEndpoint(pro.CEN_CODIGOSAP__c);
            List<String> codList = new List<String>();
            for(ONI_Cotizador_cls.LoteWrapper obj: objList){
                obj.codLote=obj.codLote.replaceFirst('^0+(?!$)', '');
                codList.add(obj.codLote);
            }
            List<Product2> prodList = [SELECT Id,CODLOTE__c FROM Product2 WHERE CODLOTE__c IN :codList];
            Map<String,String> prodMap = new Map<String,String>();
            for(Product2 prod:prodList){
                prodMap.put(prod.CODLOTE__c,prod.Id);
            }
            List<Product2> p2List = new List<Product2>();
            for(ONI_Cotizador_cls.LoteWrapper obj: objList){
                System.debug( obj.codLote+':::'+obj.estadoActualLote+':::'+obj.idCrm);
                Product2 p2 = new Product2();
                    p2.Id = obj.idCrm!=''?obj.idCrm:prodMap.get(obj.codLote);
                    p2.CODLOTE__c=obj.codLote;
                    p2.Name=obj.descripcionLote;
                    p2.DESCRIPCIONLOTE__c=obj.descripcionLote;
                    p2.CEN_IdLotSAP__c=String.valueOf(obj.idLote);
                    p2.CODCOMPANIA__c=obj.codCompania;
                    p2.CEN_MEDIDAFRENTE__c=obj.medidaFrente;
                    p2.CEN_MEDIDADERECHA__c=obj.medidaDerecha;
                    p2.CEN_LINDEROIZQUIERDA__c=obj.medidaIzquierda;
                    p2.CEN_LINDEROFRENTE__c=obj.linderoFrente;
                    p2.CEN_PRECIOVENTAFUN__c=String.valueOf(obj.precioVenta);
                    p2.MANZANA__c=obj.manzana;
                    p2.AREA__c=String.valueOf( obj.areaMt2);
                    p2.CEN_MEDIDAFONDO__c=obj.medidaFondo;
                    p2.CEN_MEDIDAIZQUIERDA__c=obj.medidaIzquierda;
                    p2.CEN_LINDEROFONDO__c=obj.linderoFondo;
                    p2.LINDERODERECHA__c=obj.linderoFrente;
                    p2.DESCRIPCIONCORTA__c=obj.descripcionCorta;
                    p2.IsActive=true;
                    p2.CEN_Proyecto__c=pro.Id;
                    p2.ONI_fld_Producto_PrecioM2__c=String.valueOf(obj.precioMt2);
                    p2.CODMONEDAFUNCIONAL__c=obj.monedaLote;
                    p2.Description=obj.descripcionLote;
                    p2.RecordTypeId=rtId;
                    p2.OFI_fld_Product2_Estado__c=obj.estadoActualLote;
                    p2.CEN_NUM_LOTE__c=obj.lote;
                    p2.CEN_TIPOLOGIA__c=obj.descripcionTipologia;
                    p2.IND_fld_Producto_Ubicacion__c=obj.descripcionTipologia;
                    p2.IND_fld_Producto_Tipologia__c=obj.tipologiaProductos;
                    
                
                p2List.add(p2);

            }
            System.debug(p2List);
            System.debug('##############1');
            Integer p = 0;
            for(Product2 p2: p2List){
                System.debug(p2.id);
                System.debug(p2.CODLOTE__c);
                System.debug(p2.Name);
                System.debug(p2.OFI_fld_Product2_Estado__c);
                System.debug(p);
                System.debug('-------------');
                p++;
            }
            Database.UpsertResult[] srList = Database.upsert(p2List, true);
            System.debug('##############2');
            
            Id  standardPricebookId;
            if(Test.isRunningTest()){
                standardPricebookId = Test.getStandardPricebookId();
            }else{
                standardPricebookId = [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1].Id;
            }
            
            Pricebook2 pb = [SELECT Id FROM Pricebook2 WHERE Name = 'MacrOpolis'];
            List<PricebookEntry> pbeList = new List<PricebookEntry>();
            Map<String,String> pbeMap = new Map<String,String>();
            Map<String,String> speMap = new Map<String,String>();
            List<PricebookEntry> pbeList2 = [SELECT Id,Product2Id FROM PricebookEntry WHERE Product2Id IN :p2List AND Pricebook2Id =: pb.Id];
            List<PricebookEntry> speList2 = [SELECT Id,Product2Id FROM PricebookEntry WHERE Product2Id IN :p2List AND Pricebook2Id =: standardPricebookId];
            for(PricebookEntry pbe:pbeList2){
                pbeMap.put(pbe.Product2Id,pbe.Id);
            }

            for(PricebookEntry spe:speList2){
                speMap.put(spe.Product2Id,spe.Id);
            }
            
            List<PricebookEntry> pbeToInsert = new List<PricebookEntry>();
            List<PricebookEntry> pbeToUpdate = new List<PricebookEntry>();

            for (Product2 p2 : p2List) {

                Decimal unitPrice = Decimal.valueOf(p2.CEN_PRECIOVENTAFUN__c);

                // STANDARD PRICE BOOK
                if (speMap.containsKey(p2.Id)) {
                    // UPDATE existente
                    pbeToUpdate.add(new PricebookEntry(
                        Id = speMap.get(p2.Id),
                        UnitPrice = unitPrice,
                        IsActive = false
                    ));
                } else {
                    // INSERT nuevo
                    pbeToInsert.add(new PricebookEntry(
                        Pricebook2Id = standardPricebookId,
                        Product2Id = p2.Id,
                        UnitPrice = unitPrice,
                        IsActive = false
                    ));
                }

                // MACROPOLIS PRICE BOOK
                if (pbeMap.containsKey(p2.Id)) {
                    // UPDATE existente
                    pbeToUpdate.add(new PricebookEntry(
                        Id = pbeMap.get(p2.Id),
                        UnitPrice = unitPrice,
                        IsActive = true
                    ));
                } else {
                    // INSERT nuevo
                    pbeToInsert.add(new PricebookEntry(
                        Pricebook2Id = pb.Id,
                        Product2Id = p2.Id,
                        UnitPrice = unitPrice,
                        IsActive = true
                    ));
                }
            }
            
            // DML SEPARADO (CRÍTICO)
            if (!pbeToInsert.isEmpty()) {
                insert pbeToInsert;
            }

            if (!pbeToUpdate.isEmpty()) {
                update pbeToUpdate;
            }


        } catch(System.CalloutException e) {
            // Handle callout exceptions
            System.debug('Callout error: ' + e.getMessage());
        }
    }
    
    
    
    public void execute(QueueableContext context) {
        Proyecto__c pro = [SELECT Id, CEN_CODIGOSAP__c FROM Proyecto__c WHERE Id =: proyectId LIMIT 1];
        callProducts(pro);
    }
}