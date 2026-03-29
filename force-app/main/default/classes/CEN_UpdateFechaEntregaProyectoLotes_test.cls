/**
 * @name               : CEN_UpdateFechaEntregaProyectoLotes_test
 * @author             : Felipe Bermudez
 * @creation date      : 22-08-2025
 * @modification date  : 22-08-2025
 * @last modified by   : Felipe Bermudez
 * @description        : Clase test del apex CEN_UpdateFechaEntregaProyectoLotes
 * @versions           : version 1.0: clase apex inicial 
 * Modifications Log
 * Ver   Date         Author            Modification
 * 1.0   22-08-2025   Felipe Bermudez   Initial Version
 * 1.1   07-09-2025   Felipe Bermudez   Se subio el porcentaje con el nuevo cambio realizado a la clase apex Fecha entrega lote espejo
**/
@isTest
public with sharing class CEN_UpdateFechaEntregaProyectoLotes_test {
    @TestSetup
    static void SetUp() {
        // Crear un proyecto para las pruebas (caso positivo)
        Proyecto__c proyecto = new Proyecto__c(
            Name = 'Test Proyecto',
            CEN_CODIGOSAP__c = 'TEST123',
            CEN_Fecha_entrega__c = Date.newInstance(2025, 8, 13),
            CEN_Fecha_entrega_proyecto__c = Date.newInstance(2025, 8, 13),
            CEN_Estado_proyecto__c = 'Entregado',
            CEN_NumVecesUpdateOpp__c = 0
        );
        insert proyecto;

        // Crear oportunidades relacionadas para el proyecto con StageName = 'Cotización'
        List<Opportunity> oportunidades = new List<Opportunity>();
        oportunidades.add(new Opportunity(
            Name = 'Test Opp 1',
            CEN_Proyecto__c = proyecto.Id,
            CEN_Proforma__c = '12345',
            StageName = 'Cotización',
            CloseDate = Date.today(),
            CEN_Fecha_Entrega_Lote__c = null
        ));
        oportunidades.add(new Opportunity(
            Name = 'Test Opp 2',
            CEN_Proyecto__c = proyecto.Id,
            CEN_Proforma__c = '67890',
            StageName = 'Cotización',
            CloseDate = Date.today(),
            CEN_Fecha_Entrega_Lote__c = null
        ));
        insert oportunidades;

        // Crear un proyecto con estado no entregado
        Proyecto__c proyectoNoEntregado = new Proyecto__c(
            Name = 'Test Proyecto No Entregado',
            CEN_CODIGOSAP__c = 'TEST789',
            CEN_Fecha_entrega__c = Date.newInstance(2025, 8, 13),
            CEN_Fecha_entrega_proyecto__c = Date.newInstance(2025, 8, 13),
            CEN_Estado_proyecto__c = 'Sin Licencia',
            CEN_NumVecesUpdateOpp__c = 0
        );
        insert proyectoNoEntregado;
    }
    @isTest
	static void testListarLotesUpdateSinProformasCoincidentes() {
        // Crear proyecto con fecha de entrega y código SAP
        Proyecto__c proyecto = new Proyecto__c(
            Name = 'Proyecto Sin Coincidencias',
            CEN_CODIGOSAP__c = 'TESTNOCOIN',
            CEN_Fecha_entrega__c = Date.today(),
            CEN_Fecha_entrega_proyecto__c = Date.today(),
            CEN_Estado_proyecto__c = 'Entregado',
            CEN_NumVecesUpdateOpp__c = 0
        );
        insert proyecto;
    
        // Crear oportunidad con proforma que no coincidirá con las proformas del servicio
        Opportunity opp = new Opportunity(
            Name = 'Opp No Coincide',
            CEN_Proyecto__c = proyecto.Id,
            CEN_Proforma__c = 'PROF_NO',
            StageName = 'Cotización',
            CloseDate = Date.today()
        );
        insert opp;
        // Actualizar la oportunidad a 'Oportunidad Ganada' para que sea considerada en la lógica
        opp.StageName = 'Oportunidad Ganada';
        opp.CEN_Oficina_de_Venta__c='ZV015';
        update opp;
    
        Test.startTest();
        String response = CEN_UpdateFechaEntregaProyectoLotes.listarLotesUpdate(Date.today(), 'TESTNOCOIN', proyecto.Id);
        Test.stopTest();
    
        System.debug('Respuesta listarLotesUpdate sin coincidencias: ' + response);
    
        // Verificar que el mensaje indica que no se encontraron proformas coincidentes
        System.assert(response.contains('No se encontraron proformas coincidentes'), 'Debe indicar que no hay proformas coincidentes');
    
        // Verificar que la oportunidad no fue actualizada (fecha de entrega lote sigue null)
        Opportunity updatedOpp = [SELECT CEN_Fecha_Entrega_Lote__c FROM Opportunity WHERE Id = :opp.Id];
        System.assertEquals(null, updatedOpp.CEN_Fecha_Entrega_Lote__c, 'La fecha de entrega lote no debe actualizarse');
	}
    
    @isTest
    static void updateOpByProyectoId() {
        // Obtener el proyecto creado en el setup
        Proyecto__c proyecto = [SELECT Id, CEN_Fecha_entrega__c, CEN_NumVecesUpdateOpp__c 
                                FROM Proyecto__c 
                                WHERE Name = 'Test Proyecto' 
                                LIMIT 1];

        // Iniciar la prueba
        Test.startTest();
        String result = CEN_UpdateFechaEntregaProyectoLotes.updateOpByProyectoId(proyecto.Id);
        Test.stopTest();

        // Verificar que CEN_NumVecesUpdateOpp__c no se actualizó
        Proyecto__c updatedProyecto = [SELECT CEN_NumVecesUpdateOpp__c 
                                      FROM Proyecto__c 
                                      WHERE Id = :proyecto.Id];
        System.assertEquals(1, updatedProyecto.CEN_NumVecesUpdateOpp__c, 
                           'CEN_NumVecesUpdateOpp__c no debería actualizarse debido al error');
    }

    @isTest
    static void testUpdateOpByProyectoIdInvalidId() {
        Test.startTest();
        String result = CEN_UpdateFechaEntregaProyectoLotes.updateOpByProyectoId('');
        Test.stopTest();

        System.assertEquals('ID de proyecto no válido', result, 'El mensaje para ID inválido no es el esperado');
    }

    @isTest
    static void testValidarEstadoProyectoSuccess() {
        // Obtener el proyecto creado en el setup
        Proyecto__c proyecto = [SELECT Id 
                                FROM Proyecto__c 
                                WHERE Name = 'Test Proyecto' 
                                LIMIT 1];

        Test.startTest();
        Boolean result = CEN_UpdateFechaEntregaProyectoLotes.validarEstadoProyecto(proyecto.Id);
        Test.stopTest();

        System.assertEquals(true, result, 'El proyecto debería ser válido (estado Entregado y CEN_NumVecesUpdateOpp__c = 0)');
    }

    @isTest
    static void testValidarEstadoProyectoInvalidId() {
        Test.startTest();
        Boolean result = CEN_UpdateFechaEntregaProyectoLotes.validarEstadoProyecto('');
        Test.stopTest();

        System.assertEquals(false, result, 'Debería retornar false para un ID inválido');
    }

    @isTest
    static void testValidarEstadoProyectoNotEntregado() {
        // Obtener el proyecto con estado no entregado
        Proyecto__c proyecto = [SELECT Id 
                                FROM Proyecto__c 
                                WHERE Name = 'Test Proyecto No Entregado' 
                                LIMIT 1];

        Test.startTest();
        Boolean result = CEN_UpdateFechaEntregaProyectoLotes.validarEstadoProyecto(proyecto.Id);
        Test.stopTest();

        System.assertEquals(false, result, 'Debería retornar false si el estado no es Entregado');
    }
    
    @isTest
    static void testListarLotesUpdateConProformasCoincidentes() {
        // Obtener proyecto del @TestSetup
        Proyecto__c proyecto = [SELECT Id, CEN_CODIGOSAP__c, CEN_Fecha_entrega_proyecto__c
                                FROM Proyecto__c
                                WHERE Name = 'Test Proyecto'
                                LIMIT 1];

        // Actualizar oportunidades del proyecto para que tengan StageName = Oportunidad Ganada y CEN_Oficina_de_Venta__c
        List<Opportunity> oportunidades = [SELECT Id, CEN_Proforma__c, StageName
                                        FROM Opportunity
                                        WHERE CEN_Proyecto__c = :proyecto.Id];

        for (Opportunity opp : oportunidades) {
            opp.StageName = 'Oportunidad Ganada';
            opp.CEN_Oficina_de_Venta__c = 'ZV015';
        }
        update oportunidades;

        // Ejecutar el método
        Test.startTest();
        String response = CEN_UpdateFechaEntregaProyectoLotes.listarLotesUpdate(
            proyecto.CEN_Fecha_entrega_proyecto__c,
            proyecto.CEN_CODIGOSAP__c,
            proyecto.Id
        );
        Test.stopTest();

        System.debug('<<< RESPONSE_COINCIDENCIAS >>> ' + response);

        // Validar que el mensaje NO sea "No se encontraron..."
        System.assert(!response.contains('No se encontraron proformas coincidentes'),
                    'Se esperaban proformas coincidentes');

        // Validar que las fechas se hayan seteado correctamente
        List<Opportunity> updatedOpps = [
            SELECT CEN_Fecha_Entrega_Lote__c, CEN_Fecha_EntregaLote_Espejo__c
            FROM Opportunity
            WHERE CEN_Proyecto__c = :proyecto.Id
        ];

        for (Opportunity opp : updatedOpps) {
            System.assertNotEquals(null, opp.CEN_Fecha_Entrega_Lote__c,
                'La fecha de entrega lote debe estar asignada');
            System.assertNotEquals(null, opp.CEN_Fecha_EntregaLote_Espejo__c,
                'El campo espejo debe estar asignado');
        }
	}
}