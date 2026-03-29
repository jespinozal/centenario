/**
 * @name               : 
 * @author             : Luis Maldonado
 * @creation date      : 
 * @modification date  : 10-10-2024
 * @last modified by   : Luis Maldonado
 * @description        : 
 * @versions           : version 1.0: clase apex inicial 
 * Modifications Log
 * Ver   Date         Author           Modification
 * 1.0   07-10-2024   Luis Maldonado   Initial Version
**/
@isTest
public class CEN_AgentWorkUpdate_test {
    @testSetup
    static void setup() {
        
        // Crear un Lead
        Lead lead = new Lead(
            FirstName = 'Luisillo', 
            LastName = 'Davila', 
            Company = 'Test Company',
            LeadSource = 'Presencial',
            CEN_Medio__c = '0110'
        	);
        insert lead;

        // Crear un AgentWork con el propietario original
        //AgentWork aw = new AgentWork(OwnerId = owner1.Id, WorkItemId = lead.Id);
        //insert aw;
        
        
        /* Consulta un ServiceChannel existente
        //ServiceChannel serviceChannel = [SELECT Id FROM ServiceChannel LIMIT 1];
        //System.debug('serviceChannel IDD: '+ serviceChannel);
        // Consulta un ServicePresenceStatus existente (por ejemplo, 'Available')
        //ServicePresenceStatus presenceStatus = [SELECT Id FROM ServicePresenceStatus LIMIT 1];
        //System.debug('presenceStatus IDD: '+ presenceStatus);
        // Verifica si existe un ServiceChannelStatus que relacione el ServiceChannel y el ServicePresenceStatus
        ServiceChannelStatus channelStatus = [SELECT Id FROM ServiceChannelStatus 
                                          	WHERE ServiceChannelId = :serviceChannel.Id 
                                          	AND ServicePresenceStatusId = :presenceStatus.Id 
                                          	LIMIT 1];
        System.debug('channelStatus IDD: '+ channelStatus);*/

    }

    //@isTest
    //static void testAgentWorkInsert() {
    //    // Obtener el Lead y el Evento creados en testSetup
    //    Lead testLead = [SELECT Id FROM Lead LIMIT 1];
    //    Event testEvent = [SELECT Id, OwnerId FROM Event WHERE WhoId = :testLead.Id LIMIT 1];

    //    // Crear un nuevo usuario como nuevo propietario
    //    User owner2 = [SELECT Id FROM User WHERE Profile.Name = 'Standard User' AND Id != :testEvent.OwnerId LIMIT 1];

    //    // Crear un nuevo AgentWork con un nuevo OwnerId
    //    AgentWork newAw = new AgentWork(OwnerId = owner2.Id, WorkItemId = testLead.Id);
    //    insert newAw;

    //    // Verificar que el evento relacionado se haya actualizado correctamente
    //    Event updatedEvent = [SELECT OwnerId FROM Event WHERE Id = :testEvent.Id];
    //    System.assertEquals(owner2.Id, updatedEvent.OwnerId, 'El propietario del evento debe haberse actualizado.');
    //}

    //@isTest
    //static void testAgentWorkUpdate() {
    //    // Obtener el AgentWork creado en testSetup
    //    AgentWork testAw = [SELECT Id, OwnerId, WorkItemId FROM AgentWork LIMIT 1];

    //    // Crear un nuevo usuario como nuevo propietario
    //    User owner2 = [SELECT Id FROM User WHERE Profile.Name = 'Standard User' AND Id != :testAw.OwnerId LIMIT 1];

    //    // Actualizar el OwnerId del AgentWork
    //    testAw.OwnerId = owner2.Id;
    //    update testAw;

    //    // Verificar que el evento relacionado se haya actualizado correctamente
    //    Lead testLead = [SELECT Id FROM Lead LIMIT 1];
    //    Event updatedEvent = [SELECT OwnerId FROM Event WHERE WhoId = :testLead.Id LIMIT 1];
    //    System.assertEquals(owner2.Id, updatedEvent.OwnerId, 'El propietario del evento debe haberse actualizado después de la actualización de AgentWork.');
    //}

    @isTest
    static void testLuis() {
        ServiceChannel serviceChannel = [SELECT Id FROM ServiceChannel LIMIT 1];
        System.debug('serviceChannel IDD: '+ serviceChannel);
        
        User u = new User();
        u.Id = UserInfo.getUserId();
        
        ServiceChannel sc = [
                SELECT Id
                FROM ServiceChannel 
                WHERE DeveloperName = 'CEN_Lead_Channel'
                LIMIT 1];
        System.debug('serviceChannel: '+ serviceChannel);

        
        
        // Crear un Lead
        Lead lead = new Lead(
            FirstName = 'Luisillo', 
            LastName = 'Davila', 
            Company = 'Test Company',
            LeadSource = 'Presencial',
            CEN_Medio__c = '0110'
        	);
        insert lead;
        
        // Crear un Evento asociado al Lead
        Event event = new Event(
            WhoId = lead.Id, // Asociar el evento con el Lead
            Subject = 'Reunión de seguimiento',
            StartDateTime = DateTime.now(),
            EndDateTime = DateTime.now().addHours(1),
            Location = 'Oficina',
            Description = 'Reunión presencial para discutir oportunidades.'
        );
        insert event;
        
        Lead LeadRep = [SELECT Id FROM Lead WHERE FirstName = 'Luisillo' LIMIT 1];
        
        
        ID servicepresenceId= [SELECT Id FROM servicepresencestatus Where MasterLabel ='Disponible' Limit 1].Id;
        System.debug('eh' + servicepresenceId);
    	ID SChannelId= [SELECT Id FROM ServiceChannel Where DeveloperName='CEN_Lead_Channel' Limit 1].Id;
        System.debug('eh SChannelId' + SChannelId);
    	UserServicePresence usrpresense = new UserServicePresence();
        System.debug('eh usrpresense' + usrpresense);
    	usrpresense.ServicePresenceStatusId=servicepresenceId;
    	usrpresense.UserId = u.Id;
        insert usrpresense;
        System.debug('eh usrpresense final' + usrpresense);

    	/*PendingServiceRouting psr = new PendingServiceRouting();
    	psr.CapacityWeight = 1;
    	psr.ServiceChannelId = SChannelId;
        psr.RoutingType = 'QueueBased';
        insert psr;*/
        
       
        AgentWork aw = new AgentWork(
                ServiceChannelId = SChannelId,
                WorkItemId = lead.Id,
                UserId = u.Id
        );

        insert aw;
    }
}