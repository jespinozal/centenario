//Developer: Jose Miguel Espinoza Mestanza
//Email: josemiguel.espinozamestanza@emeal.nttdata.com
@IsTest
private class CEN_AdjuntosRelacionadosController_tst {

    private static Id crearDocumento(String titulo, String nombreArchivo) {
        ContentVersion cv = new ContentVersion(
            Title        = titulo,
            PathOnClient = nombreArchivo,
            VersionData  = Blob.valueOf('Contenido de ' + titulo)
        );
        insert cv;
        return [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1]
               .ContentDocumentId;
    }

    @testSetup
    static void datosBase() {
        List<Case> casos = new List<Case>{
            new Case(Subject = 'Caso A', Status = 'New'),
            new Case(Subject = 'Caso B', Status = 'New')
        };
        insert casos;

        Id docA1 = crearDocumento('A1', 'a1.pdf');
        Id docA2 = crearDocumento('A2', 'a2.pdf');
        Id docB1 = crearDocumento('B1', 'b1.pdf');

        insert new List<CEN_AdjuntoRelacionado__c>{
            new CEN_AdjuntoRelacionado__c(
                Name='AR A1', CEN_CaseID__c=casos[0].Id, CEN_NombreArchivo__c='a1.pdf',
                CEN_IdDocumento__c=String.valueOf(docA1), CEN_TipoOrigen__c='File', CEN_Archivado__c=false
            ),
            new CEN_AdjuntoRelacionado__c(
                Name='AR A2', CEN_CaseID__c=casos[0].Id, CEN_NombreArchivo__c='a2.pdf',
                CEN_IdDocumento__c=String.valueOf(docA2), CEN_TipoOrigen__c='File', CEN_Archivado__c=true
            ),
            new CEN_AdjuntoRelacionado__c(
                Name='AR B1', CEN_CaseID__c=casos[1].Id, CEN_NombreArchivo__c='b1.pdf',
                CEN_IdDocumento__c=String.valueOf(docB1), CEN_TipoOrigen__c='File', CEN_Archivado__c=false
            )
        };
    }

    @IsTest
    static void obtenerAdjuntosPorCaso_devuelveAsociados() {
        Case casoA = [SELECT Id FROM Case WHERE Subject='Caso A' LIMIT 1];

        Test.startTest();
        List<CEN_AdjuntoRelacionado__c> res = CEN_AdjuntosRelacionadosController.obtenerAdjuntosPorCaso(casoA.Id);
        Test.stopTest();

        System.assertEquals(2, res.size(), 'Caso A debe tener 2 adjuntos (archivado y no archivado).');
        Set<String> archivos = new Set<String>();
        for (CEN_AdjuntoRelacionado__c ar : res) archivos.add(ar.CEN_NombreArchivo__c);
        System.assert(archivos.contains('a1.pdf') && archivos.contains('a2.pdf'), 'Debe incluir a1.pdf y a2.pdf.');
    }

    @IsTest
    static void obtenerAdjuntosPorCaso_devuelveVacio_siCaseNull() {
        Test.startTest();
        List<CEN_AdjuntoRelacionado__c> res = CEN_AdjuntosRelacionadosController.obtenerAdjuntosPorCaso(null);
        Test.stopTest();
        System.assertEquals(0, res.size(), 'Con caseId null debe devolver lista vacía.');
    }

    @IsTest
    static void obtenerAdjuntosPorCasoYTipo_conTipoNull_noFalla() {
        Case casoA = [SELECT Id FROM Case WHERE Subject='Caso A' LIMIT 1];

        Test.startTest();
        List<CEN_AdjuntoRelacionado__c> res = CEN_AdjuntosRelacionadosController.obtenerAdjuntosPorCasoYTipo(casoA.Id, null);
        Test.stopTest();

        System.assertNotEquals(null, res, 'Debe devolver una lista (vacía o no) sin error.');
    }

    @IsTest
    static void obtenerAdjuntosPorCasoYSeccion_filtraPorArchivado_conSeccionNull() {
        Case casoA = [SELECT Id FROM Case WHERE Subject='Caso A' LIMIT 1];

        Id docA3 = crearDocumento('A3', 'a3.pdf');
        Id docA4 = crearDocumento('A4', 'a4.pdf');

        CEN_AdjuntoRelacionado__c arNoArchivado = new CEN_AdjuntoRelacionado__c(
            Name = 'AR A3',
            CEN_CaseID__c = casoA.Id,
            CEN_NombreArchivo__c = 'a3.pdf',
            CEN_IdDocumento__c = String.valueOf(docA3),
            CEN_TipoOrigen__c = 'File',
            CEN_Archivado__c = false,
            CEN_TipoDocumentoCaso__c = 'Acta de Entrega de Documentos'
        );
        CEN_AdjuntoRelacionado__c arArchivado = new CEN_AdjuntoRelacionado__c(
            Name = 'AR A4',
            CEN_CaseID__c = casoA.Id,
            CEN_NombreArchivo__c = 'a4.pdf',
            CEN_IdDocumento__c = String.valueOf(docA4),
            CEN_TipoOrigen__c = 'File',
            CEN_Archivado__c = true,
            CEN_TipoDocumentoCaso__c = 'Acta de Entrega de Documentos'
        );
        insert new List<CEN_AdjuntoRelacionado__c>{ arNoArchivado, arArchivado };
    
        arNoArchivado = [
            SELECT Id, CEN_Seccion__c
            FROM CEN_AdjuntoRelacionado__c
            WHERE Id = :arNoArchivado.Id
            LIMIT 1
        ];
        String seccion = arNoArchivado.CEN_Seccion__c;
    
        Test.startTest();
        List<CEN_AdjuntoRelacionado__c> noArchivados = CEN_AdjuntosRelacionadosController.obtenerAdjuntosPorCasoYSeccion(casoA.Id, seccion, false);
        List<CEN_AdjuntoRelacionado__c> archivados = CEN_AdjuntosRelacionadosController.obtenerAdjuntosPorCasoYSeccion(casoA.Id, seccion, true);
        Test.stopTest();
    
        System.assertEquals(1, noArchivados.size(), 'Debe traer 1 no archivado para la sección derivada.');
        System.assertEquals('a3.pdf', noArchivados[0].CEN_NombreArchivo__c, 'Debe ser el no archivado (a3.pdf).');
    
        System.assertEquals(1, archivados.size(), 'Debe traer 1 archivado para la sección derivada.');
        System.assertEquals('a4.pdf', archivados[0].CEN_NombreArchivo__c, 'Debe ser el archivado (a4.pdf).');
	}    
}