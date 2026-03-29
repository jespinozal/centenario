/********************************************************************* 
* @author: Alfredo Morote (amorotet@nttdata.com) 
* @date: 29-10-2025
* @description: Clase helper para procesar y realizar upsert de Objetos de Alquiler en Salesforce
*
* Clase Test: OFI_ObjetoAlquilerHelper_tst
* 
* VERSION      DATE                 AUTOR                     ACTION 
* 0.1          29-10-2025           Alfredo Morote            Creación 
*  
*********************************************************************/
public with sharing class OFI_ObjetoAlquilerHelper_cls {

    private static Id OFICINA_RT_ID = Schema.SObjectType.Product2
            .getRecordTypeInfosByDeveloperName()
            .get('OFI_rt_Product2_Oficina')
            .getRecordTypeId();

    // ==============================================================
    // MÉTODO PRINCIPAL (por chunk)
    // ==============================================================
    public static void processObjAlqChunk( List<OFI_ObjetoAlquilerObjectResponse_cls> chunk) {

        if (chunk == null || chunk.isEmpty()) return;
        
        // ----------------------------------------------------------
        // 1. DEDUPLICACIÓN LOCAL (solo dentro del chunk)
        // ----------------------------------------------------------
        
        logHeap('Inicio');

        Map<String, OFI_ObjetoAlquilerObjectResponse_cls> uniq = new Map<String, OFI_ObjetoAlquilerObjectResponse_cls>();
        for (OFI_ObjetoAlquilerObjectResponse_cls oa : chunk) {
            String key = buildKey(oa);
            if (!uniq.containsKey(key)) {
                uniq.put(key, oa);
            }
        }

        // ----------------------------------------------------------
        // 2. PROYECTOS (Edificios)
        // ----------------------------------------------------------
        Map<String, Proyecto__c> proyectos = new Map<String, Proyecto__c>();
        for (OFI_ObjetoAlquilerObjectResponse_cls oa : uniq.values()) {
            if (!proyectos.containsKey(oa.edificio)) {
                proyectos.put(oa.edificio, buildProyecto(oa));
            }
        }

        if (!proyectos.isEmpty()) {
            upsert proyectos.values()
                Proyecto__c.ONI_fld_Proyecto_EdificioExternalId__c;
        }

        Map<String, Id> proyectoIdByExt = new Map<String, Id>();
        for (Proyecto__c p : proyectos.values()) {
            proyectoIdByExt.put(p.ONI_fld_Proyecto_EdificioExternalId__c, p.Id);
        }

        // ----------------------------------------------------------
        // 3. PRODUCTOS (Objetos de Alquiler)
        // ----------------------------------------------------------
        Map<String, Product2> productos = new Map<String, Product2>();
        logHeap('Productos creados');
        for (String key : uniq.keySet()) {
            OFI_ObjetoAlquilerObjectResponse_cls oa = uniq.get(key);
            Product2 p = buildProducto(oa, OFICINA_RT_ID);

            Id proyectoId = proyectoIdByExt.get(oa.edificio);
            if (proyectoId != null) {
                p.OFI_fld_Producto_NombreEdificio__c = proyectoId;
                p.CEN_Proyecto__c = proyectoId;
            }
            productos.put(key, p);
        }

        if (!productos.isEmpty()) {
            upsert productos.values()
                Product2.ONI_fld_Product2_ObjAlquilerCompuesto__c;
        }

        // ----------------------------------------------------------
        // 4. PRICEBOOK ENTRIES (streaming)
        // ----------------------------------------------------------
        processPricebooks(productos, uniq);
    }

    // ==============================================================
    // PRICEBOOK PROCESSING (SIN LISTAS GRANDES)
    // ==============================================================
    private static void processPricebooks(
        Map<String, Product2> productos,
        Map<String, OFI_ObjetoAlquilerObjectResponse_cls> source
    ) {
        if (productos.isEmpty()) return;

        Id standardPB = Test.isRunningTest()
            ? Test.getStandardPricebookId()
            : [SELECT Id FROM Pricebook2 WHERE IsStandard = true LIMIT 1].Id;

        Id oficinasPB = [
            SELECT Id FROM Pricebook2 WHERE Name = 'Oficinas' LIMIT 1
        ].Id;

        Map<String, MaestroPrecioWrapper> precios =
            loadMaestroPrecios(source.values());

        List<PricebookEntry> buffer = new List<PricebookEntry>();
        logHeap('Buffer inicializado');

        for (String key : productos.keySet()) {
            Product2 p = productos.get(key);
            OFI_ObjetoAlquilerObjectResponse_cls oa = source.get(key);

            Decimal price = calculatePrice(p, oa, precios);

            buffer.add(buildPBE(standardPB, p.Id, price, false));
            buffer.add(buildPBE(oficinasPB, p.Id, price, true));

            if (buffer.size() >= 200) {
                logHeap('Antes upsert PBEs');
                upsertPBEs(buffer);
                buffer.clear();
                logHeap('Después clear PBEs');
            }
        }

        logHeap('Fin');

        if (!buffer.isEmpty()) {
            upsertPBEs(buffer);
        }
    }

    // ==============================================================
    // MAESTRO DE PRECIOS
    // ==============================================================
    private static Map<String, MaestroPrecioWrapper> loadMaestroPrecios(
        List<OFI_ObjetoAlquilerObjectResponse_cls> data
    ) {
        Set<String> edificios = new Set<String>();
        for (OFI_ObjetoAlquilerObjectResponse_cls oa : data) {
            edificios.add(oa.edificio);
        }

        Map<String, MaestroPrecioWrapper> result =
            new Map<String, MaestroPrecioWrapper>();

        for (OFI_obj_MaestroPrecioEdificio__c mpe : [
            SELECT OFI_fld_MtroPrecioEdif_EdifExtId__c,
                   OFI_fld_MtroPrecioEdif_PrecioCascoGris__c,
                   OFI_fld_MtroPrecioEdif_PrecioImplCen__c,
                   OFI_fld_MtroPrecioEdif_PrecioImplExCli__c,
                   OFI_fld_MtroPrecioEdif_EsPrecioFijo__c
            FROM OFI_obj_MaestroPrecioEdificio__c
            WHERE OFI_fld_MtroPrecioEdif_EdifExtId__c IN :edificios
        ]) {
            MaestroPrecioWrapper w = new MaestroPrecioWrapper();
            w.esPrecioFijo = mpe.OFI_fld_MtroPrecioEdif_EsPrecioFijo__c;
            w.precioCascoGris = mpe.OFI_fld_MtroPrecioEdif_PrecioCascoGris__c;
            w.precioImpCentenario = mpe.OFI_fld_MtroPrecioEdif_PrecioImplCen__c;
            w.precioImpExCliente = mpe.OFI_fld_MtroPrecioEdif_PrecioImplExCli__c;
            result.put(mpe.OFI_fld_MtroPrecioEdif_EdifExtId__c, w);
        }
        return result;
    }

    // ==============================================================
    // CÁLCULO DE PRECIO
    // ==============================================================
    private static Decimal calculatePrice(
        Product2 p,
        OFI_ObjetoAlquilerObjectResponse_cls oa,
        Map<String, MaestroPrecioWrapper> precios
    ) {
        MaestroPrecioWrapper w = precios.get(oa.edificio);
        if (w == null) return 0;

        if (w.esPrecioFijo) {
            return w.precioCascoGris != null ? w.precioCascoGris : 0;
        }

        Decimal base = p.OFI_fld_Product2_BaseMedida__c != null
            ? p.OFI_fld_Product2_BaseMedida__c
            : 0;

        if (oa.claseObjeto == '01') return base * nvl(w.precioCascoGris);
        if (oa.claseObjeto == '02') return base * nvl(w.precioImpCentenario);
        if (oa.claseObjeto == '03') return base * nvl(w.precioImpExCliente);

        return 0;
    }

    // ==============================================================
    // UPSERT DE PRICEBOOKENTRY
    // ==============================================================
    private static void upsertPBEs(List<PricebookEntry> entries) {
        Map<String, PricebookEntry> existing = new Map<String, PricebookEntry>();

        Set<Id> prodIds = new Set<Id>();
        Set<Id> pbIds = new Set<Id>();
        for (PricebookEntry pbe : entries) {
            prodIds.add(pbe.Product2Id);
            pbIds.add(pbe.Pricebook2Id);
        }

        for (PricebookEntry pbe : [
            SELECT Id, Product2Id, Pricebook2Id
            FROM PricebookEntry
            WHERE Product2Id IN :prodIds
              AND Pricebook2Id IN :pbIds
        ]) {
            existing.put(pbe.Pricebook2Id + '|' + pbe.Product2Id, pbe);
        }

        List<PricebookEntry> toInsert = new List<PricebookEntry>();
        List<PricebookEntry> toUpdate = new List<PricebookEntry>();

        for (PricebookEntry pbe : entries) {
            String key = pbe.Pricebook2Id + '|' + pbe.Product2Id;
            if (existing.containsKey(key)) {
                pbe.Id = existing.get(key).Id;
                toUpdate.add(pbe);
            } else {
                toInsert.add(pbe);
            }
        }

        if (!toInsert.isEmpty()) insert toInsert;
        if (!toUpdate.isEmpty()) update toUpdate;
    }

    // ==============================================================
    // BUILDERS
    // ==============================================================
    private static Proyecto__c buildProyecto(
        OFI_ObjetoAlquilerObjectResponse_cls oa
    ) {
        return new Proyecto__c(
            ONI_fld_Proyecto_EdificioExternalId__c = oa.edificio,
            CEN_CODIGOSAP__c = oa.edificio,
            Name = oa.descEdificio,
            CEN_Tipo_de_proyecto__c = 'Oficina',
            OFI_fld_Proyecto_Categoria__c = oa.categoria,
            OFI_fld_Proyecto_DescCategoria__c = oa.descCategoria
        );
    }

    private static Product2 buildProducto(
        OFI_ObjetoAlquilerObjectResponse_cls oa,
        Id ofiRecTypeId
    ) {
        Product2 p = new Product2();
        p.ONI_fld_Product2_ObjAlquilerCompuesto__c = buildKey(oa);
        p.OFI_fld_Product2_IdSAP__c = oa.objetoAlquiler;
        p.OFI_fld_Product2_IdSociedad__c = oa.sociedad;
        p.OFI_fld_Product2_DescSociedad__c = oa.descSociedad;
        p.Name = oa.descObjAlq + ' - ' + oa.descEdificio;
        p.OFI_fld_Product2_DescEdificio__c = oa.descEdificio;
        p.IsActive = true;
        p.RecordTypeId = ofiRecTypeId;
        p.OFI_fld_Product2_Estado__c = oa.estado.substring(0,1);
        p.OFI_fld_Product2_FechaUltimaModif__c = safeDate(oa.fecUltimaModif);
        p.OFI_fld_Product2_Responsable__c = oa.responsable;
        p.OFI_fld_Product2_Clase__c = oa.clase;
        p.OFI_fld_Product2_UnidadEconomica__c = oa.unidadEconomica;
        p.OFI_fld_Product2_DescUnidadEconomica__c = oa.descUnidEco;
        p.OFI_fld_Product2_DescClase__c = oa.descClase;
        p.OFI_fld_Product2_ClaseObjeto__c = oa.claseObjeto;
        p.OFI_fld_Product2_DescClaseObj__c = oa.descClaseObj;
        p.OFI_fld_Product2_Piso__c = oa.piso;
        p.OFI_fld_Product2_DescPiso__c = oa.descPiso;
        p.OFI_fld_Product2_Categoria__c = oa.categoria;
        p.OFI_fld_Product2_DescCategoria__c = oa.descCategoria;


        if (oa.medidas != null && !oa.medidas.isEmpty()) {
            p.OFI_fld_Product2_TipoMedicion__c = oa.medidas[0].tipoMedicion;
            p.OFI_fld_Product2_DescTipoMedicion__c = oa.medidas[0].descTipmed;
            p.OFI_fld_Product2_BaseMedida__c = oa.medidas[0].baseMedida;
            p.OFI_fld_Product2_DenominacionTipoMedida__c = oa.medidas[0].um;
            p.OFI_fld_Product2_ValidoDesde__c = safeDate(oa.medidas[0].validoDe);
            p.OFI_fld_Product2_ValidoHasta__c = safeDate(oa.medidas[0].validoHasta);
        }
        return p;
    }

    private static PricebookEntry buildPBE(
        Id pbId, Id prodId, Decimal price, Boolean active
    ) {
        return new PricebookEntry(
            Pricebook2Id = pbId,
            Product2Id = prodId,
            UnitPrice = price,
            IsActive = active
        );
    }

    // ==============================================================
    // UTILIDADES
    // ==============================================================
    private static String buildKey(
        OFI_ObjetoAlquilerObjectResponse_cls oa
    ) {
        return oa.sociedad + '|' + oa.edificio + '|' + oa.objetoAlquiler;
    }

    private static Decimal nvl(Decimal d) {
        return d != null ? d : 0;
    }

    private static Date safeDate(String dateStr) {
        Date sfDate;
        Date maxAllowedDate = Date.newInstance(4000, 12, 31);
        if(!String.isBlank(dateStr)) {
            sfDate = Date.valueOf(dateStr);
            sfDate = sfDate.year() > maxAllowedDate.year() ? maxAllowedDate : Date.valueOf(dateStr);
        }
        return sfDate;
    }

    private static void logHeap(String step) {
    System.debug(
        'HEAP [' + step + '] -> ' +
        (Limits.getHeapSize() / 1024.0 / 1024.0) + ' MB / ' +
        (Limits.getLimitHeapSize() / 1024.0 / 1024.0) + ' MB'
    );
}

    // ==============================================================
    // WRAPPER INTERNO
    // ==============================================================
    private class MaestroPrecioWrapper {
        Boolean esPrecioFijo;
        Decimal precioCascoGris;
        Decimal precioImpCentenario;
        Decimal precioImpExCliente;
    }
}