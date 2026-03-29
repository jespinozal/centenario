@isTest
public class ONI_ValidadorArchivosOportunidad_tst {
 
    public static Id obtenerIdTipoRegistro(String objeto, String nombreDev) {
        return Schema.getGlobalDescribe()
            .get(objeto)
            .getDescribe()
            .getRecordTypeInfosByName()
            .get(nombreDev)
            .getRecordTypeId();
    }
 
    public static void crearArchivo(String titulo, String extension, Id idEntidad) {
        ContentVersion versionArchivo = new ContentVersion();
        versionArchivo.Title = titulo;
        versionArchivo.PathOnClient = titulo + '.' + extension;
        versionArchivo.VersionData = Blob.valueOf('Contenido de prueba para ' + titulo);
        versionArchivo.IsMajorVersion = true;
        insert versionArchivo;
 
        ContentVersion versionInsertada = [
            SELECT ContentDocumentId 
            FROM ContentVersion 
            WHERE Id = :versionArchivo.Id
        ];
 
        ContentDocumentLink enlace = new ContentDocumentLink();
        enlace.ContentDocumentId = versionInsertada.ContentDocumentId;
        enlace.LinkedEntityId = idEntidad;
        enlace.ShareType = 'V';
        insert enlace;
    }
 
    @isTest
    static void testFlujoCompletoArchivosOportunidad() {
 
        Account cuenta = new Account();
        cuenta.FirstName= 'Cuenta';
        cuenta.LastName = 'Oficinas';
        cuenta.PersonLeadSource = 'Colaborador'; 
        cuenta.CEN_Medio__c = '0126'; 
        cuenta.CEN_N_mero_de_documento__pc='20123456786';
        insert cuenta;
 
        Proyecto__c proyecto = new Proyecto__c();
        proyecto.Name = 'Proyecto Oficinas';
        insert proyecto;
 
        Opportunity oportunidad = new Opportunity();
        oportunidad.RecordTypeId = obtenerIdTipoRegistro('Opportunity', 'Oficina');
        oportunidad.Name = 'Opp Oficinas';
        oportunidad.AccountId = cuenta.Id;
        oportunidad.CEN_Proyecto__c = proyecto.Id;
        oportunidad.CEN_Oficina_de_Venta__c = 'ZV022';
        oportunidad.CEN_TipoRegimen__c = 'Régimen general';
        oportunidad.StageName = 'Cotización';
        oportunidad.CloseDate = Date.today();
        oportunidad.OFI_fld_Opportunity_TipoProducto__c = 'Oficinas';
        oportunidad.CEN_dia_de_pago__c = '1';
        insert oportunidad;
        Opportunity oppInicial = [
            SELECT 
                OFI_fld_Oportunidad_ArchivosOficinas__c, 
                OFI_fld_Oportunidad_ArchivosSalas__c, 
                IND_fld_Oportunidad_ArchivosIndustrial__c 
            FROM Opportunity 
            WHERE Id = :oportunidad.Id
        ];
        System.assertEquals(false, oppInicial.OFI_fld_Oportunidad_ArchivosOficinas__c);
        System.assertEquals(false, oppInicial.OFI_fld_Oportunidad_ArchivosSalas__c);
        System.assertEquals(false, oppInicial.IND_fld_Oportunidad_ArchivosIndustrial__c);
 
        Test.startTest();
        crearArchivo('cartafianza_cliente', 'pdf', oportunidad.Id);
        crearArchivo('contratofirmado_final', 'docx', oportunidad.Id);
        crearArchivo('actaentrega_v1', 'pdf', oportunidad.Id);
 
        Opportunity oppValidada = [
            SELECT OFI_fld_Oportunidad_ArchivosOficinas__c 
            FROM Opportunity 
            WHERE Id = :oportunidad.Id
        ];
        System.assertEquals(true, oppValidada.OFI_fld_Oportunidad_ArchivosOficinas__c);
 
        oportunidad.OFI_fld_Opportunity_TipoProducto__c = 'Salas';
        update oportunidad;
 
        crearArchivo('fichadereserva_sala', 'pdf', oportunidad.Id);
 
        oppValidada = [
            SELECT 
                OFI_fld_Oportunidad_ArchivosSalas__c, 
                OFI_fld_Oportunidad_ArchivosOficinas__c 
            FROM Opportunity 
            WHERE Id = :oportunidad.Id
        ];
        System.assertEquals(true, oppValidada.OFI_fld_Oportunidad_ArchivosSalas__c);
        System.assertEquals(false, oppValidada.OFI_fld_Oportunidad_ArchivosOficinas__c);
 
        oportunidad.RecordTypeId = obtenerIdTipoRegistro('Opportunity', 'IND_Industrial');
        oportunidad.OFI_fld_Opportunity_TipoProducto__c = null;
        update oportunidad;
 
        crearArchivo('constanciadepago_banco', 'pdf', oportunidad.Id);
        crearArchivo('contratofirmado_cliente', 'pdf', oportunidad.Id);
 
        oppValidada = [
            SELECT IND_fld_Oportunidad_ArchivosIndustrial__c 
            FROM Opportunity 
            WHERE Id = :oportunidad.Id
        ];
        System.assertEquals(true, oppValidada.IND_fld_Oportunidad_ArchivosIndustrial__c);
 
        ContentDocumentLink linkParaBorrar = [
            SELECT Id 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId = :oportunidad.Id 
              AND ContentDocument.Title LIKE '%constanciadepago%' 
            LIMIT 1
        ];
        delete linkParaBorrar;
 
        oppValidada = [
            SELECT IND_fld_Oportunidad_ArchivosIndustrial__c 
            FROM Opportunity 
            WHERE Id = :oportunidad.Id
        ];
        System.assertEquals(false, oppValidada.IND_fld_Oportunidad_ArchivosIndustrial__c);
 
        Test.stopTest();
    }
}