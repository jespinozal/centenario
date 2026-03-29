public with sharing class CEN_pdfDeclaracionJuradaDomiciliaria {
    public String recordId;
    public Account Cuenta;
    public CEN_pdfDeclaracionJuradaDomiciliaria(ApexPages.StandardController controller) {
        recordId =  controller.getRecord().id;
        try {
            Cuenta = [SELECT id,Name,LastName,FirstName,CEN_Tipo_de_documento__pc,CEN_N_mero_de_documento__pc,CEN_Sexo__pc,CEN_Nacionalidad__pc,CEN_Distrito__pr.Name,
                    CEN_Distrito__pr.Provincia__c,CEN_Distrito__pr.Departamento__c,CEN_Tipo_Via__c,CEN_Direccion__pc,CEN_Referencia_direccion__c,CEN_Situacion_vivienda__c,PersonEmail,
                    CEN_Tiempo_de_Residencia__c,CEN_Estado_civil__pc,CEN_Tel_fono_Trabajo__pc,PersonMobilePhone FROM ACCOUNT WHERE id = :recordId];
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