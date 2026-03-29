public with sharing class CEN_BotObtenerGestionCurso {

    /**
     * @description Método invocable que obtiene oportunidades o leads basados en los filtros proporcionados: tipo de documento, número de documento, número de teléfono y nombre de proyecto.
     * @param input Lista de requests, que debe contener un solo elemento con los filtros requeridos.
     * @return Lista de respuestas con los detalles de la oportunidad o lead que cumple con los filtros.
     */
    @InvocableMethod(label='Obtener oportunidad o lead por filtros' description='Obtiene la oportunidad o lead que coincide con los filtros de tipo de documento, número de documento, número de teléfono y nombre de proyecto')
    public static List<Response> getOpportunityOrLeadByFilters(List<Request> input) {
        
        

        if (input == null || input.size() != 1) {
            return null;  // Verificación de entrada válida
        }
        Request req = input[0];
        List<Response> lstRespuesta = new List<Response>();
        
        String switchDE = String.isNotBlank(Label.RS_SwitchCallDE)? Label.RS_SwitchCallDE : null;
        
        if(switchDE==null || switchDE!='true') return null;
        
        String vphone = String.isNotBlank(req.numeroTelefono) ? '+51' + req.numeroTelefono.right(9):null;

        // Validación para el input obligatorio número de teléfono
        if (String.isBlank(req.numeroTelefono)) {
            return null;  // Si el número de teléfono está vacío, se retorna null
        }

        // Intento de búsqueda en Opportunity
        Boolean foundRecord = false;
        
        if (String.isBlank(req.tipoDocumento) && String.isBlank(req.numeroDocumento) && String.isBlank(req.nombreProyecto)) {
            // Caso 1: Solo se usa número de teléfono
            String query = 'SELECT Id, OwnerId, Owner.Name ' +
                           'FROM Opportunity ' +
                           'WHERE Account.PersonMobilePhone = \'' + String.escapeSingleQuotes(vphone) + '\' ' +
                           'AND StageName != \'Closed Lost\' AND Owner.IsActive = true ' +
                           'ORDER BY CreatedDate DESC LIMIT 1';

            List<Opportunity> oportunidades = Database.query(query);

            if (!oportunidades.isEmpty()) {
                Opportunity opp = oportunidades[0];
                Response res = new Response();
                res.opportunityId = opp.Id;
                res.ownerId = opp.OwnerId;
                res.ownerName = opp.Owner.Name;
                res.foundType = 'Opportuntiy';
                res.nameMenu = 'Menú Ventas Gestión';
                lstRespuesta.add(res);
                foundRecord = true;
            }
        } else {
            // Caso 2: Se proporcionan otros filtros
            String query = 'SELECT Id, OwnerId, Owner.Name, Account.CEN_Tipo_de_documento__pc, Account.CEN_N_mero_de_documento__pc, Account.PersonMobilePhone ' +
                           'FROM Opportunity ' +
                           'WHERE Account.PersonMobilePhone = \'' + String.escapeSingleQuotes(vphone) + '\' ' +
                           'AND StageName != \'Closed Lost\' AND Owner.IsActive = true ';

            if (String.isNotBlank(req.tipoDocumento)) {
                query += 'AND Account.CEN_Tipo_de_documento__pc = \'' + String.escapeSingleQuotes(req.tipoDocumento) + '\' ';
            }
            if (String.isNotBlank(req.numeroDocumento)) {
                query += 'AND Account.CEN_N_mero_de_documento__pc = \'' + String.escapeSingleQuotes(req.numeroDocumento) + '\' ';
            }
            if (String.isNotBlank(req.nombreProyecto)) {
                query += 'AND Proyecto__c = \'' + String.escapeSingleQuotes(req.nombreProyecto) + '\' ';
            }

            query += 'LIMIT 1';

            List<Opportunity> oportunidades = Database.query(query);

            if (!oportunidades.isEmpty()) {
                Opportunity opp = oportunidades[0];
                Response res = new Response();
                res.opportunityId = opp.Id;
                res.ownerId = opp.OwnerId;
                res.ownerName = opp.Owner.Name;
                res.foundType = 'Opportunity';
                res.nameMenu = 'Menú Ventas Gestión';
                lstRespuesta.add(res);
                foundRecord = true;
            }
        }

        // Si no se encuentra un registro en Opportunity, intenta en Lead usando todos los criterios disponibles
        if (!foundRecord) {
            String leadQuery = 'SELECT Id, OwnerId, Owner.Name,CEN_Elige_donde_vivir__c,Owner.IsActive ' +
                               'FROM Lead ' +
                               'WHERE MobilePhone = \'' + String.escapeSingleQuotes(vphone) + '\' ' +
                               'AND Status != \'Desestimado\'';

            if (String.isNotBlank(req.tipoDocumento)) {
                leadQuery += 'AND CEN_Tipo_de_documento__c = \'' + String.escapeSingleQuotes(req.tipoDocumento) + '\' ';
            }
            if (String.isNotBlank(req.numeroDocumento)) {
                leadQuery += 'AND CEN_N_mero_de_documento__c = \'' + String.escapeSingleQuotes(req.numeroDocumento) + '\' ';
            }
            if (String.isNotBlank(req.nombreProyecto)) {
                leadQuery += 'AND Proyecto__c = \'' + String.escapeSingleQuotes(req.nombreProyecto) + '\' ';
            }

            leadQuery += 'ORDER BY CreatedDate DESC LIMIT 1';

            List<Lead> leads = Database.query(leadQuery);

            if (!leads.isEmpty()) {
                Lead lead = leads[0];
                Response res = new Response();
                if (lead.Owner.IsActive){
                        res.leadId = lead.Id;
                        res.ownerId = lead.OwnerId;
                        res.ownerName = lead.Owner.Name;
                        res.foundType = 'Lead';
                        res.nameMenu = 'Menú Ventas Gestión';
                        lstRespuesta.add(res);
               			 }
            }
            else 
            	{
                    Response res = new Response();
                	res.isNew = true;
                    lstRespuesta.add(res);
            	}
        }

        return lstRespuesta;
    }

    /**
     * @description Clase que representa una solicitud de oportunidad o lead con los filtros correspondientes.
     */
    public class Request {
        @InvocableVariable public String tipoDocumento;
        @InvocableVariable public String numeroDocumento;
        @InvocableVariable public String numeroTelefono;
        @InvocableVariable public String nombreProyecto;
    }

    /**
     * @description Clase que representa la respuesta con los detalles de la oportunidad o lead que cumple con los filtros.
     */
    public class Response {
        @InvocableVariable public String opportunityId;
        @InvocableVariable public String leadId;
        @InvocableVariable public String foundType;
        @InvocableVariable public String ownerId;
        @InvocableVariable public String ownerName;
        @InvocableVariable public String nameMenu;
        @InvocableVariable public Boolean isNew;
    }
}