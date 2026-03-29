/**
 * @name               : CEN_BotInfoMatrizPerfilamientoSecuencial
 * @author             : Jhanluck Onofre
 * @creation date      : 04/11/2024
 * @modification date  : 04/11/2024
 * @last modified by   : Jhanluck Onofre
**/
public with sharing class CEN_BotInfoMatrizPerfilamientoSecuencial {

    /**
     * @description Método invocable que obtiene proyectos basados en filtros específicos: promotional, region y perfil.
     * @param input Lista de requests, que debe contener un solo elemento con los filtros requeridos.
     * @return Lista de listas de respuestas con los proyectos filtrados.
     */
    @InvocableMethod(label='Obtener proyectos por filtros BOT Secuencial' description='Obtiene los proyectos que coinciden con los filtros de promotional, region y perfil')
    public static List<List<Response>> getProjectsByFilters(List<Request> input) {

        if (input == null || input.size() != 1) {
            return null;  // Verificación de entrada válida
        }
        Request req = input[0];
        List<List<Response>> lstRespuesta = new List<List<Response>>();
        List<Response> menu = new List<Response>();

        // Caso 1: Si solo se recibe 'promotional' como true
        if (req.promotional != null && req.promotional == true) {
            String query = 'SELECT Id, Name, CEN_ZonaGrupo__c, CEN_ReferenciaZona__c,CEN_NombreProyectoLista__c,CEN_NombreProyectoHomologado__c,CEN_ZonaHomologada__c, CEN_Region__c, CEN_NombreProyecto__c, CEN_RangosCuota__c, CEN_RangosInicial__c, CEN_RangosMetraje__c ' +
                           'FROM CEN_MatrizPerfilamiento__c ' +
                           'WHERE CEN_CampanaPromocional__c = true ' +
                           'AND RecordType.DeveloperName = \'CEN_MatrizPerfilamientoProyecto\' ORDER BY CEN_PrioridadTotal__c ASC';

            List<CEN_MatrizPerfilamiento__c> promotionalProjects = Database.query(query);

            for (CEN_MatrizPerfilamiento__c project : promotionalProjects) {
                Response res = new Response();
                res.name = project.Name;
                res.zona = project.CEN_ZonaGrupo__c;
                res.nombreProyecto = project.CEN_NombreProyecto__c;
                res.nombreProyectoLista = project.CEN_NombreProyectoLista__c;
                res.nombreProyectoHomologado = project.CEN_NombreProyectoHomologado__c;
                res.zonaHomologada = project.CEN_ZonaHomologada__c;
                res.rangosCuota = project.CEN_RangosCuota__c;
                res.rangosInicial = project.CEN_RangosInicial__c;
                res.rangosMetraje = project.CEN_RangosMetraje__c;
                menu.add(res);
            }
        } 
        // Caso 2: Si solo se recibe 'region', ejecuta la consulta con 'region' únicamente
        else if (String.isNotBlank(req.region) && String.isBlank(req.perfil)) {
            String query = 'SELECT Id, Name, CEN_ZonaGrupo__c, CEN_Region__c, CEN_NombreProyecto__c,CEN_NombreProyectoLista__c,CEN_NombreProyectoHomologado__c,CEN_ZonaHomologada__c,CEN_RangosCuota__c, CEN_RangosInicial__c, CEN_RangosMetraje__c ' +
                           'FROM CEN_MatrizPerfilamiento__c ' +
                           'WHERE CEN_Region__c = \'' + String.escapeSingleQuotes(req.region) + '\' ' +
                           'AND RecordType.DeveloperName = \'CEN_MatrizPerfilamientoProyecto\'';

            List<CEN_MatrizPerfilamiento__c> projects = Database.query(query);

            for (CEN_MatrizPerfilamiento__c project : projects) {
                Response res = new Response();
                res.name = project.Name;
                res.zona = project.CEN_ZonaGrupo__c;
                res.nombreProyecto = project.CEN_NombreProyecto__c;
                res.nombreProyectoLista = project.CEN_NombreProyectoLista__c;
                res.nombreProyectoHomologado = project.CEN_NombreProyectoHomologado__c;
                res.zonaHomologada = project.CEN_ZonaHomologada__c;
                res.rangosCuota = project.CEN_RangosCuota__c;
                res.rangosInicial = project.CEN_RangosInicial__c;
                res.rangosMetraje = project.CEN_RangosMetraje__c;
                menu.add(res);
            }
        }
        // Caso 3: Si se recibe 'region' y 'perfil', se muestran los registros de perfil
        else if (String.isNotBlank(req.region) && String.isNotBlank(req.perfil)) {
            String query = 'SELECT Id, Name, CEN_Region__c, CEN_ZonaGrupo__c, CEN_ReferenciaZona__c, CEN_NombreProyecto__c, CEN_RangosCuota__c, CEN_RangosInicial__c, CEN_RangosMetraje__c ' +
                           'FROM CEN_MatrizPerfilamiento__c ' +
                           'WHERE CEN_Region__c = \'' + String.escapeSingleQuotes(req.region) + '\' ' +
                           'AND RecordType.DeveloperName = \'CEN_MatrizPerfilamientoProyecto\'';

            if (String.isNotBlank(req.proyecto)) {
                query += ' AND CEN_NombreProyecto__c = \'' + String.escapeSingleQuotes(req.proyecto) + '\' ';
            }

            List<CEN_MatrizPerfilamiento__c> registros = Database.query(query);

            for (CEN_MatrizPerfilamiento__c registro : registros) {
                Response res = new Response();
                res.name = registro.Name;
                res.zona = registro.CEN_ZonaGrupo__c;
                res.nombreProyecto = registro.CEN_NombreProyecto__c;

                if (req.perfil == 'Metraje' && String.isNotBlank(registro.CEN_RangosMetraje__c)) {
                    List<String> valoresMetraje = registro.CEN_RangosMetraje__c.split(';');
                    for (String valor : valoresMetraje) {
                        Response multiRes = new Response();
                        multiRes.name = res.name;
                        multiRes.zona = res.zona;
                        multiRes.nombreProyecto = res.nombreProyecto;
                        multiRes.rangosMetraje = valor;
                        menu.add(multiRes);
                    }
                } else if (req.perfil == 'Cuota' && String.isNotBlank(registro.CEN_RangosCuota__c)) {
                    List<String> valoresCuota = registro.CEN_RangosCuota__c.split(';');
                    for (String valor : valoresCuota) {
                        Response multiRes = new Response();
                        multiRes.name = res.name;
                        multiRes.zona = res.zona;
                        multiRes.nombreProyecto = res.nombreProyecto;
                        multiRes.rangosCuota = (valor.trim() == '0') ? 'Ninguno' : valor;
                        menu.add(multiRes);
                    }
                } else if (req.perfil == 'Inicial' && String.isNotBlank(registro.CEN_RangosInicial__c)) {
                    List<String> valoresInicial = registro.CEN_RangosInicial__c.split(';');
                    for (String valor : valoresInicial) {
                        Response multiRes = new Response();
                        multiRes.name = res.name;
                        multiRes.zona = res.zona;
                        multiRes.nombreProyecto = res.nombreProyecto;
                        multiRes.rangosInicial = valor;
                        menu.add(multiRes);
                    }
                } else {
                    menu.add(res);
                }
            }
        }

        lstRespuesta.add(menu);
        return lstRespuesta;
    }

    /**
     * @description Clase que representa una solicitud de proyecto con los filtros correspondientes.
     */
    public class Request {
        @InvocableVariable public Boolean promotional;
        @InvocableVariable public String region;
        @InvocableVariable public String perfil;
        @InvocableVariable public String proyecto;
    }

    /**
     * @description Clase que representa la respuesta con los detalles de los proyectos que cumplen los filtros.
     */
    public class Response {
        @InvocableVariable public String name;
        @InvocableVariable public String code;
        @InvocableVariable public String zona;
        @InvocableVariable public String nombreProyecto;
        @InvocableVariable public String rangosCuota;
        @InvocableVariable public String rangosInicial;
        @InvocableVariable public String rangosMetraje;
        @InvocableVariable public String referenciaZona;
        @InvocableVariable public String nombreProyectoLista;
        @InvocableVariable public String nombreProyectoHomologado;
        @InvocableVariable public String zonaHomologada;
    }
}