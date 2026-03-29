/**
 * @description       : 
 * @author            : @everis.com
 * @group             : 
 * @last modified on  : 07-20-2021
 * @last modified by  : @everis.com
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   07-20-2021   @everis.com   Initial Version
**/
@isTest
public with sharing class CEN_LotSAPSevice_tst {
    @TestSetup
    static void SetUp(){
          Proyecto__c  pj = new Proyecto__c();
		pj.CEN_CODIGOSAP__c = '10U1.061E';  
        insert pj; 
    }
    static testMethod void CEN_LotSAPSevice_doPost() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
     	Test.startTest();
            req.requestURI = URL.getSalesforceBaseUrl().toExternalForm()+'/sap/lot/';  
            req.httpMethod = 'POST';
            Blob strJson = Blob.valueOf('[{"tipoProyect":"Urbano","idProyectoSap":"10U1.061E","lots":[{"zonificacion":null,"usoInmueble":"DP","urbanizacion":null,"tipoLote":"V","tipologia":null,"tipoInmueble":"LO","tieneReserva":false,"sector":null,"productSKU":null,"productCode":"10U1.061E","precioVenta":"232450.92","numeroKardex":null,"numeroFichaRegistral":null,"name":"SANTA MARIA RDA 10A Mz.A Lt.01","medidaIzquierda":"15.86","medidaFrente":"6.30","medidaFondo":"6.30","medidaDerecha":"15.86","manzana":"A","linderoIzquierda":"LOTE 2","linderoFrente":"AV. PUENTE PIEDRA","linderoFondo":"HU SANTA MARIA ETAPA 10C","linderoDerecha":"CALLE S/N 8","isActive":true,"idLotSap":"000001","fechaVenta":null,"fechaIngresoNotaria":null,"fechaIngreso":null,"etapaLote":null,"eliminado":false,"description":null,"descripcionLote":"SANTA MARIA RDA 10A Mz.A Lt.01","descripcionCorta":"SM10A-A001","costoVenta":null,"costoTerreno":null,"costoMayorValor":null,"costoAbitacionUrba":null,"codSituacionLote":null,"codMonedaFuncional":"PEN","codLoteSap":"840032974","codEstadoLote":"Q","codEstadoEntrega":null,"codCompania":"0010","codCliente":null,"areaLote":"95.18"}]}]');
            req.requestBody = strJson;
            RestContext.request = req;
            RestContext.response= res;
            String results = CEN_LotSAPSevice_cls.doPost();
        Test.stopTest();
    }
    
    static testMethod void CEN_LotSAPSevice_doPostError() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
     	Test.startTest();
            req.requestURI = URL.getSalesforceBaseUrl().toExternalForm()+'/sap/lot/';  
            req.httpMethod = 'POST';
            Blob strJson = Blob.valueOf('{"tipoProyect":"Urbano","idProyectoSap":"10U1.061E","lots":[{"zonificacion":null,"usoInmueble":"DP","urbanizacion":null,"tipoLote":"V","tipologia":null,"tipoInmueble":"LO","tieneReserva":false,"sector":null,"productSKU":null,"productCode":"10U1.061E","precioVenta":"232450.92","numeroKardex":null,"numeroFichaRegistral":null,"name":"SANTA MARIA RDA 10A Mz.A Lt.01","medidaIzquierda":"15.86","medidaFrente":"6.30","medidaFondo":"6.30","medidaDerecha":"15.86","manzana":"A","linderoIzquierda":"LOTE 2","linderoFrente":"AV. PUENTE PIEDRA","linderoFondo":"HU SANTA MARIA ETAPA 10C","linderoDerecha":"CALLE S/N 8","isActive":true,"idLotSap":"000001","fechaVenta":null,"fechaIngresoNotaria":null,"fechaIngreso":null,"etapaLote":null,"eliminado":false,"description":null,"descripcionLote":"SANTA MARIA RDA 10A Mz.A Lt.01","descripcionCorta":"SM10A-A001","costoVenta":null,"costoTerreno":null,"costoMayorValor":null,"costoAbitacionUrba":null,"codSituacionLote":null,"codMonedaFuncional":"PEN","codLoteSap":"840032974","codEstadoLote":"Q","codEstadoEntrega":null,"codCompania":"0010","codCliente":null,"areaLote":"95.18"}]]');
            req.requestBody = strJson;
            RestContext.request = req;
            RestContext.response= res;
            String results = CEN_LotSAPSevice_cls.doPost();
        Test.stopTest();
    }
    
    static testMethod void CEN_LotSAPSevice_doPostErrorData() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
     	Test.startTest();
            req.requestURI = URL.getSalesforceBaseUrl().toExternalForm()+'/sap/lot/';  
            req.httpMethod = 'POST';
            Blob strJson = Blob.valueOf('[{"tipoProyect":"Urbano","idProyectoSap":"10U1.061E","lots":[{"zonificacion":null,"usoInmueble":"DP","urbanizacion":null,"tipoLote":"V","tipologia":null,"tipoInmueble":"LO","tieneReserva":false,"sector":null,"productSKU":null,"productCode":"10U1.061E","precioVenta":"232450.92","numeroKardex":null,"numeroFichaRegistral":null,"name":"SANTA MARIA RDA 10A Mz.A Lt.01","medidaIzquierda":"15.86","medidaFrente":"6.30","medidaFondo":"6.30","medidaDerecha":"15.86","manzana":"A","linderoIzquierda":"LOTE 2","linderoFrente":"AV. PUENTE PIEDRA","linderoFondo":"HU SANTA MARIA ETAPA 10C","linderoDerecha":"CALLE S/N 8","isActive":true,"idLotSap":null,"fechaVenta":null,"fechaIngresoNotaria":null,"fechaIngreso":null,"etapaLote":null,"eliminado":false,"description":null,"descripcionLote":"SANTA MARIA RDA 10A Mz.A Lt.01","descripcionCorta":"SM10A-A001","costoVenta":null,"costoTerreno":null,"costoMayorValor":null,"costoAbitacionUrba":null,"codSituacionLote":null,"codMonedaFuncional":"PEN","codLoteSap":"840032974","codEstadoLote":"Q","codEstadoEntrega":null,"codCompania":"0010","codCliente":null,"areaLote":"95.18"}]}]');
            req.requestBody = strJson;
            RestContext.request = req;
            RestContext.response= res;
            String results = CEN_LotSAPSevice_cls.doPost();
        Test.stopTest();
    }
    
    static testMethod void CEN_LotSAPSevice_doPut() {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
     	Test.startTest();
            req.requestURI = URL.getSalesforceBaseUrl().toExternalForm()+'/sap/lot/';  
            req.httpMethod = 'POST';
            Blob strJson = Blob.valueOf('[{"tipoProyect":"Urbano","idProyectoSap":"10U1.061E","lots":[{"zonificacion":null,"usoInmueble":"DP","urbanizacion":null,"tipoLote":"V","tipologia":null,"tipoInmueble":"LO","tieneReserva":false,"sector":null,"productSKU":null,"productCode":"10U1.061E","precioVenta":"232450.92","numeroKardex":null,"numeroFichaRegistral":null,"name":"SANTA MARIA RDA 10A Mz.A Lt.01","medidaIzquierda":"15.86","medidaFrente":"6.30","medidaFondo":"6.30","medidaDerecha":"15.86","manzana":"A","linderoIzquierda":"LOTE 2","linderoFrente":"AV. PUENTE PIEDRA","linderoFondo":"HU SANTA MARIA ETAPA 10C","linderoDerecha":"CALLE S/N 8","isActive":true,"idLotSap":"000001","fechaVenta":null,"fechaIngresoNotaria":null,"fechaIngreso":null,"etapaLote":null,"eliminado":false,"description":null,"descripcionLote":"SANTA MARIA RDA 10A Mz.A Lt.01","descripcionCorta":"SM10A-A001","costoVenta":null,"costoTerreno":null,"costoMayorValor":null,"costoAbitacionUrba":null,"codSituacionLote":null,"codMonedaFuncional":"PEN","codLoteSap":"840032974","codEstadoLote":"Q","codEstadoEntrega":null,"codCompania":"0010","codCliente":null,"areaLote":"95.18"}]}]');
            req.requestBody = strJson;
            RestContext.request = req;
            RestContext.response= res;
            String results = CEN_LotSAPSevice_cls.doPut();
        Test.stopTest();
    }
    
    
}