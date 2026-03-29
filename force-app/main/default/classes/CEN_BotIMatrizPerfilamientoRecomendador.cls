public with sharing class CEN_BotIMatrizPerfilamientoRecomendador {

    /**
     * @description Método invocable que obtiene proyectos basados en filtros específicos de metraje, cuota, zona y perfil.
     * @param input Lista de requests, que debe contener un solo elemento con los filtros requeridos.
     * @return Lista de listas de respuestas con los proyectos filtrados.
     */
    @InvocableMethod(label='Obtener proyectos recomendados por metraje, cuota, zona y perfil' description='Obtiene los proyectos que coinciden con los filtros de metraje, cuota, zona y perfil')
    public static List<List<Response>> getRecommendedProjectsByFilters(List<Request> input) {

        if (input == null || input.size() != 1) {
            return null;  // Verificación de entrada válida
        }
        Request req = input[0];
        List<List<Response>> lstRespuesta = new List<List<Response>>();
        List<Response> menu = new List<Response>();

        // Verificación de filtros de metraje y cuota
        if (String.isNotBlank(req.cuotaRango) && String.isNotBlank(req.zona)) {
            String cuotaRango = String.escapeSingleQuotes(req.cuotaRango);
			Integer vCountProjects = 0;
            // Comparación de cuota con evaluación de zona y cuota mínima
            List<String> cuotaValores = cuotaRango.replace('S/', '').replace('Menor a','1 - ').replace('a más',' - 999999').split('-');
            Decimal cuotaMin = Decimal.valueOf(cuotaValores[0].trim());
            Decimal cuotaMax = Decimal.valueOf(cuotaValores[1].trim());
            if (cuotaMax==999999){
                cuotaMin = 0;
            }

            String query = 'SELECT Id, CEN_NombreProyecto__c, CEN_Region__c,CEN_ZonaGrupo__c, CEN_CuotaMinima__c,CEN_NombreProyectoLista__c,CEN_NombreProyectoHomologado__c,CEN_ZonaHomologada__c ' +
                           'FROM CEN_MatrizPerfilamiento__c ' +
                           'WHERE CEN_ZonaGrupo__c = \'' + String.escapeSingleQuotes(req.zona) + '\' ' +
                           'AND RecordType.DeveloperName = \'CEN_MatrizPerfilamientoProyecto\' ORDER BY CEN_PrioridadTotal__c ASC';

            List<CEN_MatrizPerfilamiento__c> projects = Database.query(query);

            for (CEN_MatrizPerfilamiento__c project : projects) {
                Decimal cuotaProyecto = null;

                // Verificar que el campo de cuota mínima tenga un valor válido
                if (String.isNotBlank(project.CEN_CuotaMinima__c)) {
                    try {
                        String cuotaLimpia = project.CEN_CuotaMinima__c.replace('S/', '').replace(',', '').trim();
                        cuotaProyecto = Decimal.valueOf(cuotaLimpia);
                    } catch (Exception e) {
                        System.debug('Error al convertir la cuota mínima: ' + project.CEN_CuotaMinima__c);
                        continue;
                    }
                } else {
                    continue;
                }

                // Filtrar solo por el rango de cuota y zona ingresada
                // 1450 >= 1 && 1450 <= 1400
                if (cuotaProyecto <= cuotaMax) {
                    vCountProjects = vCountProjects + 1;
                    Response res = new Response();
                    res.name = project.CEN_NombreProyecto__c;
                    res.nombreProyecto = project.CEN_NombreProyecto__c;
                    res.nombreProyectoLista = project.CEN_NombreProyectoLista__c;
                    res.nombreProyectoHomologado = project.CEN_NombreProyectoHomologado__c;
                    res.zonaHomologada = project.CEN_ZonaHomologada__c;
                    res.zona = project.CEN_ZonaGrupo__c;
                    res.code = project.Id;
                    res.rangosCuota = project.CEN_CuotaMinima__c;
                    menu.add(res);
                } 
            }
            
            if (vCountProjects == 0)
            {
                 String vquery = 'SELECT Id, CEN_NombreProyecto__c, CEN_Region__c,CEN_ZonaGrupo__c, CEN_CuotaMinima__c,CEN_NombreProyectoLista__c,CEN_NombreProyectoHomologado__c,CEN_ZonaHomologada__c ' +
                           'FROM CEN_MatrizPerfilamiento__c ' +
                           'WHERE CEN_ZonaGrupo__c = \'' + String.escapeSingleQuotes(req.zona) + '\' ' +
                           'AND RecordType.DeveloperName = \'CEN_MatrizPerfilamientoProyecto\' ORDER BY CEN_CuotaMinima__c ASC LIMIT 1';

            	List<CEN_MatrizPerfilamiento__c> vprojects = Database.query(vquery);
                for (CEN_MatrizPerfilamiento__c project : vprojects) {
               		Response res = new Response();
                    res.name = project.CEN_NombreProyecto__c;
                    res.nombreProyecto = project.CEN_NombreProyecto__c;
                    res.nombreProyectoLista = project.CEN_NombreProyectoLista__c;
                    res.nombreProyectoHomologado = project.CEN_NombreProyectoHomologado__c;
                    res.zonaHomologada = project.CEN_ZonaHomologada__c;
                    res.zona = project.CEN_ZonaGrupo__c;
                    res.code = project.Id;
                    res.rangosCuota = project.CEN_CuotaMinima__c;
                    menu.add(res);
                }
            }
            
            
        }
        // Caso 3: Si se recibe 'zona' y 'perfil', se muestran los registros de perfil
        else if (String.isNotBlank(req.zona) && String.isNotBlank(req.perfil)) {
            String query = 'SELECT Id, Name, CEN_Region__c, CEN_ZonaGrupo__c, CEN_ReferenciaZona__c, CEN_NombreProyecto__c, CEN_RangosCuota__c, CEN_RangosInicial__c, CEN_RangosMetraje__c ' +
                           'FROM CEN_MatrizPerfilamiento__c ' +
                           'WHERE CEN_ZonaGrupo__c = \'' + String.escapeSingleQuotes(req.zona) + '\' ' +
                           'AND RecordType.DeveloperName = \'CEN_MatrizPerfilamientoZona\'';

            if (String.isNotBlank(req.proyecto)) {
                query += ' AND CEN_NombreProyecto__c = \'' + String.escapeSingleQuotes(req.proyecto) + '\' ';
            }

            List<CEN_MatrizPerfilamiento__c> registros = Database.query(query);

            for (CEN_MatrizPerfilamiento__c registro : registros) {
                Response res = new Response();
                res.name = registro.Name;
                res.zona = registro.CEN_ZonaGrupo__c;
                res.nombreProyecto = registro.CEN_NombreProyecto__c;
                res.referenciaZona = registro.CEN_ReferenciaZona__c;

                // Manejo del perfil: Metraje, Cuota o Inicial
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
                        multiRes.referenciaZona = res.referenciaZona;
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
     * @description Clase que representa una solicitud de proyecto con los filtros de metraje, cuota, zona y perfil.
     */
    public class Request {
        @InvocableVariable public String metrajeRango;
        @InvocableVariable public String cuotaRango;
        @InvocableVariable public String perfil;
        @InvocableVariable public String zona;
        @InvocableVariable public String proyecto;
    }

    /**
     * @description Clase que representa la respuesta con los detalles de los proyectos recomendados que cumplen los filtros.
     */
    public class Response {
        @InvocableVariable public String name;
        @InvocableVariable public String code;
        @InvocableVariable public String nombreProyecto; 
        @InvocableVariable public String nombreProyectoLista;
        @InvocableVariable public String nombreProyectoHomologado;
        @InvocableVariable public String rangosCuota;
        @InvocableVariable public String rangosInicial;
        @InvocableVariable public String rangosMetraje;
        @InvocableVariable public String zona;
        @InvocableVariable public String zonaHomologada;
        @InvocableVariable public String referenciaZona;
    }
}