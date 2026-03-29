/********************************************************************* 
* @author: Alan Alvarez (aalvarpe@everis.com) 
* @date: 2021-06-14 
* @description: Handler - Arqueo de Caja. 
* 
* VERSION      DATE                 AUTOR                  ACTION 
* 0.1          2021-06-14           Alan Alvarez           Creación 
*  
*********************************************************************/ 
public class CEN_CashRegistredTriggerHandler_cls {
    
    public static void triggerInsert(List<CEN_CashRegistred__c> newMap){
        Map<Id,String> mapRecordType = new Map<Id,String>();
        List<RecordType> lstRecordType = [Select Id, Name From RecordType Where SobjectType = 'CEN_CashRegistred__c'];
        for(RecordType r: lstRecordType){
            mapRecordType.put(r.Id, r.Name);
        }
        List<Proyecto__c> lstProyecto = [Select Name From Proyecto__c Where id = :newMap[0].CEN_OfficeProyect__c];
        if(lstProyecto.size() > 0){
            //Actualizar Nombre de Arqueo con TipoRegistro + Proyecto + Fecha
            Datetime myPaymentDate = newMap[0].CEN_PayOrderDate__c;
            Timezone tz = Timezone.getTimeZone('America/Lima');
            Integer offset = tz.getOffset(myPaymentDate);
            Datetime localPaymentDate = myPaymentDate.addSeconds(offset/1000);
            String newName = mapRecordType.get(newMap[0].RecordTypeId) + ' - ' + lstProyecto[0].Name + ' - ' + localPaymentDate;
            newMap[0].Name = newName;
        }
    }
    
}