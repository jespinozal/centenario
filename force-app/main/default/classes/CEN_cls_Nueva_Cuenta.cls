public class CEN_cls_Nueva_Cuenta {
    @AuraEnabled
    public static RecordType getRecordTypeCuentaNatural(){
        RecordType response = null;
        try{
            response = [SELECT Id, Name FROM RecordType WHERE Name='Cuenta Natural' LIMIT 1];
        }catch(Exception ex){
            System.debug('Exception: '+ex.getMessage()+'. Line: '+ex.getLineNumber()+'. Type: '+ex.getTypeName());
        }
        return response;
    }
}