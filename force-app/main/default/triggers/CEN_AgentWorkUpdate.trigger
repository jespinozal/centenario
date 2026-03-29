/**
 * @name               : CEN_AgentWorkUpdate
 * @author             : Luis Maldonado
 * @creation date      : 30-09-2024
 * @modification date  : 30-09-2024
 * @last modified by   : Luis Maldonado
 * @description        : Trigger que actualiza el owner de un evento asociado a un lead cuando este cambia por medio del omnichannel
 * @versions           : version 1.0: clase apex inicial 
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   30-09-2024   Luis Maldonado   Initial Version
**/
trigger CEN_AgentWorkUpdate on AgentWork (after insert, after update) {
    List<Event> eventsToUpdate = new List<Event>();

    for (AgentWork aw : Trigger.new) {
        AgentWork oldAw = Trigger.oldMap != null ? Trigger.oldMap.get(aw.Id) : null;

        if (oldAw == null || aw.OwnerId != oldAw.OwnerId) {
            if (!String.valueOf(aw.OwnerId).startsWith('00G')) {
                if (aw.WorkItemId != null && [SELECT Id FROM Lead WHERE Id = :aw.WorkItemId].size() > 0) {
                    // Obtener los eventos relacionados con el Lead cuyo OwnerId ha cambiado
                    List<Event> relatedEvents = [
                        SELECT Id, OwnerId 
                        FROM Event 
                        WHERE WhoId = :aw.WorkItemId
                    ];

                    // Actualizacion de los propietarios
                    for (Event evt : relatedEvents) {
                        evt.OwnerId = aw.OwnerId;
                        eventsToUpdate.add(evt);
                    }
                }
            }
        }
    }

    if (!eventsToUpdate.isEmpty()) {
        update eventsToUpdate;
    }
}