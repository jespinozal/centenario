/**
 * @description       : clase test para CEN_Lead_trg_Helper.class
 * @author            : Adolfo Crispin
 * @group             :
 * @last modified on  : 10-17-2024
 * @last modified by  : Richard Villafana - NTT DATA
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   29-01-2021   Adolfo Crispin   Initial Version
**/
@isTest
public with sharing class CEN_Lead_trg_Helper_test {
    private static List<String> eleccionesDondeVivir = new List<String>{'Carabayllo - Urbanización Santa María','Carabayllo - Urbanización La Planicie','Urbanización Esmeralda'};
    /**
    * @description: inicializa la data para todos los test
    * @author Adolfo Crispin | 29-01-2021
    **/
    @TestSetup
    static void setup(){
        List<User> supervisores = getSupervisores();
        insert supervisores;

        User usuarioTester = [SELECT Id FROM User WHERE Id=:System.UserInfo.getUserId()];
        System.runAs(usuarioTester){
            List<Lead> prospectos = getProspectos();
            insert prospectos;

            //Insertar Lead Reactivos
            List<Lead> oldLead = [SELECT Id FROM Lead];
            for(Lead ld : oldLead){
                Test.setCreatedDate(ld.Id, Date.today().addDays(-20)); //Intervalo [1 - 30] días
            }
            List<Lead> prospectos2 = getProspectos();
            insert prospectos2;

            //Insertar Lead Nuevo Interes
            for(Lead ld : oldLead){
                Test.setCreatedDate(ld.Id, Date.today().addDays(-40)); //Mayores a 30 días
            }
            List<Lead> prospectos3 = getProspectos();
            insert prospectos3;

            List<Enrutamiento_Reactivos__c> enrutamientos = getEnrutamientos(supervisores);
            insert enrutamientos;
        }
    }
    /**
    * @description: valida el registro masivo de prospectos para el trigger CEN_ProspectosDuplicados
    * @author Adolfo Crispin | 29-01-2021
    **/
    @isTest
    public static void validarRegistroMasivoDeProspectos(){
        List<Lead> prospectosRegistrados1 = [
            SELECT Id
            FROM Lead
        ];
        List<Lead> prospectos = getProspectos();
        Test.startTest();
        insert prospectos;
        Test.stopTest();
        List<Lead> prospectosRegistrados2 = [
            SELECT Id
            FROM Lead
        ];
        List<Task> tareasRegistradas = [
            SELECT Id
            FROM Task
        ];
        //System.assertEquals(prospectosRegistrados1.size(), prospectosRegistrados2.size());
        //System.assert(!tareasRegistradas.isEmpty());
        System.debug(prospectosRegistrados1.size());
        System.debug(tareasRegistradas.size());
    }
    
    @isTest
    public static void test_searchLeadBySines(){
        List<Lead> prospectosRegistrados1 = [
            SELECT Id
            FROM Lead
        ];
        
        List<Lead> prospectos = getProspectos();
        Test.startTest();
        insert prospectos;
        Test.stopTest();
        
        
        System.debug('leads prueba: '+ prospectosRegistrados1);
    }
    @isTest
    public static void test_searchLeadBySines2(){
        List<Lead> prospectosRegistrados1 = [
            SELECT Id
            FROM Lead
        ];
        
        List<Lead> prospectos = getProspectos();
        Test.startTest();
        CEN_Lead_trg_Helper.searchLeadBySines(prospectos[0], prospectos);
        Test.stopTest();
        
        
        System.debug('leads prueba: '+ prospectosRegistrados1);
    }
    @isTest
    public static void searchLeadByNdoc_test(){
        List<Lead> prospectosRegistrados1 = [
            SELECT Id
            FROM Lead
        ];
        
        List<Lead> prospectos = getProspectos();
        Test.startTest();
        CEN_Lead_trg_Helper.searchLeadByNdoc(prospectos[0], prospectos);
        Test.stopTest();
        
        
        System.debug('leads prueba: '+ prospectosRegistrados1);
    }

    /**
     *  DATA FACTORY
     */

    /**
    * @description: generador de data de Leads
    * @author Adolfo Crispin | 29-01-2021 
    * @return Lead[]
    **/
    private static List<Lead> getProspectos(){
        List<Lead> prospectos = new List<Lead>();
        List<String> nombres = new List<String>{'Editha','Luis','Felipe Alfredo','Nelida','Jose Armando','Jimmy Santy','José','José Roberto','Bismely Grisel','Eusebio','Victor Hugo','Felipe Teodoro','Anonimo'};
        List<String> apellidos = new List<String>{'Hidalgo Suárez','Pineda Quispe','Torres Cama','Rengifo','Laban Santos','Pineda Salas','Cornejo','Paulini Adrianzen','Perera Osorio','Livisi Quispe','Gamboa Gallegoa','Marroquin Vega','Anonimous'};
        List<String> documentos = new List<String>{'32363212','42074432','42074434','42054432','82442631','13268445','24410254','2838170','3459895','6135902','7004483','7083141','000000000'};
        Schema.DescribeFieldResult fieldResult = Lead.CEN_Medio__c.getDescribe();
        List<Schema.PicklistEntry> mediosPicklist = fieldResult.getPicklistValues();
        fieldResult = Lead.LeadSource.getDescribe();
        List<Schema.PicklistEntry> canalesPicklist = fieldResult.getPicklistValues();
        fieldResult = Lead.CEN_Oficina_de_Venta2__c.getDescribe();
        List<Schema.PicklistEntry> oficinasVenta = fieldResult.getPicklistValues();
        String tipoDocumento = 'DNI';
        for(Integer i=0;i<=0;i++){
            prospectos.add(
                new Lead(
                    FirstName=nombres[i],
                    LastName=apellidos[i],
                    CEN_Tipo_de_documento__c=tipoDocumento,
                    CEN_N_mero_de_documento__c=documentos[i],
                    MobilePhone = '+51999888777',
                    CEN_Medio__c=mediosPicklist[Integer.valueof((Math.random() * mediosPicklist.size()))].getValue(),
                    LeadSource=canalesPicklist[Integer.valueof((Math.random() * canalesPicklist.size()))].getValue(),
                    //CEN_Oficina_de_Venta2__c=oficinasVenta[Integer.valueof((Math.random() * oficinasVenta.size()))].getValue(),
                    CEN_Divisi_n_de_inter_s__c='Lotes de vivienda',
                    CEN_Tema_de_inter_s__c='Quiero comprar un lote',
                    CEN_Donde_comprar__c='LIMA_Lima_Norte_LU',
                    CEN_Elige_donde_vivir__c='Carabayllo - Urbanización Santa María'
                    //CEN_Elige_donde_vivir__c=eleccionesDondeVivir[Integer.valueof((Math.random() * eleccionesDondeVivir.size()))]
                )
            );
        }
        System.debug('prospectos: ' + prospectos);
        return prospectos;
    }
    /**
    * @description: generador de data de usuarios supervisores
    * @author Adolfo Crispin | 29-01-2021
    * @return User[]
    **/
    private static List<User> getSupervisores(){
        List<User> usuarios = new List<User>();
        User usuario1 = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'CEN_Supervisor_de_ventas_urbano'].Id,
            LastName = 'Supervisor 1',
            Email = 'user1@test.com',
            Username = 'user1@test.com.pe' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title1',
            Alias = 'alias1',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            Caseta_de_Venta__c = 'ZV023',
            LocaleSidKey = 'en_US'
        );
        User usuario2 = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'CEN_Supervisor_de_ventas_urbano'].Id,
            LastName = 'Supervisor 2',
            Email = 'user2@test.com',
            Username = 'user2@test.com.pe' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title2',
            Alias = 'alias2',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            Caseta_de_Venta__c = 'ZV023',
            LocaleSidKey = 'en_US'
        );
        User usuario3 = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'CEN_Supervisor_de_ventas_urbano'].Id,
            LastName = 'Supervisor 3',
            Email = 'user3@test.com',
            Username = 'user3@test.com.pe' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title3',
            Alias = 'alias3',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            Caseta_de_Venta__c = 'ZV023',
            LocaleSidKey = 'en_US'
        );
        usuarios.add(usuario1);
        usuarios.add(usuario2);
        usuarios.add(usuario3);
        return usuarios;
    }
    /**
    * @description: generador de data de enrutadores de supervisores
    * @author Adolfo Crispin | 29-01-2021
    * @param List<User> usuarios
    * @return Enrutamiento_Reactivos__c[]
    **/
    private static List<Enrutamiento_Reactivos__c> getEnrutamientos(List<User> usuarios){
        List<Enrutamiento_Reactivos__c> enrutamientos = new List<Enrutamiento_Reactivos__c>();
        for(User usuario : usuarios){
            enrutamientos.add(
                new Enrutamiento_Reactivos__c(
                    CEN_Elige_Donde_Vivir__c = eleccionesDondeVivir[Integer.valueof((Math.random() * eleccionesDondeVivir.size()))],
                    Supervisor_Asignado__c = usuario.Id
                )
            );
        }
        return enrutamientos;
    }
}