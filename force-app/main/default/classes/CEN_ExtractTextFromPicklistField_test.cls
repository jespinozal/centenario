/**
 * @description       : Clase test de CEN_ExtractTextFromPicklistField.
 * @author            : @nttdata.com
 * @group             :
 * @last modified on  : 30-12-2021
 * @last modified by  : @nttdata
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   30-12-2021   @nttdata     Initial Version
**/
@isTest
public class CEN_ExtractTextFromPicklistField_test {
    @TestSetup
	static void SetUp(){        
        Lead ld = new Lead();
        ld.FirstName =  'Test';
        ld.LastName =  'prueba';
        ld.Email =  'test@mail.com';
        ld.CEN_Tipo_de_documento__c =  'DNI';
        ld.CEN_N_mero_de_documento__c =  '478965419';
        ld.MobilePhone =  '9999999';
        ld.CEN_Divisi_n_de_inter_s__c =  'Lotes de vivienda ';
        ld.CEN_Tema_de_inter_s__c =  'Quiero comprar un lote ';
        ld.CEN_Donde_comprar__c =  'PROV_Piura_LU';
        ld.CEN_Elige_donde_vivir__c =  'Piura - Urbanización Las Palmeras';
        ld.CEN_T_rminos_y_condiciones__c = true;
        ld.LeadSource =  'Digital';
        ld.CEN_Web__c =  'Terreno';
        ld.CEN_Medio__c =  'Internet - Página Web Campaña';
        ld.CEN_Formulario__c =  'Proyecto ';
        ld.CEN_utm_source__c =  'testsource1';
        ld.CEN_utm_medium__c =  'testmedium1';
        ld.CEN_utm_term__c =  'testterm1';
        ld.CEN_utm_content__c =  'testcontent1';
        ld.CEN_utm_campaign__c =  'testcampaign1';            
        ld.CEN_ClientID__c = 'GA1.4.47264897.1638980031v1';
        insert ld;
    }
	@IsTest static void Sucess_test(){    
        Test.startTest();  
        List<CEN_ExtractTextFromPicklistField.Requests> Requests = new List<CEN_ExtractTextFromPicklistField.Requests>();
        CEN_ExtractTextFromPicklistField.Requests Obj = new CEN_ExtractTextFromPicklistField.Requests();
        id ld = [Select id from lead LIMIT 1].id;
        Obj.recordId=ld;
        Requests.add(Obj);       
        CEN_ExtractTextFromPicklistField.extract(Requests);
        Test.stopTest();
    }
}