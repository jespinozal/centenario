public class CEN_ModalCotizadorLibre_ctr {
  @AuraEnabled
  public static Boolean validateStageOpp(String IdOportunidad) {
      Opportunity opp = [Select id, stagename from Opportunity where id =: IdOportunidad];
      Boolean resp = false;
      if(opp.stagename == 'Cotización'){
          resp = true;
      }
      return resp;
  }

  @AuraEnabled
  public static String getMonedaActual(String IdOportunidad){
      String tipoMoneda = [SELECT CEN_Moneda__c FROM Opportunity WHERE id =:IdOportunidad].CEN_Moneda__c;
      return tipoMoneda;
  }

  @AuraEnabled
  public static Opportunity getOppData(String IdOportunidad){
      Opportunity oppData = [SELECT CEN_Proforma__c, CEN_Tipo_de_venta__c FROM Opportunity WHERE id =:IdOportunidad];
      return oppData;
  }
}