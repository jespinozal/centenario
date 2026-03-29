public with sharing class CEN_AccountCroquis_cls {

    public Account Cuenta;
    public Id recordId;
    public String MapaReferencia;

    public String getTipoCuenta (){ 
        Account cuenta = [SELECT RecordType.DeveloperName FROM ACCOUNT WHERE id = :recordId];
        return cuenta.RecordType.DeveloperName;
    }

    public String getMapaReferencia (){ 
        system.debug('llamada api google maps static');
        Cuenta = [SELECT id,name,BillingStreet,BillingCity,BillingState,BillingCountry,CEN_Longitude__c,CEN_Latitude__c FROM ACCOUNT WHERE id = :recordId];

        String marker = 'markers=size:mid%7Ccolor:red%7C';
        String googleMap = 'https://maps.googleapis.com/maps/api/staticmap?';
        String zoom = '16';
        String size = '600x400';
        String key = Label.CEN_url_api_google_maps_static;
        String latitud = String.valueOf(cuenta.CEN_Latitude__c);
        String longitud = String.valueOf(cuenta.CEN_Longitude__c);
        String urlMapaReferencia = googleMap+'center='+latitud+','+longitud+'&zoom='+zoom+'&size='+size+'&'+marker+latitud+','+longitud+'&key='+key;
        
     return urlMapaReferencia;
    }
    public CEN_AccountCroquis_cls(ApexPages.StandardController controller) {
        system.debug('constructor croquis');
        recordId =  controller.getRecord().id;
        try {
            Cuenta = [SELECT id,name,CEN_Longitude__c,CEN_Latitude__c FROM ACCOUNT WHERE id = :recordId];
        } catch (Exception e) {
            System.debug(e.getMessage());
            System.debug(
                LoggingLevel.ERROR,
                'No se pudo consultar la cuenta: ' +
                e.getMessage() +
                '. Type: ' +
                e.getTypeName() +
                '. Line: ' +
                e.getLineNumber()
            );
        }
        

    }

}