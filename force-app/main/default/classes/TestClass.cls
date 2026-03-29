/**
 * @name               : 
 * @author             : Luis Maldonado
 * @creation date      : 
 * @modification date  : 08-10-2024
 * @last modified by   : Luis Maldonado
 * @description        : 
 * @versions           : version 1.0: clase apex inicial 
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   08-10-2024   Luis Maldonado   Initial Version
**/
@isTest
private class TestClass {

  @testSetup
  private static void setup() {
    List<Lead> leads = CEN_cls_TestClass_DF.getLeads();
    insert leads;

    List<User> usuarios = CEN_cls_TestClass_DF.getUsers();
      for(User uss: usuarios){
          uss.Caseta_de_Venta__c = 'ZV022';
      }

    insert usuarios;

    List<Account> cuentas = CEN_cls_TestClass_DF.getAccounts();
    cuentas[1].OwnerId = usuarios[0].Id;
    insert cuentas;

    List<Event> eventos = CEN_cls_TestClass_DF.getEvents();
    eventos[0].WhoId = leads[0].Id;
      eventos[0].CEN_Oficina__c = 'ZV022';
    eventos[1].WhoId = cuentas[1].PersonContactId;
      eventos[1].CEN_Oficina__c = 'ZV022';

    insert eventos;

    List<Attachment> attachments = CEN_cls_TestClass_DF.getAttachments();
    attachments[0].parentId = cuentas[1].Id;
    insert attachments;

    List<Tabla_maestra__c> distritos = CEN_cls_TestClass_DF.getDistritos();
    insert distritos;

    List<Proyecto__c> proyectos = CEN_cls_TestClass_DF.getProyectos();
    proyectos[0].CEN_Distrito__c = distritos[0].Id;
    insert proyectos;

    List<Opportunity> oportunidades = CEN_cls_TestClass_DF.getOpportunities();
    oportunidades[0].AccountId = cuentas[1].Id;
    oportunidades[0].CEN_Proyecto__c = proyectos[0].Id;
    oportunidades[0].CEN_dia_de_pago__c = '1';
    oportunidades[0].CEN_Motivo_de_Compra__c = 'Inversión';
    oportunidades[0].StageName = 'Cotización';
    insert oportunidades;

    Quote cotizacion = new Quote();
    cotizacion.Name='Coti';
    cotizacion.OpportunityId=oportunidades[0].Id;
    cotizacion.Pricebook2Id = Test.getStandardPricebookId();
    insert cotizacion;

    List<Product2> productos = CEN_cls_TestClass_DF.getProducts();
    productos[0].CEN_Proyecto__c = proyectos[0].Id;
    productos[0].CEN_PRECIOVENTAFUN__c = '150000';
    productos[0].CODMONEDAFUNCIONAL__c = 'PEN';
    insert productos;

    List<Pricebook2> pricebooks = CEN_cls_TestClass_DF.getPricebook2s();
    insert pricebooks;

    List<PricebookEntry> pricebookentries = CEN_cls_TestClass_DF.getPricebookEntries();
    pricebookentries[0].Product2ID = productos[0].Id;
    pricebookentries[0].Pricebook2Id = Test.getStandardPricebookId();
    insert pricebookentries;

    //List<Case> casos = CEN_cls_TestClass_DF.getCases();
    //casos[0].ContactId = cuentas[2].PersonContactId;
    //insert casos;
    Case caso = new Case();
        caso.Subject = 'Interacción - Entrega de documentos - Cláusula de prepago';
        caso.Description = 'El cliente quiere la entrega de sus documentos por correo.';
        caso.Status = 'En proceso';
        //caso.ContactId = cuentas[2].PersonContactId;
        caso.CEN_Actualizar_Datos__c = true;
        caso.Reason = 'Entrega de documentos';
        caso.CEN_Sub_Categoria__c ='Cláusula de prepago';
        caso.Origin ='Presencial';
        caso.Type ='Solicitud';
        caso.CEN_Area_Responsable__c = 'Post venta';
      	caso.CEN_Tipifica_Solucion__c = 'Procedente';
    insert caso;
      
    // Crear RecordTypes de prueba para Event
    RecordType rt = [SELECT Id 
                         FROM RecordType 
                         WHERE SObjectType = 'Event' 
                         AND DeveloperName = 'CEN_Reunion_presencial_Visita_presencial' 
                         LIMIT 1];
    System.debug('recordssss: ' + rt);
      
    // Crear un Evento de prueba
        Event testEvent = new Event(
            WhoId = leads[0].Id, 
            Subject = 'Test Event',
            StartDateTime = System.now().addDays(-1),
            EndDateTime = System.now().addHours(1),
            ActivityDate = System.today(),
            RecordTypeId = rt.Id // Asignar el RecordType específico
        );
        insert testEvent;
       
  }

  @isTest
  private static void a_info_alerta_prospecto_cuenta() {
    List<Account> cuentas = [
      SELECT
        Id,
        PersonContactId,
        CEN_Tipo_de_documento__pc,
        CEN_N_mero_de_documento__pc,
        FirstName,
        LastName,
        CEN_Direcci_n__c
      FROM Account
      ORDER BY FirstName ASC
    ];
    List<Lead> leads = [SELECT Id, FirstName FROM Lead ORDER BY FirstName ASC];
    List<Tabla_maestra__c> distritos = [
      SELECT Id
      FROM Tabla_maestra__c
      ORDER BY Name ASC
    ];
    List<Event> eventos = [SELECT Id FROM Event ORDER BY Subject ASC];
    List<User> usuarios = [SELECT Id FROM User ORDER BY LastName ASC];

    string ld = 'Lead';
    string acc = 'Account';
    string pros = 'Prospecto';

    Test.startTest();
    CEN_ImagenCuenta.getInfoFromContact(cuentas[1].id);
    CEN_ImagenCuenta.getInfoFromObject(cuentas[1].id, 'Account');

    CEN_AlertaProspecto.getAlertasProspecto(leads[1].Id, ld);
    CEN_AlertaProspecto.getAlertasProspecto(leads[2].Id, ld);
    CEN_AlertaProspecto.getAlertasProspecto(leads[3].Id, ld);
    CEN_AlertaProspecto.getAlertasProspecto(cuentas[0].Id, acc);
    System.debug(
      'SOQL LIMITS: ' +
      String.valueOf(Limits.getLimitQueries() - Limits.getQueries())
    );
    Test.stopTest();
    System.debug(
      'SOQL LIMITS: ' +
      String.valueOf(Limits.getLimitQueries() - Limits.getQueries())
    );
  }
  @isTest
  private static void b_select() {
    List<Account> cuentas = [
      SELECT
        Id,
        PersonContactId,
        CEN_Tipo_de_documento__pc,
        CEN_N_mero_de_documento__pc,
        FirstName,
        LastName,
        CEN_Direcci_n__c
      FROM Account
      ORDER BY FirstName ASC
    ];

    //List<Lead> leads = [
    //  SELECT 
    //  Id,
    //  CEN_Tipo_de_documento__c,
    //  FirstName,
    //  LastName,
    //  Email,
    //  MobilePhone,
    //  CEN_Direcci_n_Prospecto__c,
    //  CEN_Distrito__c,
    //  CEN_N_mero_de_documento__c
    //  FROM Lead 
    //  ORDER BY FirstName ASC];

    List<Lead> leads = [SELECT Id, FirstName FROM Lead ORDER BY FirstName ASC];
    System.debug('lista leadssss: ' + leads);

    List<Tabla_maestra__c> distritos = [
      SELECT Id
      FROM Tabla_maestra__c
      ORDER BY Name ASC
    ];
    List<Event> eventos = [SELECT Id, Subject, StartDateTime, EndDateTime FROM Event ORDER BY Subject ASC];
    List<User> usuarios = [SELECT Id FROM User ORDER BY LastName ASC];

    Test.startTest();
    CEN_busquedaDNI.getselectDoc(
      cuentas[0].CEN_Tipo_de_documento__pc,
      cuentas[0].CEN_N_mero_de_documento__pc
    );

    /*CEN_busquedaDNI.getEventId(
      leads[0].Id
    );*/

    CEN_busquedaDNI.getselectEve(
      cuentas[1].id,
      'Venta',
      'Se genero Visita',
      cuentas[1].CEN_N_mero_de_documento__pc,
      cuentas[1].FirstName,
      cuentas[1].LastName,
      'renzo.rivera@proactiviti.com',
      '972715766',
      cuentas[1].CEN_Direcci_n__c,
      distritos[0].Id,
      'Preferencial',
      null,
      null,
      '0118'
    );

    List<Attachment> attachments = [
      SELECT id, name
      FROM Attachment
      WHERE parent.id = :leads[3].id
    ];
    ApexPages.StandardController stdCtr = new ApexPages.StandardController(
      leads[3]
    );
    CEN_cls_LeadAttach ccp = new CEN_cls_LeadAttach(stdCtr);
    ccp.pr = leads[3];
    ccp.attach();

    List<Attachment> attachments2 = [
      SELECT id, name
      FROM Attachment
      WHERE parent.id = :cuentas[1].id
    ];
    ApexPages.StandardController stdCtr2 = new ApexPages.StandardController(
      cuentas[1]
    );
    CEN_cls_AccountAttach ccp2 = new CEN_cls_AccountAttach(stdCtr2);
    ccp2.pr = cuentas[1];
    ccp2.attach();

    System.debug(
      'SOQL LIMITS: ' +
      String.valueOf(Limits.getLimitQueries() - Limits.getQueries())
    );
    Test.stopTest();
    System.debug(
      'SOQL LIMITS: ' +
      String.valueOf(Limits.getLimitQueries() - Limits.getQueries())
    );
  }
  
  @isTest
  private static void c_account() {
    List<Account> cuentas = [
      SELECT
        Id,
        PersonContactId,
        CEN_Tipo_de_documento__pc,
        CEN_N_mero_de_documento__pc,
        FirstName,
        LastName,
        CEN_Direcci_n__c
      FROM Account
      ORDER BY FirstName ASC
    ];
    List<Lead> leads = [
      SELECT
        Id,
        FirstName,
        Company,
        CEN_RUC__c,
        CEN_N_mero_de_documento__c,
        LastName,
        Email,
        MobilePhone,
        CEN_Direcci_n_Prospecto__c
      FROM Lead
      ORDER BY FirstName ASC
    ];
    List<Tabla_maestra__c> distritos = [
      SELECT Id
      FROM Tabla_maestra__c
      ORDER BY Name ASC
    ];
    List<Event> eventos = [SELECT Id FROM Event ORDER BY Subject ASC];
    List<User> usuarios = [SELECT Id FROM User ORDER BY LastName ASC];
    User us1 = [SELECT Id, Name FROM User WHERE LastName = 'A00001 last'];
    User us2 = [SELECT Id, Name FROM User WHERE LastName = 'A00002 last'];

    System.debug(
      'SOQL LIMITS: ' +
      String.valueOf(Limits.getLimitQueries() - Limits.getQueries())
    );

    Test.startTest();
    List<Attachment> attachments = [
      SELECT id, name
      FROM Attachment
      WHERE parent.id = :leads[3].id
    ];
    ApexPages.StandardController stdCtr = new ApexPages.StandardController(
      leads[3]
    );
    CEN_cls_LeadAttach ccp = new CEN_cls_LeadAttach(stdCtr);
    ccp.pr = leads[3];
    ccp.attach();

    List<Attachment> attachments2 = [
      SELECT id, name
      FROM Attachment
      WHERE parent.id = :cuentas[1].id
    ];
    ApexPages.StandardController stdCtr2 = new ApexPages.StandardController(
      cuentas[1]
    );
    CEN_cls_AccountAttach ccp2 = new CEN_cls_AccountAttach(stdCtr2);
    ccp2.pr = cuentas[1];
    ccp2.attach();

    CEN_cls_LeadAttach_insert.createPDF(leads[3].id);
    CEN_SMS.getSMS(eventos[0].id);

    CEN_SMS.getSMS(eventos[1].id);
    /*CEN_Prospectoempresa.getProspectoEmpresa(
      leads[3].Company,
      leads[3].CEN_RUC__c,
      leads[3].Id
    );*/

    Boolean debeUsarOAC = false;
    List<CEN_busquedaDNI.PickListWrapper> listaSeleccionOAC = new List<CEN_busquedaDNI.PickListWrapper>();
    String oacElegido = null;

    System.runAs(us1) {
      debeUsarOAC = CEN_busquedaDNI.getObligacionElegirOAC();
      listaSeleccionOAC = CEN_busquedaDNI.getOACs();
      if (!listaSeleccionOAC.isEmpty()) {
        oacElegido = listaSeleccionOAC[0].value;
      }
      CEN_busquedaDNI.getselectEve(
        leads[3].Id,
        'Prospecto',
        'Venta',
        leads[3].CEN_N_mero_de_documento__c,
        leads[3].FirstName,
        leads[3].LastName,
        leads[3].Email,
        leads[3].MobilePhone,
        leads[3].CEN_Direcci_n_Prospecto__c,
        distritos[0].Id,
        'Preferencial',
        null,
        oacElegido,
        '0118'
      );
      CEN_busquedaDNI.getselectEve(
        cuentas[1].id,
        'Cuenta',
        'Venta',
        cuentas[1].CEN_N_mero_de_documento__pc,
        cuentas[1].FirstName,
        cuentas[1].LastName,
        'renzo.rivera@proactiviti.com',
        '972715766',
        cuentas[1].CEN_Direcci_n__c,
        distritos[0].Id,
        'Preferencial',
        null,
        oacElegido,
        '0118'
      );
    }

    System.runAs(us2) {
      debeUsarOAC = CEN_busquedaDNI.getObligacionElegirOAC();
      listaSeleccionOAC = CEN_busquedaDNI.getOACs();
      if (!listaSeleccionOAC.isEmpty()) {
        oacElegido = listaSeleccionOAC[0].value;
      }
      CEN_busquedaDNI.getselectEve(
        leads[3].Id,
        'Prospecto',
        'Venta',
        leads[3].CEN_N_mero_de_documento__c,
        leads[3].FirstName,
        leads[3].LastName,
        leads[3].Email,
        leads[3].MobilePhone,
        leads[3].CEN_Direcci_n_Prospecto__c,
        distritos[0].Id,
        'Preferencial',
        null,
        oacElegido,
        '0118'
      );
      CEN_busquedaDNI.getselectEve(
        cuentas[1].id,
        'Cuenta',
        'Venta',
        cuentas[1].CEN_N_mero_de_documento__pc,
        cuentas[1].FirstName,
        cuentas[1].LastName,
        '',
        '972715766',
        cuentas[1].CEN_Direcci_n__c,
        distritos[0].Id,
        'Preferencial',
        null,
        oacElegido,
        '0118'
      );
    }

    dataTableCtrl.fetchAccountWrapper('10U1.230E');

    try {
      leads[3].CEN_Distrito__c = distritos[1].id;
      leads[3].CEN_Direcci_n_de_centro_de_trabajo__c = 'nuevo';
      leads[3].CEN_Distrito_Empresa__c = distritos[1].id;
      update leads[3];
      leads[3].Status = 'Convertido';
      update leads[3];
    } catch (exception e) {
    }
    System.debug(
      'SOQL LIMITS: ' +
      String.valueOf(Limits.getLimitQueries() - Limits.getQueries())
    );
    Test.stopTest();
  }
    
  @isTest
  private static void d_cotizar() {
    CEN_cls_VisorLotes.CotizacionGeneradaWrapper respuesta = new CEN_cls_VisorLotes.CotizacionGeneradaWrapper();
    CEN_cls_VisorLotes.DatosPersonaWrapper datosPersona = new CEN_cls_VisorLotes.DatosPersonaWrapper();    
    List<Opportunity> oportunidades = [SELECT Id FROM Opportunity];
    List<CEN_cls_VisorLotes.LoteReceived> lotesList = new List<CEN_cls_VisorLotes.LoteReceived>();
    List<CEN_cls_utilsQuote.DatoAnotacionesWrapper> anotaciones = new List<CEN_cls_utilsQuote.DatoAnotacionesWrapper>();    
    CEN_cls_utilsQuote.DatoAnotacionesWrapper anotacion = new CEN_cls_utilsQuote.DatoAnotacionesWrapper();
    List<String> codigosLotesRecotizables_result1 = new List<String>();
    List<String> codigosLotesRecotizables_result2 = new List<String>();
    CEN_cls_VisorLotes.LoteReceived loter = new CEN_cls_VisorLotes.LoteReceived();
    loter.Area = 99;
    loter.Codestadolote = 'Libre';
    loter.Codlote = '840001257';
    loter.Descripcionlote = 'LAS PALMERAS ETAPA 4 Mz.F Lt.06';
    loter.FillerStr02 = 'FRENTE CALLE';
    loter.Idproyecto = '10U1.231E';
    loter.Manzana = 'F4';
    loter.Precioventafun = 63558;
    loter.Precioventam2fun = 642;
    loter.isVisible = true;
    loter.isChecked = true;
    loter.PrecioVentaDscto = 60000;
    loter.Orden = 1;
    loter.Descripcioncorta = 'LPALMERASE4';
    lotesList.add(loter);
    lotesList.add(loter);
    List<Proyecto__c> proyectos = [
      SELECT Id, Zona__c FROM Proyecto__c WHERE CEN_CODIGOSAP__c = :loter.Idproyecto
    ];

    Test.startTest();

    codigosLotesRecotizables_result1 = CEN_cls_VisorLotes.getCodigosLotesRecotizables(oportunidades[0].Id);

    List<Tasa_variable__mdt> tasas = CEN_cls_VisorLotes.getTasasMdt(proyectos[0].Zona__c);
    CEN_cls_VisorLotes.data dataObj = new CEN_cls_VisorLotes.data();
    dataObj.codtasa = 'TASA1';
    dataObj.tasa = '26';
    dataObj.opcionDesembolso = 'OPCION A';
    dataObj.frecuenciaDesembolso = '1';
    dataObj.fechaDesembolso = '13/03/2024';
    respuesta = CEN_cls_VisorLotes.getcreateCotiz(
      datosPersona.datosPersona, //datosPersona
      lotesList, //lotesList
      anotaciones, //anotacionesList
      oportunidades[0].Id, //IdOportunidad
      100, //area
      200, //preciom2
      2000, //PrecioVenta
      20, //precioTotalDscto
      1000, //Iniporcentajevalue
      10, //Inicial
      10, //ncuotasinicial
      false, //bolMontoPrimeraCuota
      1000, //montocuota
      false, //isFacilote
      100000, //monotofinan
      60, //cuotasfinan
      10, //numCuotasSI
      '2022-06-14', //fecCuotaSaldoIni
      '2022-06-14', //fecCuotaSaldoFin
      23, //tasainteres
      10000,  //monotocuotafinan
      //10000,
      false, //esCotizacionLibre
      1000, //montoAdelanto
      true, //bolMontoAdelanto
      'PEN', //moneda
      'CD', //tipoVenta
      true, //simulador
      ''  ,//idCotizacionSimulador
      '[{"levers":[{"codigo":"PALANCA1","promocion":"PROMO0010","porcentaje":"15.3","importe":"15000.0","moneda":"PEN","descripcionPalanca":"TACTICO","aprobador":true}]},{"criteria":{"importeEspecial":0,"importeAdicional":0,"porcentajeEspecial":0,"porcentajeAdicional":0,"motivoInformativa":""}}]'  ,//jsonPalancas
      true,  //hasPermission
      dataObj, //TasaYDesembolso
      100 //MontoCuotaRestanteFinanciamiento
    );

    CEN_cls_VisorLotes.generarPDF(respuesta.cotizacion.Id, oportunidades[0].Id);

    codigosLotesRecotizables_result2 = CEN_cls_VisorLotes.getCodigosLotesRecotizables(oportunidades[0].Id);

    Test.stopTest();
    System.assertNotEquals(NULL, respuesta.cotizacion);
    System.assertEquals(true, respuesta.ok);
    // validacion de lotes recotizables
    System.assert(codigosLotesRecotizables_result1.isEmpty());
    System.assert(!codigosLotesRecotizables_result2.isEmpty());
  }

  @isTest
  private static void d_cotizarSimulador() {
    CEN_cls_VisorLotes.CotizacionGeneradaWrapper respuesta = new CEN_cls_VisorLotes.CotizacionGeneradaWrapper();
    CEN_cls_VisorLotes.DatosPersonaWrapper datosPersona = new CEN_cls_VisorLotes.DatosPersonaWrapper();
    List<Opportunity> oportunidades = [SELECT Id FROM Opportunity];
    List<Quote> cotizacion = [SELECT Id,
    Name,
    OpportunityId,
    Pricebook2Id,
    CEN_Area__c,
    CEN_Precio_por_mt2__c,
    CEN_Precio_de_venta__c,
    CEN_Inicial__c,
    CEN_Cuota_inicial__c,
    CEN_Inicial_porct__c,
    CEN_N_cuotas_de_inicial_de_precio__c,
    CEN_Monto_cuota_de_inicial_de_precio__c,
    CEN_Cuota_Facilote__c,
    CEN_Saldo_del_precio__c,
    CEN_Numero_de_cuotas_a_financiar__c,
    CEN_N_cuotas_del_saldo_de_precio__c,
    CEN_Tasa_de_Interes_compensatorio_anual__c,
    CEN_Monto_cuota_del_saldo_de_precio__c,
    CEN_Tipologia__c,
    CEN_Lote__c,
    CEN_Manzana__c,
    CEN_fld_Libre__c,
    CEN_Precio_de_venta_con_descuento__c,
    CEN_Moneda__c,
    CEN_TypeOfSale__c,
    CEN_FirstInstallmentAmount__c,
    CEN_Simulator__c,
    CEN_NumberInstallmentsSI__c,
    CEN_DateBalanceInstallment__c,
    CEN_DateEndBalanceInstallment__c,
    CEN_fld_anotaciones__c,
    CEN_fld_nombres__c,
    CEN_fld_apellidos__c,
    CEN_fld_tipoDocumento__c,
    CEN_fld_nroDocumento__c,
    CEN_fld_celular__c
    FROM Quote];
    List<CEN_cls_VisorLotes.LoteReceived> lotesList = new List<CEN_cls_VisorLotes.LoteReceived>();
    List<CEN_cls_utilsQuote.DatoAnotacionesWrapper> anotaciones = new List<CEN_cls_utilsQuote.DatoAnotacionesWrapper>();
    CEN_cls_utilsQuote.DatoAnotacionesWrapper anotacion = new CEN_cls_utilsQuote.DatoAnotacionesWrapper();
    List<String> codigosLotesRecotizables_result1 = new List<String>();
    List<String> codigosLotesRecotizables_result2 = new List<String>();
    CEN_cls_VisorLotes.LoteReceived loter = new CEN_cls_VisorLotes.LoteReceived();
    loter.Area = 99;
    loter.Codestadolote = 'Libre';
    loter.Codlote = '840001257';
    loter.Descripcionlote = 'LAS PALMERAS ETAPA 4 Mz.F Lt.06';
    loter.FillerStr02 = 'FRENTE CALLE';
    loter.Idproyecto = '10U1.231E';
    loter.Manzana = 'F4';
    loter.Precioventafun = 63558;
    loter.Precioventam2fun = 642;
    loter.isVisible = true;
    loter.isChecked = true;
    loter.PrecioVentaDscto = 60000;
    loter.Orden = 1;
    loter.Descripcioncorta = 'LPALMERASE4';
    lotesList.add(loter);
    lotesList.add(loter);
    List<Proyecto__c> proyectos = [
      SELECT Id, Zona__c FROM Proyecto__c WHERE CEN_CODIGOSAP__c = :loter.Idproyecto
    ];

    Test.startTest();
    CEN_cls_VisorLotes.data dataObj = new CEN_cls_VisorLotes.data();
    dataObj.codtasa = 'TASA1';
    dataObj.tasa = '26';
    dataObj.opcionDesembolso = 'OPCION A';
    dataObj.frecuenciaDesembolso = '1';
    dataObj.fechaDesembolso = '13/03/2024';
    codigosLotesRecotizables_result1 = CEN_cls_VisorLotes.getCodigosLotesRecotizables(oportunidades[0].Id);

    List<Tasa_variable__mdt> tasas = CEN_cls_VisorLotes.getTasasMdt(proyectos[0].Zona__c);
    respuesta = CEN_cls_VisorLotes.getcreateCotiz(
      datosPersona.datosPersona, //datosPersona
      lotesList, //lotesList
      anotaciones, //anotacionesList
      oportunidades[0].Id, //IdOportunidad
      100, //area
      200, //preciom2
      2000, //PrecioVenta
      20, //precioTotalDscto
      1000, //Iniporcentajevalue
      10, //Inicial
      10, //ncuotasinicial
      false, //bolMontoPrimeraCuota
      1000, //montocuota
      false, //isFacilote
      100000, //monotofinan
      60, //cuotasfinan
      10, //numCuotasSI
      '2022-06-14', //fecCuotaSaldoIni
      '2022-06-14', //fecCuotaSaldoFin
      23, //tasainteres
      10000,  //monotocuotafinan
      //10000,
      false, //esCotizacionLibre
      1000, //montoAdelanto
      true, //bolMontoAdelanto
      'PEN', //moneda
      'CD', //tipoVenta
      false, //simulador
      cotizacion[0].Id,//idCotizacionSimulador
      '[{"levers":[{"codigo":"PALANCA1","promocion":"PROMO0010","porcentaje":"15.3","importe":"15000.0","moneda":"PEN","descripcionPalanca":"TACTICO","aprobador":true}]},{"criteria":{"importeEspecial":0,"importeAdicional":0,"porcentajeEspecial":0,"porcentajeAdicional":0,"motivoInformativa":""}}]'  ,//jsonPalancas
      true,  //hasPermission
      dataObj, //TasaYDesembolso
      100 //montoCuotaRestanteFinanciamiento
    );

    CEN_cls_VisorLotes.generarPDF(respuesta.cotizacion.Id, oportunidades[0].Id);
    CEN_cls_VisorLotes.getTipoVenta();
    CEN_cls_VisorLotes.picklistValues();

    codigosLotesRecotizables_result2 = CEN_cls_VisorLotes.getCodigosLotesRecotizables(oportunidades[0].Id);

    Test.stopTest();
    //System.assertNotEquals(NULL, respuesta.cotizacion);
    //System.assertEquals(true, respuesta.ok);
    // validacion de lotes recotizables
    //System.assert(codigosLotesRecotizables_result1.isEmpty());
    //System.assert(!codigosLotesRecotizables_result2.isEmpty());
  }

  @isTest
  private static void e_imagen() {
    List<Account> cuentas = [
      SELECT
        Id,
        PersonContactId,
        CEN_Tipo_de_documento__pc,
        CEN_N_mero_de_documento__pc,
        FirstName,
        LastName,
        CEN_Direcci_n__c
      FROM Account
      ORDER BY FirstName ASC
    ];
    List<Lead> leads = [
      SELECT
        Id,
        FirstName,
        Company,
        CEN_RUC__c,
        CEN_N_mero_de_documento__c,
        LastName,
        Email,
        MobilePhone,
        CEN_Direcci_n_Prospecto__c
      FROM Lead
      ORDER BY FirstName ASC
    ];
    List<Tabla_maestra__c> distritos = [
      SELECT Id
      FROM Tabla_maestra__c
      ORDER BY Name ASC
    ];
    List<Event> eventos = [SELECT Id FROM Event ORDER BY Subject ASC];
    List<User> usuarios = [SELECT Id FROM User ORDER BY LastName ASC];

    List<Case> casos = [SELECT Id FROM Case];
    Test.startTest();
    LCH_ContactHighlightContainer chc = CEN_ImagenCuenta.getInfoFromCase(
      casos[0].Id
    );
    Test.stopTest();
  }
  @isTest
  private static void f_tipo_documentos_Cotizador(){
    CEN_cls_utilsQuote.ListatipoDocumentoWrapper tipoDocumentos = null;
    Test.startTest();
    tipoDocumentos = CEN_cls_VisorLotes.getListaTipoDocumentos();
    Test.stopTest();
    System.assertNotEquals(null, tipoDocumentos);
  }
  @isTest
  private static void g_error_cotizar_productosNoEncontrados(){
    CEN_cls_VisorLotes.CotizacionGeneradaWrapper respuesta = new CEN_cls_VisorLotes.CotizacionGeneradaWrapper();
    CEN_cls_VisorLotes.DatosPersonaWrapper datosPersona = new CEN_cls_VisorLotes.DatosPersonaWrapper();
    List<Opportunity> oportunidades = [SELECT Id FROM Opportunity];
    List<CEN_cls_VisorLotes.LoteReceived> lotesList = new List<CEN_cls_VisorLotes.LoteReceived>();
    List<CEN_cls_utilsQuote.DatoAnotacionesWrapper> anotaciones = new List<CEN_cls_utilsQuote.DatoAnotacionesWrapper>();
    CEN_cls_utilsQuote.DatoAnotacionesWrapper anotacion = new CEN_cls_utilsQuote.DatoAnotacionesWrapper();
    CEN_cls_VisorLotes.LoteReceived loter = new CEN_cls_VisorLotes.LoteReceived();
    loter.Area = 99;
    loter.Codestadolote = 'Entregado';
    loter.Codlote = '840001257';
    loter.Descripcionlote = 'LAS PALMERAS ETAPA 4 Mz.F Lt.06';
    loter.FillerStr02 = 'FRENTE CALLE';
    loter.Idproyecto = '10U1.231E';
    loter.Manzana = 'F4';
    loter.Precioventafun = 63558;
    loter.Precioventam2fun = 642;
    loter.isVisible = true;
    loter.isChecked = true;
    loter.PrecioVentaDscto = 60000;
    loter.Orden = 1;
    loter.Descripcioncorta = 'LPALMERASE4';
    lotesList.add(loter);
    loter.Codestadolote = 'Libre';
    loter.Descripcionlote = 'LAS PALMERAS ETAPA 4 Mz.F Lt.07';
    loter.Codlote = null;
    lotesList.add(loter);

    datosPersona = CEN_cls_VisorLotes.getDatosCliente(oportunidades[0].Id);

    anotacion.key = 1;
    anotacion.fecha = Date.today();
    anotacion.monto = 1000;
    anotacion.anotaciones = 'Prueba de anotaciones';
    anotaciones.add(anotacion);

    Test.startTest();
    CEN_cls_VisorLotes.data dataObj = new CEN_cls_VisorLotes.data();
    dataObj.codtasa = 'TASA1';
    dataObj.tasa = '26';
    dataObj.opcionDesembolso = 'OPCION A';
    dataObj.frecuenciaDesembolso = '1';
    dataObj.fechaDesembolso = '13/03/2024';
    respuesta = CEN_cls_VisorLotes.getcreateCotiz(
      datosPersona.datosPersona,
      lotesList,
      anotaciones,
      oportunidades[0].Id,
      100,
      200,
      2000,
      20,
      1000,
      10,
      10,
      false,
      1000,
      false,
      100000, //monotofinan
      60, //cuotasfinan
      10,
      '2022-06-14', //fecCuotaSaldoIni
      '2022-06-14', //fecCuotaSaldoFin
      23,
      10000,
      //10000,
      false,
      1000,
      true,
      'PEN',
      'CD',
      true,
      '',//idCotizacionSimulador
      '[{"levers":[{"codigo":"PALANCA1","promocion":"PROMO0010","porcentaje":"15.3","importe":"15000.0","moneda":"PEN","descripcionPalanca":"TACTICO","aprobador":true}]},{"criteria":{"importeEspecial":0,"importeAdicional":0,"porcentajeEspecial":0,"porcentajeAdicional":0,"motivoInformativa":""}}]'  ,//jsonPalancas
      true,  //hasPermission
      dataObj,
      100
    );
    Test.stopTest();
    //System.assertEquals(NULL, respuesta.cotizacion);
    //System.assertEquals(false, respuesta.ok);
  }
  @isTest
  private static void h_error_cotizar_sinListaPrecio(){
    CEN_cls_VisorLotes.CotizacionGeneradaWrapper respuesta = new CEN_cls_VisorLotes.CotizacionGeneradaWrapper();
    CEN_cls_VisorLotes.DatosPersonaWrapper datosPersona = new CEN_cls_VisorLotes.DatosPersonaWrapper();
    List<Opportunity> oportunidades = [SELECT Id FROM Opportunity];
    List<CEN_cls_VisorLotes.LoteReceived> lotesList = new List<CEN_cls_VisorLotes.LoteReceived>();
    List<CEN_cls_utilsQuote.DatoAnotacionesWrapper> anotaciones = new List<CEN_cls_utilsQuote.DatoAnotacionesWrapper>();
    CEN_cls_utilsQuote.DatoAnotacionesWrapper anotacion = new CEN_cls_utilsQuote.DatoAnotacionesWrapper();
    CEN_cls_VisorLotes.LoteReceived loter = new CEN_cls_VisorLotes.LoteReceived();
    List<PricebookEntry> listaPrecios = [SELECT Id FROM PricebookEntry];
    loter.Area = 99;
    loter.Codestadolote = 'Libre';
    loter.Codlote = '840001257';
    loter.Descripcionlote = 'LAS PALMERAS ETAPA 4 Mz.F Lt.06';
    loter.FillerStr02 = 'FRENTE CALLE';
    loter.Idproyecto = '10U1.231E';
    loter.Manzana = 'F4';
    loter.Precioventafun = 63558;
    loter.Precioventam2fun = 642;
    loter.isVisible = true;
    loter.isChecked = true;
    loter.PrecioVentaDscto = 60000;
    loter.Orden = 1;
    loter.Descripcioncorta = 'LPALMERASE4';
    lotesList.add(loter);

    Test.startTest();
    delete listaPrecios;

    CEN_cls_VisorLotes.data dataObj = new CEN_cls_VisorLotes.data();
    dataObj.codtasa = 'TASA1';
    dataObj.tasa = '26';
    dataObj.opcionDesembolso = 'OPCION A';
    dataObj.frecuenciaDesembolso = '1';
    dataObj.fechaDesembolso = '13/03/2024';
    respuesta = CEN_cls_VisorLotes.getcreateCotiz(
      datosPersona.datosPersona,
      lotesList,
      anotaciones,
      oportunidades[0].Id,
      100,
      200,
      2000,
      20,
      1000,
      10,
      10,
      false,
      1000,
      false,
      100000, //monotofinan
      60, //cuotasfinan
      10,
      '2022-06-14', //fecCuotaSaldoIni
      '2022-06-14', //fecCuotaSaldoFin
      23,
      //10000,
      10000,
      false,
      1000,
      true,
      'PEN',
      'CD',
      true,
      '',//idCotizacionSimulador
      '[{"levers":[{"codigo":"PALANCA1","promocion":"PROMO0010","porcentaje":"15.3","importe":"15000.0","moneda":"PEN","descripcionPalanca":"TACTICO","aprobador":true}]},{"criteria":{"importeEspecial":0,"importeAdicional":0,"porcentajeEspecial":0,"porcentajeAdicional":0,"motivoInformativa":""}}]'  ,//jsonPalancas
      true,  //hasPermission
      dataObj,
      100
    );
    Test.stopTest();
    System.assertEquals(NULL, respuesta.cotizacion);
    System.assertEquals(false, respuesta.ok);
  }

  @isTest
  private static void getCuotasFaciloteTest(){
      List<Cuota_Facilote_Permitida__mdt> cuotas = CEN_cls_VisorLotes.getCuotasFacilote();
      System.assertNotEquals(NULL, cuotas, 'La lista Cuota Facilote esta vacía.');
  }

  @isTest
  private static void generateAndUpdateOperationSafeTest(){
    List<Opportunity> oportunidades = [SELECT Id FROM Opportunity];
    Map<String, String> resp = CEN_cls_VisorLotes.generateAndUpdateOperationSafe(oportunidades[0].Id, false);
  }

  @isTest
  private static void checkPermissionTest(){

    List<User> usuarios = [SELECT Id FROM User ORDER BY LastName ASC];
    User u = [SELECT Id, Name FROM User WHERE LastName = 'A00001 last'];

    PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'CEN_DiscountSupervisorJefe'];
		insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.Id);

    system.runAs(u){
      test.startTest();
      Boolean resp = CEN_cls_VisorLotes.checkPermission('CEN_DiscountSupervisorJefe');
      test.stopTest();
    }
  }
}