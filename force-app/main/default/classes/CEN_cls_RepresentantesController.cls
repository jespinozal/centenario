public class CEN_cls_RepresentantesController {
	
    private final Account q;
    
    public ApexPages.StandardController Representantes0Controller {get; set;}
	public Firma_de_Representantes_Legales__mdt representantes0 {get; set;}
	
	public ApexPages.StandardController Representantes1Controller {get; set;}
	public Firma_de_Representantes_Legales__mdt representantes1 {get; set;}
	
	public ApexPages.StandardController ContactoController {get; set;}
	public Contact contacto {get; set;}
	
    public CEN_cls_RepresentantesController(ApexPages.StandardController stdController) {
        system.debug('Entro');
        this.q = (Account)stdController.getRecord();
        
        representantes0 = [SELECT MasterLabel, Nombres_Completos__c, Imagen_de_Firma__c, Activo__c From Firma_de_Representantes_Legales__mdt where Activo__c = true][0];
        Representantes0Controller = new ApexPages.StandardController(representantes0);
		
		representantes1 = [SELECT MasterLabel, Nombres_Completos__c, Imagen_de_Firma__c, Activo__c From Firma_de_Representantes_Legales__mdt where Activo__c = true][1];
        Representantes1Controller = new ApexPages.StandardController(representantes1);
		
        try {
            contacto = [SELECT name From contact where AccountId =: q.Id order by CreatedDate asc limit 1];
        }
        catch (Exception ex) {
            System.debug(
            'Exception: ' +
            ex.getMessage() +
            '. Line: ' +
            ex.getLineNumber() +
            '. Type: ' +
            ex.getTypeName()
            ); 
            contacto = new Contact(); 
        }
        ContactoController = new ApexPages.StandardController(contacto);
    }
}