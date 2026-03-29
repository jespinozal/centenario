public with sharing class CEN_BotObtenerDatosMatriz {

    /**
     * @description Método invocable para obtener proyectos basados en filtros: zona, metraje, cuota o perfil.
     * @param input Lista de requests que contiene un solo elemento con los filtros especificados.
     * @return Lista de respuestas con los proyectos filtrados.
     */
    @InvocableMethod(label='Obtener datos de la matriz BOT' description='Obtiene los proyectos que coinciden con los filtros de zona, metraje, cuota o perfil')
    public static List<Response> getProjectsByFilters(List<Request> input) {

        List<Response> lstRpta = new List<Response>();

        // Validación de entrada
        if (input == null || input.size() != 1) {
            return null;
        }

        Request req = input[0];

        // Manejo del parámetro opcional 'option' del tipo Response de CEN_BotIMatrizPerfilamientoRecomendador
        CEN_BotIMatrizPerfilamientoRecomendador.Response option = req.option;

        if (option != null) {
            // Caso: Si solo se recibe 'option', devuelve el proyecto sin consulta adicional
            Response res = new Response();
            res.name = option.name;
            res.nombreProyecto = option.nombreProyecto; 
            res.nombreProyectoHomologado = option.nombreProyectoHomologado; 
            res.zona = option.zona;
            res.zonaHomologada = option.zonaHomologada;
            res.rangosCuota = option.rangosCuota;
            res.rangosInicial = option.rangosInicial;
            res.rangosMetraje = option.rangosMetraje;
            res.referenciaZona = option.referenciaZona;
            lstRpta.add(res);
            System.debug('Respuesta capturada del option: ' + lstRpta);
        } else {
            String zona = String.isNotBlank(req.zona) ? String.escapeSingleQuotes(req.zona) : null;
            String perfil = String.isNotBlank(req.perfil) ? String.escapeSingleQuotes(req.perfil) : null;

            // Lógica cuando están presentes tanto metraje como cuota
            if (String.isNotBlank(req.metrajeRango) && String.isNotBlank(req.cuotaRango)) {
                String metrajeRango = String.escapeSingleQuotes(req.metrajeRango);
                String cuotaRango = String.escapeSingleQuotes(req.cuotaRango);

                List<String> metrajeValores = metrajeRango.replace('m2', '').split('-');
                Decimal metrajeMin = Decimal.valueOf(metrajeValores[0].trim());
                Decimal metrajeMax = Decimal.valueOf(metrajeValores[1].trim());

                // Verifica si la cuota es igual a 0
                if (cuotaRango == '0') {
                    // Consulta cuando cuota es 0
                    String query = 'SELECT Id, CEN_NombreProyecto__c, CEN_MetrajeMinimo__c ' +
                                   'FROM CEN_MatrizPerfilamiento__c ' +
                                   'WHERE CEN_ZonaGrupo__c = \'' + zona + '\' ' +
                                   'AND RecordType.DeveloperName = \'CEN_MatrizPerfilamientoProyecto\'';

                    List<CEN_MatrizPerfilamiento__c> projects = Database.query(query);

                    for (CEN_MatrizPerfilamiento__c project : projects) {
                        Decimal metrajeProyecto = null;
                        if (String.isNotBlank(project.CEN_MetrajeMinimo__c)) {
                            try {
                                String metrajeLimpio = project.CEN_MetrajeMinimo__c.replace('m2', '').trim();
                                metrajeProyecto = Decimal.valueOf(metrajeLimpio);
                            } catch (Exception e) {
                                System.debug('Error al convertir el metraje mínimo: ' + project.CEN_MetrajeMinimo__c);
                                continue;
                            }
                        } else {
                            continue;
                        }

                        if (metrajeProyecto >= metrajeMin && metrajeProyecto <= metrajeMax) {
                            Response res = new Response();
                            res.name = project.CEN_NombreProyecto__c;
                            res.nombreProyecto = project.CEN_NombreProyecto__c;
                            res.zona = zona;
                            lstRpta.add(res);
                        }
                    }
                } else {
                    // Comparación de cuota y metraje
                    List<String> cuotaValores = cuotaRango.replace('S/', '').split('-');
                    Decimal cuotaMin = Decimal.valueOf(cuotaValores[0].trim());
                    Decimal cuotaMax = Decimal.valueOf(cuotaValores[1].trim());

                    String query = 'SELECT Id, CEN_NombreProyecto__c, CEN_CuotaMinima__c, CEN_MetrajeMinimo__c,CEN_ReferenciaZona__c ' +
                                   'FROM CEN_MatrizPerfilamiento__c ' +
                                   'WHERE CEN_ZonaGrupo__c = \'' + zona + '\' ' +
                                   'AND RecordType.DeveloperName = \'CEN_MatrizPerfilamientoProyecto\'';

                    List<CEN_MatrizPerfilamiento__c> projects = Database.query(query);

                    for (CEN_MatrizPerfilamiento__c project : projects) {
                        Decimal cuotaProyecto = null;
                        Decimal metrajeProyecto = null;

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

                        if (String.isNotBlank(project.CEN_MetrajeMinimo__c)) {
                            try {
                                String metrajeLimpio = project.CEN_MetrajeMinimo__c.replace('m2', '').trim();
                                metrajeProyecto = Decimal.valueOf(metrajeLimpio);
                            } catch (Exception e) {
                                System.debug('Error al convertir el metraje mínimo: ' + project.CEN_MetrajeMinimo__c);
                                continue;
                            }
                        } else {
                            continue;
                        }

                        if (cuotaProyecto >= cuotaMin && cuotaProyecto <= cuotaMax && 
                            metrajeProyecto >= metrajeMin && metrajeProyecto <= metrajeMax) {
                            Response res = new Response();
                            res.name = project.CEN_NombreProyecto__c;
                            res.nombreProyecto = project.CEN_NombreProyecto__c;
                            res.referenciaZona = project.CEN_ReferenciaZona__c;
                            res.zona = zona;
                            lstRpta.add(res);
                        }
                    }
                }
            } else if (String.isNotBlank(zona) && String.isNotBlank(perfil)) {
                // Caso 2: Solo se ingresa zona y perfil, muestra los registros de perfil
                String query = 'SELECT Id, Name, CEN_ZonaGrupo__c, CEN_NombreProyecto__c, CEN_RangosCuota__c, CEN_RangosInicial__c, CEN_RangosMetraje__c,CEN_ReferenciaZona__c ' +
                               'FROM CEN_MatrizPerfilamiento__c ' +
                               'WHERE CEN_ZonaGrupo__c = \'' + zona + '\'' +
                               'AND RecordType.DeveloperName = \'CEN_MatrizPerfilamientoProyecto\'' +
                               'LIMIT 1';

                List<CEN_MatrizPerfilamiento__c> registros = Database.query(query);

                for (CEN_MatrizPerfilamiento__c registro : registros) {
                    Response res = new Response();
                    res.name = registro.Name;
                    res.nombreProyecto = registro.CEN_NombreProyecto__c; 
                    res.zona = registro.CEN_ZonaGrupo__c;
                    res.referenciaZona = registro.CEN_ReferenciaZona__c;
                    lstRpta.add(res);

                    // Casos para los perfiles específicos (Metraje, Cuota e Inicial)
                    if (perfil == 'Metraje' && String.isNotBlank(registro.CEN_RangosMetraje__c)) {
                        List<String> valoresMetraje = registro.CEN_RangosMetraje__c.split(';');
                        for (String valor : valoresMetraje) {
                            Response multiRes = new Response();
                            multiRes.name = res.name;
                            multiRes.nombreProyecto = res.nombreProyecto;
                            multiRes.zona = res.zona;
                            multiRes.rangosMetraje = valor; 
                            lstRpta.add(multiRes);
                        }
                    }

                    if (perfil == 'Cuota' && String.isNotBlank(registro.CEN_RangosCuota__c)) {
                        List<String> valoresCuota = registro.CEN_RangosCuota__c.split(';');
                        for (String valor : valoresCuota) {
                            Response multiRes = new Response();
                            multiRes.name = res.name;
                            multiRes.nombreProyecto = res.nombreProyecto;
                            multiRes.zona = res.zona;
                            multiRes.rangosCuota = valor;  
                            lstRpta.add(multiRes);
                        }
                    }

                    if (perfil == 'Inicial' && String.isNotBlank(registro.CEN_RangosInicial__c)) {
                        List<String> valoresInicial = registro.CEN_RangosInicial__c.split(';');
                        for (String valor : valoresInicial) {
                            Response multiRes = new Response();
                            multiRes.name = res.name;
                            multiRes.nombreProyecto = res.nombreProyecto; 
                            multiRes.zona = res.zona;
                            multiRes.rangosInicial = valor; 
                            lstRpta.add(multiRes);
                        }
                    }
                }
            }
        }

        return lstRpta;
    }

    /**
     * @description Clase para el request, permite usar un objeto 'option' de tipo Response.
     */
    public class Request {
        @InvocableVariable public String zona;
        @InvocableVariable public String metrajeRango;
        @InvocableVariable public String cuotaRango;
        @InvocableVariable public String perfil;
        @InvocableVariable public CEN_BotIMatrizPerfilamientoRecomendador.Response option;
    }

    /**
     * @description Clase para la respuesta con los detalles del proyecto.
     */
    public class Response {
        @InvocableVariable public String name;
        @InvocableVariable public String zona;
        @InvocableVariable public String zonaHomologada; 
        @InvocableVariable public String nombreProyecto; 
        @InvocableVariable public String nombreProyectoHomologado; 
        @InvocableVariable public String rangosCuota;
        @InvocableVariable public String rangosInicial; 
        @InvocableVariable public String rangosMetraje;
        @InvocableVariable public String referenciaZona;
    }
}