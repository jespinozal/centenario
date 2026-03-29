/**
 * Jesus Poco
 * jpocosal@emeal.nttdata.com
 */
trigger CEN_CaseOwnerValidationTrigger on Case (before update) {
    // Obtener el ID del Record Type "CEN_InteraccionContrato"
    Id recordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Case' AND DeveloperName = 'CEN_InteraccionContrato' LIMIT 1]?.Id;
    
    // Si no se encuentra el Record Type, salir para evitar errores
    if (recordTypeId == null) {
        return;
    }

    // Obtener el ID del usuario actual
    Id currentUserId = UserInfo.getUserId();
    
    // Recopilar IDs de casos que cumplen las condiciones iniciales
    Set<Id> queueOwnerIds = new Set<Id>();
    for (Case c : Trigger.new) {
        Case oldCase = Trigger.oldMap.get(c.Id);
        // Verificar cambio de propietario, Record Type y que el owner anterior sea una cola
        if (c.OwnerId != oldCase.OwnerId && c.RecordTypeId == recordTypeId && oldCase.OwnerId.getSObjectType() == Group.SObjectType) {
            queueOwnerIds.add(oldCase.OwnerId);
        }
    }
    
    // Si no hay casos relevantes, salir
    if (queueOwnerIds.isEmpty()) {
        return;
    }
    
    // Consultar las colas relevantes (solo "CEN_Cola_de_Administradores_de_Casos")
    Map<Id, Group> validQueues = new Map<Id, Group>([
        SELECT Id, DeveloperName 
        FROM Group 
        WHERE Id IN :queueOwnerIds 
        AND Type = 'Queue' 
        AND DeveloperName = 'CEN_Cola_de_Administradores_de_Casos'
    ]);
    
    // Consultar membresías del usuario actual en las colas relevantes
    Set<Id> userMembershipQueueIds = new Set<Id>();
    for (GroupMember gm : [SELECT GroupId FROM GroupMember WHERE GroupId IN :validQueues.keySet() AND UserOrGroupId = :currentUserId]) {
        userMembershipQueueIds.add(gm.GroupId);
    }
    
    // Validar cada caso
    for (Case c : Trigger.new) {
        Case oldCase = Trigger.oldMap.get(c.Id);
        // Solo procesar casos con Record Type correcto y cambio de propietario
        if (c.OwnerId != oldCase.OwnerId && c.RecordTypeId == recordTypeId && oldCase.OwnerId.getSObjectType() == Group.SObjectType) {
            // Verificar si el owner anterior es la cola correcta
            Group queue = validQueues.get(oldCase.OwnerId);
            if (queue != null) { // Es la cola "CEN_Cola_de_Administradores_de_Casos"
                // Validación 1: El nuevo propietario debe ser el usuario actual
                if (c.OwnerId != currentUserId) {
                    c.addError('Solo los miembros de la cola de administradores de casos pueden asignarse el caso. El propietario no puede ser distinto al logueado.');
                }
                // Validación 2: El usuario actual debe ser miembro de la cola
                else if (!userMembershipQueueIds.contains(oldCase.OwnerId)) {
                    c.addError('No eres miembro de la Cola de Administradores de Casos. No puedes tomar este caso.');
                }
            }
        }
    }
}