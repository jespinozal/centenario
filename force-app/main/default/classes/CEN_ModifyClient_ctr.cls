public with sharing class CEN_ModifyClient_ctr {

    @future(callout=true)
    public static void callModifyClientAsync(Set<Id> ids, Map<String,String> mapAccount) {
        System.Debug('***IN CEN_ModifyClient_ctr.callModifyClient***');

        List<Account> cuenta = [SELECT Id,Name, CEN_SocietySAP__c, OwnerId FROM Account WHERE Id IN:ids];
        String titleNotification='Modificación de Cliente en SAP';
        String bodyNotification;
        String targetNotification = cuenta[0].Id;
        Set<String> recipientId = new Set<String> {cuenta[0].OwnerId};

        try {
            String strSociety = cuenta[0].CEN_SocietySAP__c;
            CEN_ModifyClientObjectResponse resp = null;
            if(String.isNotBlank(strSociety)){
                String[] arrSociety = strSociety.split(';');
                resp = CEN_ModifyClient_cls.modifyClientById(cuenta[0].Id, arrSociety[0], mapAccount);
            }else{
                bodyNotification = 'El cliente aún no esta registrado SAP';
                myNotification (titleNotification, bodyNotification, targetNotification, recipientId );
            }

            System.debug('resp-callModifyClient: ' + resp);
            if(resp != null){
                if(resp.E_OK == 'X'){
                    bodyNotification = 'Se modificó el cliente '+cuenta[0].Name+' en SAP';
                    myNotification (titleNotification, bodyNotification, targetNotification, recipientId );
                }else{
                    bodyNotification = resp.ET_RETURN.item[0].MESSAGE;
                    myNotification (titleNotification, bodyNotification, targetNotification, recipientId );
                }
            }
        } catch (Exception ex) {
            myNotification ('Error Tecnico', 'Error: '+ex.getMessage()+'. Linea: '+ex.getLineNumber(), targetNotification, recipientId );
            System.debug('Error SAP: '+ ex);
        }
    }

    @InvocableMethod(label='UpdateAccountData')
    public static void CEN_ModifyClient_ctr(List<Requests> accs) {
        System.Debug('***IN CEN_ModifyClient_ctr.CEN_ModifyClient_ctr***');
        try {
            Set<id> recordId = new Set<id>();
            Map<String,String> mapFlagAccount = new Map<String,String>();
            for(Requests r: accs){
                recordId.add(r.recordId);
                mapFlagAccount.put('tratamiento', r.tratamiento);
                mapFlagAccount.put('nombres', r.nombres);
                mapFlagAccount.put('direccion', r.direccion);
                mapFlagAccount.put('referencia', r.referencia);
                mapFlagAccount.put('telefonoFijo', r.telefonoFijo);
                mapFlagAccount.put('telefonoMovil', r.telefonoMovil);
                mapFlagAccount.put('email', r.email);
                mapFlagAccount.put('lugarNacimiento', r.lugarNacimiento);
                mapFlagAccount.put('fechaNacimiento', r.fechaNacimiento);
                mapFlagAccount.put('estadoCivil', r.estadoCivil);
                mapFlagAccount.put('apellidos', r.apellidos);
                mapFlagAccount.put('nacionalidad', r.nacionalidad);
                mapFlagAccount.put('distrito', r.distrito);
                mapFlagAccount.put('provincia', r.provincia);
                mapFlagAccount.put('departamento', r.departamento);
            }

            callModifyClientAsync(recordId, mapFlagAccount);

        } catch (Exception ex) {
            System.debug('Error SAP: '+ ex);
        }
    }

    private static void myNotification (String notiTitle, String notiBody, String notiTarget, Set<String> notiRecipients ){
        String notiId = [SELECT Id, DeveloperName
                         FROM CustomNotificationType
                         WHERE DeveloperName = 'Notificacin_de_la_organizacin' ].Id;
        Messaging.CustomNotification notification = new Messaging.CustomNotification();
        notification.setTitle(notiTitle);
        notification.setBody(notiBody);
        notification.setNotificationTypeId(notiId);
        notification.setTargetId(notiTarget);
        notification.send(notiRecipients);
    }

    public class Requests {
        @InvocableVariable(required=true)
        public String recordId;
        @InvocableVariable
        public String tratamiento;
        @InvocableVariable
        public String nombres;
        @InvocableVariable
        public String direccion;
        @InvocableVariable
        public String referencia;
        @InvocableVariable
        public String telefonoFijo;
        @InvocableVariable
        public String telefonoMovil;
        @InvocableVariable
        public String email;
        @InvocableVariable
        public String lugarNacimiento;
        @InvocableVariable
        public String fechaNacimiento;
        @InvocableVariable
        public String estadoCivil;
        @InvocableVariable
        public String apellidos;
        @InvocableVariable
        public String nacionalidad;
        @InvocableVariable
        public String distrito;
        @InvocableVariable
        public String provincia;
        @InvocableVariable
        public String departamento;

    }

}