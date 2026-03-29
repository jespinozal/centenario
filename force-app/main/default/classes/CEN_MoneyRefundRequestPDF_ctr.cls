/**
 * @description       : Clase controladora para generación de PDFs para devoluciones.
 * @author            : augusto.nayib.tamayo.bedregal@everis.nttdata.com
 * @group             : 
 * @last modified on  : 06-28-2021
 * @last modified by  : @everis.com
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   04-17-2021   @everis.com   Initial Version
**/

public class CEN_MoneyRefundRequestPDF_ctr {

    public Opportunity oportunidad;    
    public String writeToday;
    public String writeTodayB;
    public Proyecto__c proyecto;
    public List<CEN_SocietySAP__mdt> lstSociety;
    public String societyName;
    public Account cuenta;
    public Tabla_maestra__c tablaMas;
    public String domicilio;
    public List<OpportunityLineItem> lotes;
    public String tipoDocumento;
    public String documento;
    public String telefono;
    public String correo;
    public String loteConcat = '';

  public CEN_MoneyRefundRequestPDF_ctr(ApexPages.StandardController controller) {
    //	Get recordId
    Id recordId = controller.getRecord().Id;
    System.debug(LoggingLevel.INFO, recordId);
    //Fecha de HOY
    DateTime dt = Datetime.now();
    Integer day = dt.day();
    Integer year =dt.year();
    writeToday = String.valueOf(day)+' de ';
    writeTodayB = ' de '+String.valueOf(year);

    oportunidad = [
      SELECT
      Id,
      CEN_Tipo_de_venta__c,
      CEN_Monto_Cuota_del_Saldo_de_precio__c,
      CEN_MaximumPaymentDate__c,
      CreatedDate,
      CloseDate,
      CEN_AmountPaidDate__c,
      AccountId,
      CEN_Proyecto__c
      FROM Opportunity
      WHERE Id = :recordId
    ];
    System.debug(LoggingLevel.INFO, oportunidad);
    proyecto = [
      SELECT Id,Name,CEN_MaximumPaymentDuePeriod__c,CEN_MaximumTermForSigningTheContract__c,CEN_Sociedad__c
      FROM Proyecto__c
      WHERE Id = :oportunidad.CEN_Proyecto__c
      LIMIT 1
    ];
    System.debug(LoggingLevel.INFO, proyecto);
    cuenta = [
        SELECT
        Name,
        CEN_Tipo_de_documento__c,
        CEN_Tipo_de_documento__pc,
        CEN_Numero_de_documento_del__c,
        CEN_N_mero_de_documento__pc,
        CEN_Direccion__pc,
        CEN_Direcci_n__c,
        PersonMobilePhone,
        PersonEmail,
        CEN_fld_Correo_empresa__c,
        CEN_Distrito__c,
        CEN_Distrito__pc,
        Phone,
        RecordType.DeveloperName
        FROM Account
        WHERE Id = :oportunidad.AccountId
    ];
    System.debug(LoggingLevel.INFO, cuenta);
    lstSociety = [
            SELECT 
            DeveloperName, 
            Label 
            FROM CEN_SocietySAP__mdt
    ];
    System.debug(LoggingLevel.INFO, lstSociety);

    lotes = [
      SELECT
        Id,
        Product2.Name,
        Product2.CEN_Proyecto__c        
      FROM OpportunityLineItem
      WHERE OpportunityId = :oportunidad.Id
    ];

    System.debug(LoggingLevel.INFO, lotes);

    tablaMas = cuenta.RecordType.DeveloperName == 'PersonAccount' ? [SELECT Departamento__c,Provincia__c,name FROM Tabla_maestra__c WHERE Id =: cuenta.CEN_Distrito__pc] : [SELECT Departamento__c,Provincia__c,name FROM Tabla_maestra__c WHERE Id =: cuenta.CEN_Distrito__c];

    //GetSocietyName
    for(CEN_SocietySAP__mdt s: lstSociety){
        if(s.Label == proyecto.CEN_Sociedad__c){
            societyName = s.DeveloperName.replace('_',' ');
        }
    }

    domicilio = cuenta.RecordType.DeveloperName == 'PersonAccount' ? cuenta.CEN_Direccion__pc + ', ' + tablaMas.Departamento__c + ', ' + tablaMas.Provincia__c + ', ' + tablaMas.name : cuenta.CEN_Direcci_n__c + ', ' + tablaMas.Departamento__c + ', ' + tablaMas.Provincia__c + ', ' + tablaMas.name;
    documento = cuenta.RecordType.DeveloperName == 'PersonAccount' ? cuenta.CEN_N_mero_de_documento__pc : cuenta.CEN_Numero_de_documento_del__c;
    telefono = cuenta.RecordType.DeveloperName == 'PersonAccount' ? cuenta.PersonMobilePhone : cuenta.Phone;
    correo = cuenta.RecordType.DeveloperName == 'PersonAccount' ? cuenta.PersonEmail : cuenta.CEN_fld_Correo_empresa__c;
    tipoDocumento = cuenta.RecordType.DeveloperName == 'PersonAccount' ? cuenta.CEN_Tipo_de_documento__pc : cuenta.CEN_Tipo_de_documento__c;
    Integer i = 0;
    for(OpportunityLineItem oppLt : lotes){
      if(i == 0){
        loteConcat = oppLt.Product2.Name;
        i=1;
      }else{
        loteConcat = loteConcat + ', ' + oppLt.Product2.Name;
      }        
    }
  }

  public String getTelefono(){
    System.debug(LoggingLevel.INFO, telefono);
    return this.telefono;
  }

  public String getDocumento(){
    System.debug(LoggingLevel.INFO, documento);
    return this.documento;
  }

  public String getTipoDocumento(){
    System.debug(LoggingLevel.INFO, tipoDocumento);
    return this.tipoDocumento;
  }

  public String getCorreo(){
    System.debug(LoggingLevel.INFO, correo);
    return this.correo;
  }

  public String getLoteConcat(){
    System.debug(LoggingLevel.INFO, LoteConcat);
    return this.LoteConcat;
  }

  public String getDomicilio(){
    System.debug(LoggingLevel.INFO, domicilio);
    return this.domicilio;
  }

  public String getSocietyName(){
    System.debug(LoggingLevel.INFO, societyName);
    return this.societyName;
  }

  public List<CEN_SocietySAP__mdt> getLstSociety(){
    System.debug(LoggingLevel.INFO, lstSociety);
    return this.lstSociety;
  }

  public String getWriteToday(){
    System.debug(LoggingLevel.INFO, writeToday);
    return this.writeToday;
  }

  public String getWriteTodayB(){
    System.debug(LoggingLevel.INFO, writeTodayB);
    return this.writeTodayB;
  }

  public Proyecto__c getProyecto() {
    System.debug(LoggingLevel.INFO, proyecto);
    return this.proyecto;
  }

  public Opportunity getOportunidad() {
    System.debug(LoggingLevel.INFO, oportunidad);
    return this.oportunidad;
  }

  public Account getCuenta() {
    System.debug(LoggingLevel.INFO, cuenta);
    return this.cuenta;
  }

  public Tabla_maestra__c getTablaMas() {
    System.debug(LoggingLevel.INFO, tablaMas);
    return this.tablaMas;
  }

  public List<OpportunityLineItem> getLotes(){
    System.debug(LoggingLevel.INFO, lotes);
    return this.lotes;
  }
}