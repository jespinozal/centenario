/**
 * @description       : 
 * @author            : @everis.com
 * @group             : 
 * @last modified on  : 07-06-2021
 * @last modified by  : @everis.com
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   06-14-2021   @everis.com   Initial Version
**/
@RestResource(urlMapping='/sap/account/*')
global class CEN_AccountSAPSevice_cls {
    private static List<Account> accountsToProcess;
    private static Set<String> idExtenalAccToProcess;

    @HttpPost
    global static String doPost(){
        system.debug('doPost');
        List<CEN_AccountSapObjectResponse> myRespList = new List<CEN_AccountSapObjectResponse>();
        try {
            String jsonString = RestContext.request.requestBody.toString();
            system.debug('jsonString: '+jsonString);
            //String jsonString ='[{"typeDocument":"RUC","termsAccepted":false,"statusAccount":"Cuenta Centenario","sourceAccountData":"Salesforce","sourceMediumAccount":"0125","salesOffice":null,"phoneAccount":"988004919","numberDocument":"12345679","nameAccount":"Nayib Tamayo","headingAccount":null,"emailAccount":"test@test.com","departamento":"00001","provincia":"00001","distrito":"00001","commentary":null,"codSap":"Test_003 MOD","addressReference":"Javier prado","addressAccount":"dir test"}]';
            List<CEN_AccountSapObjectRequest> myObjReq = (List<CEN_AccountSapObjectRequest> )JSON.deserialize(jsonString,List<CEN_AccountSapObjectRequest>.class);
            if(myObjReq.size()<=200){
                List<CEN_AccountSapObjectResponse> myRespValidate = validateData(myObjReq,false);
                if(myRespValidate.size()>0){myRespList.addAll(myRespValidate);}
            
                List<CEN_AccountSapObjectResponse> myRespProcess = accountProcess (false); 
                if(myRespProcess.size()>0){myRespList.addAll(myRespProcess);}
            }else{
                CEN_AccountSapObjectResponse accMax = new CEN_AccountSapObjectResponse();
                accMax.idAccount = 'All';
                accMax.status = 'error';
                accMax.message = 'Procesar maximo de 200 cuentas';
                
                myRespList.add(accMax); 
            }
           
        } catch (Exception ex) {
            CEN_AccountSapObjectResponse accEx = new CEN_AccountSapObjectResponse();
            accEx.idAccount = 'All';
            accEx.status = 'error';
            accEx.message = ex.getMessage();
            
            myRespList.add(accEx);
        }
        String myResp = JSON.serialize(myRespList);
        system.debug('doPost-myResp: '+myResp);
        return myResp; 
    }

    @HttpPut
    global static String doPut(){
        system.debug('doPut');
        List<CEN_AccountSapObjectResponse> myRespList = new List<CEN_AccountSapObjectResponse>();
        try {
            String jsonString = RestContext.request.requestBody.toString();
            system.debug('jsonString: '+jsonString);
            //String jsonString ='[{"typeDocument":"RUC","termsAccepted":false,"statusAccount":"Cuenta Centenario","sourceAccountData":"Salesforce","sourceMediumAccount":null,"salesOffice":null,"phoneAccount":"988004919","numberDocument":null,"nameAccount":"Nayib Tamayo","headingAccount":null,"emailAccount":null,"districtAccount":null,"commentary":null,"codSap":null,"addressReference":"Javier prado","addressAccount":null}]';
            List<CEN_AccountSapObjectRequest> myObjReq = (List<CEN_AccountSapObjectRequest> )JSON.deserialize(jsonString,List<CEN_AccountSapObjectRequest>.class);
            if(myObjReq.size()<=200){
                List<CEN_AccountSapObjectResponse> myRespValidate = validateData(myObjReq,true);
                if(myRespValidate.size()>0){myRespList.addAll(myRespValidate);}
            
                List<CEN_AccountSapObjectResponse> myRespProcess = accountProcess (true); 
                if(myRespProcess.size()>0){myRespList.addAll(myRespProcess);}
            }else{
                CEN_AccountSapObjectResponse accMax = new CEN_AccountSapObjectResponse();
                accMax.idAccount = 'All';
                accMax.status = 'error';
                accMax.message = 'Procesar maximo de 200 cuentas';
                
                myRespList.add(accMax); 
            }
           
        } catch (Exception ex) {
            CEN_AccountSapObjectResponse accEx = new CEN_AccountSapObjectResponse();
            accEx.idAccount = 'All';
            accEx.status = 'error';
            accEx.message = ex.getMessage();
            
            myRespList.add(accEx);
        }
        String myResp = JSON.serialize(myRespList);
        system.debug('doPut-myResp: '+myResp);
        return myResp;
    }

    private static List<CEN_AccountSapObjectResponse> accountProcess (Boolean isAccUpdate){
        system.debug('accountProcess');

        List<CEN_AccountSapObjectResponse> processResp = new List<CEN_AccountSapObjectResponse> ();
        system.debug('accountProcess-accountsToProcess: '+accountsToProcess);
																			 
        if(accountsToProcess.size()>0){
            Database.SaveResult[] srList;
            if(isAccUpdate){
                List<Account> getAccUpdate = [SELECT Id, CEN_Tipo_de_documento__c,CEN_N_mero_de_documento__pc,CEN_Numero_de_documento_del__c FROM Account WHERE CEN_Numero_de_documento_del__c IN :idExtenalAccToProcess OR CEN_N_mero_de_documento__pc IN :idExtenalAccToProcess ];
                for(Account getAcc: getAccUpdate ){
                    for(Account accUpdate: accountsToProcess){
                        if((accUpdate.CEN_Tipo_de_documento__c == 'RUC' && accUpdate.CEN_Numero_de_documento_del__c == getAcc.CEN_Numero_de_documento_del__c) 
                            || (accUpdate.CEN_Tipo_de_documento__c != 'RUC' && accUpdate.CEN_N_mero_de_documento__pc ==getAcc.CEN_N_mero_de_documento__pc)){
                            accUpdate.Id = getAcc.Id;
                        }
                    }
                }
									   
												
                srList = Database.update(accountsToProcess, false);
            }
            else{srList = Database.insert(accountsToProcess, false);}
            
            Integer pos = 0 ;
            for (Database.SaveResult sr : srList) {
                Account getAcc = accountsToProcess.get(pos);
                if (sr.isSuccess()) {
                    CEN_AccountSapObjectResponse accSucces = new CEN_AccountSapObjectResponse();
                    accSucces.idAccount = getAcc.CEN_Numero_de_documento_del__c!=null?getAcc.CEN_Numero_de_documento_del__c:getAcc.CEN_N_mero_de_documento__pc;
                    accSucces.status = 'succes';
                    accSucces.message = 'Cliente procesado con exito';
                    processResp.add(accSucces);
                }else {
                    // Operation failed, so get all errors
                    for(Database.Error err : sr.getErrors()) {
                        CEN_AccountSapObjectResponse accError = new CEN_AccountSapObjectResponse();
                        accError.idAccount = getAcc.CEN_Numero_de_documento_del__c!=null?getAcc.CEN_Numero_de_documento_del__c:getAcc.CEN_N_mero_de_documento__pc;
                        accError.status = 'error';
                        accError.message = isAccUpdate && getAcc.Id==null?'Cliente no encontrado':err.getStatusCode() + ': ' + err.getMessage();
                        processResp.add(accError);
                    }
                }
                ++pos;
            }
           }

           system.debug('accountProcess-processResp: '+processResp);
           return processResp;
    }

    private static List<CEN_AccountSapObjectResponse> validateData(List<CEN_AccountSapObjectRequest> myAccReq, Boolean isAccUpdate){
        system.debug('validateData-myAccReq: '+myAccReq);
        List<CEN_AccountSapObjectResponse> myAccResp = new List<CEN_AccountSapObjectResponse>();
        accountsToProcess =  new List<Account> ();
        Map<String, String> mapDistri = getDistri ();
        idExtenalAccToProcess = new Set<String>();

        for(CEN_AccountSapObjectRequest myAcc: myAccReq){
            Account acc = new Account();
            try{

                //if(isAccUpdate && myAcc.nameAccount!=null){acc.Name=myAcc.nameAccount;}
                if(!isAccUpdate && myAcc.nameAccount==null){throw new AccountSAPSeviceException('Debe indicar el campo Name');}
                else{
                    if(myAcc.typeDocument=='RUC'){
                        acc.Name=myAcc.lastNameAccount;
                    }else{
                        acc.FirstName = myAcc.nameAccount;
                        acc.LastName = myAcc.lastNameAccount;
                    }
                    
                }

                if(myAcc.typeDocument!=null){
                    if(myAcc.typeDocument=='RUC'){
                        acc.CEN_Tipo_de_documento__c=myAcc.typeDocument;
                        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Cuenta_Empresa').getRecordTypeId();
                    }else{
                        acc.CEN_Tipo_de_documento__pc=myAcc.typeDocument;
                        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
                    }
                }
                else if(!isAccUpdate && myAcc.typeDocument==null){throw new AccountSAPSeviceException('Debe indicar el campo typeDocument');}
                
                if(myAcc.numberDocument==null){throw new AccountSAPSeviceException('Debe indicar el campo numberDocument');}
                else{
                    if(myAcc.typeDocument=='RUC'){
                        acc.CEN_Numero_de_documento_del__c=myAcc.numberDocument;
                    }else{
                        acc.CEN_N_mero_de_documento__pc=myAcc.numberDocument;
                    }
                    idExtenalAccToProcess.add(myAcc.numberDocument);
                }

                if(isAccUpdate && myAcc.phoneAccount!=null){
                    if(myAcc.typeDocument=='RUC'){
                        acc.Phone =myAcc.phoneAccount;
                    }else{
                        acc.PersonMobilePhone =myAcc.phoneAccount;
                    }
                }
                else if(!isAccUpdate && myAcc.phoneAccount==null){throw new AccountSAPSeviceException('Debe indicar el campo phoneAccount');}
                else{
                    if(myAcc.typeDocument=='RUC'){
                        acc.Phone =myAcc.phoneAccount;
                    }else{
                        acc.PersonMobilePhone =myAcc.phoneAccount;
                    }
                }

                if(myAcc.salesOffice!=null){acc.CEN_Oficina_de_venta__c = myAcc.typeDocument=='RUC' ? myAcc.salesOffice : null;}

                if(myAcc.headingAccount!=null){acc.CEN_Rubro__c = myAcc.typeDocument=='RUC' ? myAcc.headingAccount : null;}

                String myKeyDistrito;
                if(isAccUpdate && myAcc.departamento!=null){myKeyDistrito=myAcc.departamento;}
                else if(!isAccUpdate && myAcc.departamento==null){throw new AccountSAPSeviceException('Debe indicar el campo departamento');}
                else{myKeyDistrito=myAcc.departamento;}
                
                if(isAccUpdate && myAcc.provincia!=null){myKeyDistrito+=myAcc.provincia;}
                else if(!isAccUpdate && myAcc.provincia==null){throw new AccountSAPSeviceException('Debe indicar el campo provincia');}
                else{myKeyDistrito=myKeyDistrito+myAcc.provincia;}

                if(isAccUpdate && myAcc.distrito!=null){myKeyDistrito+=myAcc.distrito;}
                else if(!isAccUpdate && myAcc.distrito==null){throw new AccountSAPSeviceException('Debe indicar el campo distrito');}
                else{myKeyDistrito=myKeyDistrito+myAcc.distrito;}

                if(myKeyDistrito!=null && mapDistri.get(myKeyDistrito)==null){throw new AccountSAPSeviceException('Debe indicar el Departamento, Provincia y Distrito validos');}
                else{
                    if(myAcc.typeDocument=='RUC'){
                        acc.CEN_Distrito__c = mapDistri.get(myKeyDistrito);
                    }else{
                        acc.CEN_Distrito__pc = mapDistri.get(myKeyDistrito);
                    }
                }

                if(isAccUpdate && myAcc.addressAccount!=null){
                    if(myAcc.typeDocument=='RUC'){
                        acc.CEN_Direcci_n__c =myAcc.addressAccount;
                    }else{
                        acc.CEN_Direccion__pc =myAcc.addressAccount;
                    }
                }
                else if(!isAccUpdate && myAcc.addressAccount==null){throw new AccountSAPSeviceException('Debe indicar el campo addressAccount');}
                else{
                    if(myAcc.typeDocument=='RUC'){
                        acc.CEN_Direcci_n__c =myAcc.addressAccount;
                    }else{
                        acc.CEN_Direccion__pc =myAcc.addressAccount;
                    }
                }

                if(myAcc.sourceMediumAccount!=null){acc.CEN_Medio__c =myAcc.sourceMediumAccount;}
                
                if(myAcc.statusAccount!=null){acc.CEN_Estado__c =myAcc.statusAccount;}

                if(myAcc.commentary!=null){acc.Comentario__c =myAcc.commentary;}

                if(myAcc.addressReference!=null){acc.CEN_Referencia_direccion__c =myAcc.addressReference;}

                if(myAcc.termsAccepted!=null){acc.Prospecto_acept_t_rminos_y_condiciones__c =myAcc.termsAccepted;}

                acc.CEN_Origen__c = 'SAP';

                if(isAccUpdate && myAcc.codSap!=null){
                    acc.Cod_Interno_SAP_Empresa__c =myAcc.codSap;
                }
                else if(!isAccUpdate && myAcc.codSap==null){throw new AccountSAPSeviceException('Debe indicar el campo codSap');}
                else{acc.Cod_Interno_SAP_Empresa__c =myAcc.codSap;}

                if(isAccUpdate && myAcc.emailAccount!=null){
                    if(myAcc.typeDocument=='RUC'){
                        acc.CEN_fld_Correo_empresa__c =myAcc.emailAccount;
                    }else{
                        acc.PersonEmail =myAcc.emailAccount;
                    }
                }
                else if(!isAccUpdate && myAcc.emailAccount==null){throw new AccountSAPSeviceException('Debe indicar el campo emailAccount');}
                else{
                    if(myAcc.typeDocument=='RUC'){
                        acc.CEN_fld_Correo_empresa__c =myAcc.emailAccount;
                    }else{
                        acc.PersonEmail =myAcc.emailAccount;
                    }
                }
                accountsToProcess.add(acc);
            } catch (Exception ex) {
                CEN_AccountSapObjectResponse accEx = new CEN_AccountSapObjectResponse();
                accEx.idAccount = myAcc.codSap;
                accEx.status = 'error';
                accEx.message = 'errorValidate: ' +ex.getMessage();
                
                myAccResp.add(accEx);
            }
        }
        system.debug('validateData-myAccResp: '+myAccResp);
        return myAccResp;
    }

    private static Map<String, String> getDistri (){
        Map<String, String> mapRes = new Map<String, String>();
       List<Tabla_maestra__c> distris = [SELECT Id, CEN_Codigo_departamento__c, CEN_Codigo_distrito__c, CEN_Codigo_provincia__c FROM Tabla_maestra__c];
       for(Tabla_maestra__c d: distris){
        String myKey = d.CEN_Codigo_departamento__c  + d.CEN_Codigo_provincia__c + d.CEN_Codigo_distrito__c ; 
        mapRes.put(myKey, d.Id);
       }
       System.debug(mapRes);
       return mapRes;
    }

    

    public class AccountSAPSeviceException extends Exception {} 
}