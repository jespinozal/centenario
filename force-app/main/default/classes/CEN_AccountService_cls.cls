/********************************************************************************
* @author: Katherine Espinoza (kespinod@everis.com)
* @date: 2021-04-14
* @description: web service para envío de email y celular hacia la web de terrenos.
* 
* VERSION		DATE			AUTOR					ACTION
* 0.1			2021-04-12		Katherine Espinoza		Creación
* 0.2			2021-05-07		Alan Alvarez			Actualización
********************************************************************************/
@RestResource(urlMapping='/account/*')
global class CEN_AccountService_cls {
    
    @HttpGet
    global static List<accountresp> doGet(){
        RestRequest req = RestContext.request;
        String dni = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        List<Account> lstAccount = [select Recordtype.DeveloperName,
                                    FirstName, LastName, PersonEmail, PersonMobilePhone, CEN_Distrito__pr.Name, CEN_Direccion__pc,
                                    Name, CEN_fld_Correo_empresa__c, Phone, CEN_Distrito__r.Name, CEN_Direcci_n__c
                                    from account 
                                    where CEN_N_mero_de_documento__pc =:dni or CEN_Numero_de_documento_del__c =:dni];
        
        accountresp accResp;
        List<accountresp> lstAccResp = new List<accountresp>();
        for(Account objAccount: lstAccount){
            accResp = new accountresp();
            accResp.contry_code = 'PE';
            if(objAccount.Recordtype.DeveloperName == 'PersonAccount'){
                accResp.first_name = objAccount.FirstName;
            	accResp.last_name = objAccount.LastName;
                accResp.email = objAccount.PersonEmail;
                accResp.mobile = objAccount.PersonMobilePhone;
                accResp.address_city = objAccount.CEN_Distrito__pr.Name;
                accResp.address = objAccount.CEN_Direccion__pc;
            }else{
                accResp.first_name = objAccount.Name;
                accResp.email = objAccount.CEN_fld_Correo_empresa__c;
                accResp.mobile = objAccount.Phone;
                accResp.address_city = objAccount.CEN_Distrito__r.Name;
                accResp.address = objAccount.CEN_Direcci_n__c;
            }
            lstAccResp.add(accResp);
        }
        return lstAccResp;
    }
    
    global class accountresp{
        private String first_name { get; set; }
        private String last_name { get; set; }
        private String address { get; set; }
        private String contry_code { get; set; }
        private String address_city { get; set; }
        private String email { get; set; }
        private String mobile { get; set; }
    }
    
}