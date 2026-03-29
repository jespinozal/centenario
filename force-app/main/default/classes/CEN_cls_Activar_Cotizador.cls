/*
 * Name: CEN_cls_Activar_Cotizador
 * Version: 2.0
 * Descripción: clase controladora del componente CEN_Activar_Cotizador
 * Fecha: 27/12/2020
 * TestClass: Test_Controller
 */
public with sharing class CEN_cls_Activar_Cotizador {
  private static final Map<String,String> mapEstadoTransformer = new Map<String,String>{
    'E' => 'Entregado', 
    'B' => 'Borrado',
    'L' => 'Libre',
    'Q' => 'Bloqueado',
    'C' => 'Vendido',
    'R' => 'Reservado'
  };
  
  /**
   * clase para validar si la oportunidad tiene algun lote ingresado desde el visor mapa y activar el cotizador
   * @param  opportunityId: id de la oportunidad
   * @return               return lista de lotes respondidas de las api del visor
   */
  @AuraEnabled
  public static Response validarOportunidad(String opportunityId){
    Response objResponse = new Response();
    CEN_ResponseContentVisorLotes objLoteVisor = null;
    Opportunity oportunidad = null;
    List<Product2> lotes = new List<Product2>();
    Set<Id> idsProducto = new Set<Id>();
    List<OpportunityLineItem> lotes_de_oportunidad = new List<OpportunityLineItem>();
    List<Proyecto__c> proyectos = new List<Proyecto__c>();
    
    oportunidad = [SELECT Id, CEN_con_lote_desde_visor__c, OwnerId, StageName FROM Opportunity WHERE Id=:opportunityId LIMIT 1];    
    if(
        oportunidad!=null && 
        oportunidad.CEN_con_lote_desde_visor__c==true && 
        oportunidad.StageName=='Cotización' &&
        oportunidad.OwnerId == System.UserInfo.getUserId()
    ){
      lotes_de_oportunidad = [
          SELECT Id, OpportunityId, CEN_Estado_del_lote__c, Product2Id, ProductCode, CreatedDate, IsDeleted 
          FROM OpportunityLineItem 
          WHERE OpportunityId=:opportunityId 
          ORDER BY CreatedDate DESC
      ];
      //  si hay lotes de oportunidad
      if(lotes_de_oportunidad!=null && !lotes_de_oportunidad.isEmpty()){
        for(OpportunityLineItem loteOport : lotes_de_oportunidad){
            idsProducto.add(loteOport.Product2Id);
        }
        lotes = [
            SELECT Id, CODLOTE__c, MANZANA__c, ProductCode, CEN_Proyecto__c, 
            CEN_Proyecto__r.Id,
            CEN_Proyecto__r.CEN_CODIGOSAP__c,
            CEN_Proyecto__r.Name 
            FROM Product2 
            WHERE Id IN :idsProducto
        ];
        if(lotes !=null){
          proyectos = getProyectos(lotes);
          //  si solo se trata del mismo proyecto
          if(proyectos!=null && !proyectos.isEmpty() && proyectos.size()==1){
            objResponse.idProyectoSF = proyectos[0].Id;
            objResponse.objProyectoSF = proyectos[0];
            
            //  por cada lote encontrado extraer data desde el ws de visor de lotes
            for(Product2 lote : lotes){
              if(String.isNotBlank(lote.CODLOTE__c) && lote.CEN_Proyecto__c!=null && String.isNotBlank(lote.CEN_Proyecto__r.CEN_CODIGOSAP__c)){
                  objLoteVisor = CEN_ConsultVisorLotes.ByProyectCodloteManzana(lote.CODLOTE__c, lote.CEN_Proyecto__r.CEN_CODIGOSAP__c, '');
                  objLoteVisor.Codestadolote = mapEstadoTransformer.get(objLoteVisor.Codestadolote);
                  if (
                      String.isNotBlank(objLoteVisor.Descripcionlote) &&
                      String.isNotBlank(objLoteVisor.Descripcionlote) &&
                      objLoteVisor.Descripcionlote.toUpperCase().indexOf('LT.') > -1
                  ) {
                      objLoteVisor.Descripcioncorta = objLoteVisor.Descripcionlote.substring(
                          objLoteVisor.Descripcionlote.toUpperCase().indexOf('LT.')
                      )
                      .trim();
                  } else {
                      objLoteVisor.Descripcioncorta = objLoteVisor.Descripcionlote;
                  }
                  objResponse.lotes.add(objLoteVisor);
                  objLoteVisor = null;
              }
            }
            objResponse.ok = true;
          }else{
            objResponse.ok = false;
            objResponse.mensaje = 'Los lotes de la oportunidad tienen diferentes proyectos.';
            objResponse.detalle = objResponse.mensaje;
          }
        }
      }
    }
    return objResponse;
  }
  /**
   * identifica los proyectos de los lotes para validar que sean del mismo proyecto
   * @param  lotes lista de lotes
   * @return       return set de proyectos
   */
  private static List<Proyecto__c> getProyectos(List<Product2> lotes){
    List<Proyecto__c> listProyectos= new List<Proyecto__c>();
    Set<Proyecto__c> setProyectos = new Set<Proyecto__c>();
    for(Product2 lote : lotes){
      setProyectos.add(lote.CEN_Proyecto__r);
    }
    listProyectos.addAll(setProyectos);
    setProyectos.clear();
    return listProyectos;
  }

  public class Response extends ResponseWrapper{
    @AuraEnabled public List<CEN_ResponseContentVisorLotes> lotes;
    @AuraEnabled public Proyecto__c objProyectoSF;
    @AuraEnabled public Id idProyectoSF;
    public Response(){
      lotes = new List<CEN_ResponseContentVisorLotes>();      
    }
  }
}