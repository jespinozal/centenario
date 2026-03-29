/*********************************************************************
* @author: Alfredo Morote (amorotet@nttdata.com)
* @date: 10-12-2025
* @description: Test de la clase Apex ONI_CargaArchivosHandler_cls para
*               la validación de carga de archivos en registros de Evaluación
*
* VERSION      DATE                 AUTOR                     ACTION
* 0.1          10-12-2025           Alfredo Morote            Creación
*********************************************************************/
@IsTest
private class ONI_CargaArchivosHandler_tst {

    /* ============================================================
       MÉTODOS AUXILIARES
       ============================================================ */

    /**
     * Crea un registro real de Evaluación para obtener
     * el prefijo correcto del objeto.
     */
    private static Id createEvaluacion() {
        OFI_obj_Evaluacion__c eval = new OFI_obj_Evaluacion__c(
            Name = 'Evaluación Test'
        );
        insert eval;
        return eval.Id;
    }

    /**
     * Construye un ContentVersion genérico para los tests.
     */
    private static ContentVersion buildContentVersion(
        Id firstPublishLocationId,
        String pathOnClient
    ) {
        ContentVersion cv = new ContentVersion();
        cv.FirstPublishLocationId = firstPublishLocationId;
        cv.PathOnClient = pathOnClient;
        cv.Title = 'Archivo de prueba';
        cv.VersionData = Blob.valueOf('contenido de prueba');
        cv.Origin = 'H';
        return cv;
    }

    /* ============================================================
       TESTS
       ============================================================ */

    /**
     * Caso: Evaluación + extensión válida (pdf).
     * No debe generarse ningún error.
     */
    @IsTest
    static void testExtensionValida() {
        Id evaluacionId = createEvaluacion();

        ContentVersion cvPdf = buildContentVersion(
            evaluacionId,
            'C:\\temp\\archivo.pdf'
        );

        List<ContentVersion> lista = new List<ContentVersion>{ cvPdf };

        Test.startTest();
        ONI_CargaArchivosHandler_cls.validaTipoArchivo(lista);
        Test.stopTest();

        System.assert(true,
            'La extensión válida no debe generar errores.'
        );
    }

    /**
     * Caso: Evaluación + extensión válida en mayúsculas (JPG).
     * Valida conversión a minúsculas.
     */
    @IsTest
    static void testExtensionValidaMayusculas() {
        Id evaluacionId = createEvaluacion();

        ContentVersion cvJpg = buildContentVersion(
            evaluacionId,
            'C:\\temp\\imagen.JPG'
        );

        List<ContentVersion> lista = new List<ContentVersion>{ cvJpg };

        Test.startTest();
        ONI_CargaArchivosHandler_cls.validaTipoArchivo(lista);
        Test.stopTest();

        System.assert(true,
            'Las extensiones en mayúsculas deben aceptarse.'
        );
    }

    /**
     * Caso: Evaluación + extensión inválida.
     * Se debe ejecutar la rama del addError.
     */
    @IsTest
    static void testExtensionInvalida() {
        Id evaluacionId = createEvaluacion();

        ContentVersion cvExe = buildContentVersion(
            evaluacionId,
            'C:\\temp\\archivo.exe'
        );

        Test.startTest();
        try {
            insert cvExe;
            System.assert(
                false,
                'Se esperaba un error por extensión inválida.'
            );
        } catch (DmlException e) {
            System.assert(
                e.getDmlMessage(0).contains('El tipo de archivo no es válido'),
                'El mensaje de error no es el esperado.'
            );
        }
        Test.stopTest();
    }


    /**
     * Caso: Prefijo distinto al de Evaluación.
     * Aunque la extensión sea inválida, no debe validarse.
     */
    @IsTest
    static void testPrefijoDistintoEvaluacion() {
        // Simulamos un Id de Account
        Id accountLikeId = (Id) '001000000000001AAA';

        ContentVersion cvExe = buildContentVersion(
            accountLikeId,
            'C:\\temp\\archivo.exe'
        );

        List<ContentVersion> lista = new List<ContentVersion>{ cvExe };

        Test.startTest();
        ONI_CargaArchivosHandler_cls.validaTipoArchivo(lista);
        Test.stopTest();

        System.assert(true,
            'Con prefijo distinto no debe ejecutarse la validación.'
        );
    }

    /**
     * Caso: PathOnClient = null.
     * No debe intentarse validar la extensión.
     */
    @IsTest
    static void testPathOnClientNull() {
        Id evaluacionId = createEvaluacion();

        ContentVersion cvSinPath = buildContentVersion(
            evaluacionId,
            null
        );

        List<ContentVersion> lista = new List<ContentVersion>{ cvSinPath };

        Test.startTest();
        ONI_CargaArchivosHandler_cls.validaTipoArchivo(lista);
        Test.stopTest();

        System.assert(true,
            'PathOnClient null no debe provocar errores.'
        );
    }

    /**
     * Caso: FirstPublishLocationId = null.
     * Debe ejecutarse el continue sin lanzar excepción.
     */
    @IsTest
    static void testFirstPublishLocationIdNull() {
        ContentVersion cvSinParent = buildContentVersion(
            null,
            'C:\\temp\\archivo.pdf'
        );

        List<ContentVersion> lista = new List<ContentVersion>{ cvSinParent };

        Test.startTest();
        ONI_CargaArchivosHandler_cls.validaTipoArchivo(lista);
        Test.stopTest();

        System.assert(true,
            'No debe producirse error cuando FirstPublishLocationId es null.'
        );
    }
}