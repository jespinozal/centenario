/**
 * @description       : 
 * @author            : augusto.nayib.tamayo.bedregal@everis.nttdata.com
 * @group             : 
 * @last modified on  : 06-13-2021
 * @last modified by  : @everis.com
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   06-13-2021   @everis.com   Initial Version
**/
@isTest
public class CEN_MoneyRefundRequestPDF_tst {
    @isTest static void CEN_MoneyRefundRequestPDFController(){
        //MIO
        Tabla_maestra__c distrito = new Tabla_maestra__c();
        distrito.Name='Lima';
        distrito.Departamento__c='Lima';
        distrito.Provincia__c='Lima';
        distrito.CEN_Codigo_departamento__c='15';
        distrito.CEN_Codigo_provincia__c='1501';
        distrito.CEN_Codigo_distrito__c='150105';        
        insert distrito;

        Account cuenta = new Account();
        cuenta.CEN_Numero_de_documento_del__c ='10100010002';
        cuenta.Name='Maximule SAC';
        cuenta.Phone='6543245';
        cuenta.CEN_Direcci_n__c='av siempre viva';
        cuenta.CEN_Estado__c='Cuenta Potencial';
        cuenta.RecordTypeId ='0124T0000000qqbQAA';
        //cuenta.CEN_N_mero_de_documento__pc ='10100010002';
        cuenta.CEN_fld_Correo_empresa__c = 'prueba@gmail.com';
        //cuenta.PersonMobilePhone='6543245';
        cuenta.CEN_Tipo_de_documento__c = 'RUC';        
        cuenta.CEN_Distrito__c =distrito.Id;
        //cuenta.CEN_Direccion__pc ='av siempre viva';
        insert cuenta;

        Opportunity oportunidad=new Opportunity();
        oportunidad.AccountId=cuenta.Id;
        oportunidad.StageName='Operación';
        oportunidad.CEN_Sub_Estado__c='Segura';
        oportunidad.Name='Opo 1';
        oportunidad.CloseDate=Date.today();
        oportunidad.CEN_Tipo_de_venta__c = 'CS';
        oportunidad.CEN_AmountPaidDate__c = 2000;
        oportunidad.CEN_devolucion_saldo_Afavor__c = false;
        

        //objPersona = CEN_cls_VisorLotes.getDatosCliente(oportunidad.Id);

        Proyecto__c proyecto= new Proyecto__c();
        proyecto.Name='Proyecto 1';
        proyecto.CEN_CODIGOSAP__c='10U1.011E';
        proyecto.CEN_Etapa__c='Etapa 1';
        insert proyecto;
        oportunidad.CEN_Proyecto__c = proyecto.id;
        insert oportunidad;
        
        Product2 lote = new Product2();
        lote.Name='Lote prueba1';
        lote.CEN_Proyecto__c=proyecto.Id;
        lote.CODLOTE__c='123123123';
        lote.CODCOMPANIA__c='0010';
        lote.CEN_Tiene_Reserva__c='No';
        lote.CODESTADOLOTE__c='L';
        lote.CEN_PRECIOVENTAFUN__c='10000';
        lote.IsActive=true;
        lote.MANZANA__c = 'Mz. A1';
        lote.AREA__c = '100';
        lote.CEN_TIPOLOGIA__c= 'ESQUINA';
        insert lote;
        
        List<OpportunityLineItem> oppLitem = new List<OpportunityLineItem>();
        OpportunityLineItem oppLt = new OpportunityLineItem();
        oppLt.Product2Id = lote.id;
        oppLt.OpportunityId = oportunidad.id;
        oppLitem.add(oppLt);
        

        PricebookEntry precio2= new PricebookEntry();
        precio2.UseStandardPrice=false;
        precio2.IsActive=true;
        precio2.Pricebook2Id=Test.getStandardPricebookId();
        precio2.Product2Id=lote.Id;
        precio2.UnitPrice=Decimal.valueOf(lote.CEN_PRECIOVENTAFUN__c);
        insert precio2;
        
        Proyecto__c proyecto2 = CEN_cls_VisorLote_2.buscarProyectobyId(proyecto.Id);
        System.assertEquals(proyecto.id, proyecto2.Id);
        Id[]searchResultsIds=new Id[]{proyecto.Id};
        Test.setFixedSearchResults(searchResultsIds);
        Test.startTest();
        Proyecto__c proyecto3 = CEN_cls_VisorLote_2.getProyectoDeOportunidad(oportunidad.Id);
        List<Proyecto__c> proyectos_encontrados = CEN_cls_VisorLote_2.buscarProyecto(proyecto.Name);
        
        
        System.assertEquals(1, proyectos_encontrados.size());
        System.assertEquals(proyecto.id, proyectos_encontrados[0].Id);
        //System.assertNotEquals(null, objPersona);
        //DATA
        PageReference pageref = Page.CEN_MoneyRefundRequestPDF_vf;
        pageref.getParameters().put('id',oportunidad.Id);
        Test.setCurrentPage(pageref);        
        ApexPages.StandardController scontr = new ApexPages.StandardController(oportunidad);
        //  Controlador de visualforce
        CEN_MoneyRefundRequestPDF_ctr controller = new CEN_MoneyRefundRequestPDF_ctr(scontr);
        String telefono = controller.getTelefono();
        String documento = controller.getDocumento();
        String tipoDocumento = controller.getTipoDocumento();
        String correo = controller.getCorreo();
        String loteConcat = controller.getLoteConcat();
        String domicilio = controller.getDomicilio();
        String societyName = controller.getSocietyName();
        List<CEN_SocietySAP__mdt>lstSociety = controller.getLstSociety();
        String writeToday = controller.getWriteToday();
        String writeTodayB = controller.getWriteTodayB();
        Proyecto__c proyectop = controller.getProyecto();
        Opportunity oportunidads = controller.getOportunidad();
        Account cuentad = controller.getCuenta();
        Tabla_maestra__c tablaMas = controller.getTablaMas();
        List<OpportunityLineItem> lotes = controller.getLotes();
        CEN_AnulationOperationSafe_ctr.generarPDF(oportunidad.id);
        Test.stopTest();
    }
}