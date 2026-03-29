public class ONI_ValidadorArchivosOportunidad_cls {
    public class RequisitoArchivo {
        public String palabraClave;
        public Set<String> extensiones;
        
        public RequisitoArchivo(String palabra, Set<String> exts) {
            this.palabraClave = palabra;
            this.extensiones = exts;
        }
    }

    public class ConfiguracionTipo {
        public String campoObjetivo;
        public Boolean esLogicaAnd; 
        public List<RequisitoArchivo> requisitos;

        public ConfiguracionTipo(String campo, Boolean esAnd, List<RequisitoArchivo> reqs) {
            this.campoObjetivo = campo;
            this.esLogicaAnd = esAnd;
            this.requisitos = reqs;
        }
    }

    private static final Map<String, ConfiguracionTipo> MAPA_CONFIGURACION = new Map<String, ConfiguracionTipo>{
        'Oficinas' => new ConfiguracionTipo(
            'OFI_fld_Oportunidad_ArchivosOficinas__c',
            true, 
            new List<RequisitoArchivo>{
                new RequisitoArchivo('cartafianza', new Set<String>{'pdf'}),
                new RequisitoArchivo('contrato', new Set<String>{'pdf', 'docx'}),
                new RequisitoArchivo('actaentrega', new Set<String>{'pdf', 'docx'})
            }
        ),
        'Salas' => new ConfiguracionTipo(
            'OFI_fld_Oportunidad_ArchivosSalas__c',
            false, 
            new List<RequisitoArchivo>{
                new RequisitoArchivo('reserva', new Set<String>{'pdf', 'docx'})
            }
        ),
        'Industrial' => new ConfiguracionTipo(
            'IND_fld_Oportunidad_ArchivosIndustrial__c',
            true, 
            new List<RequisitoArchivo>{
                new RequisitoArchivo('constanciadepago', new Set<String>{'pdf', 'docx'}),
                new RequisitoArchivo('contratofirmado', new Set<String>{'pdf', 'docx'})
            }
        )
    };
    @future
    public static void validarOportunidadesAsync(Set<Id> idsOportunidades) {
        try {
            validarOportunidades(idsOportunidades);
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }
    public static void validarOportunidades(Set<Id> idsOportunidades) {        
        try {
            if (idsOportunidades.isEmpty()) return;
            List<Opportunity> oportunidades = [
                SELECT Id, Name, OFI_fld_Opportunity_TipoProducto__c, RecordType.Name,
                    IND_fld_Oportunidad_ArchivosIndustrial__c,
                    OFI_fld_Oportunidad_ArchivosSalas__c,
                    OFI_fld_Oportunidad_ArchivosOficinas__c,
                    (SELECT ContentDocument.Title, ContentDocument.FileExtension 
                        FROM ContentDocumentLinks)
                FROM Opportunity 
                WHERE Id IN :idsOportunidades
            ];

            List<Opportunity> oportunidadesParaActualizar = new List<Opportunity>();

            for (Opportunity oportunidad : oportunidades) {

                Set<String> archivosNormalizados = obtenerArchivosNormalizados(oportunidad.ContentDocumentLinks);                
                Boolean huboCambio = false;
                
                String claveTipoActual = '';
                if (oportunidad.OFI_fld_Opportunity_TipoProducto__c == 'Oficinas') {
                    claveTipoActual = 'Oficinas';
                } else if (oportunidad.OFI_fld_Opportunity_TipoProducto__c == 'Salas') {
                    claveTipoActual = 'Salas';
                } else if (oportunidad.RecordType.Name == 'IND_Industrial') {
                    claveTipoActual = 'Industrial';
                }

                for (String key : MAPA_CONFIGURACION.keySet()) {
                    ConfiguracionTipo config = MAPA_CONFIGURACION.get(key);
                    Boolean cumpleRequisitos = false;

                    if (key == claveTipoActual)
                        cumpleRequisitos = evaluarListaRequisitos(archivosNormalizados, config);
                    
                    Object valorActualObj = oportunidad.get(config.campoObjetivo);
                    Boolean valorActual = (valorActualObj != null) ? (Boolean)valorActualObj : false;

                    if (valorActual != cumpleRequisitos) {
                        oportunidad.put(config.campoObjetivo, cumpleRequisitos);
                        huboCambio = true;
                    }
                }

                if (huboCambio)
                    oportunidadesParaActualizar.add(oportunidad);
            }

            if (!oportunidadesParaActualizar.isEmpty())
                update oportunidadesParaActualizar;
        } catch (Exception e) {
            System.debug('!!! EXCEPCION CONTROLADA !!!');
            System.debug('Mensaje: ' + e.getMessage());
            System.debug('Traza: ' + e.getStackTraceString());
        }
    }

    private static Set<String> obtenerArchivosNormalizados(List<ContentDocumentLink> links) {
        Set<String> archivos = new Set<String>();
        if (links != null) {
            for (ContentDocumentLink enlace : links) {
                String nombreNormalizado = normalizarTexto(enlace.ContentDocument.Title);
                String extension = enlace.ContentDocument.FileExtension != null ? enlace.ContentDocument.FileExtension.toLowerCase() : '';
                archivos.add(nombreNormalizado + '.' + extension);
            }
        }
        return archivos;
    }

    private static Boolean evaluarListaRequisitos(Set<String> archivos, ConfiguracionTipo config) {
        Boolean resultado = config.esLogicaAnd ? true : false; 

        for (RequisitoArchivo req : config.requisitos) {
            Boolean archivoEncontrado = verificarArchivoIndividual(archivos, req.palabraClave, req.extensiones);

            if (config.esLogicaAnd) {
                if (!archivoEncontrado) return false; 
            } else {
                if (archivoEncontrado) return true; 
            }
        }
        return resultado;
    }

    private static String normalizarTexto(String textoEntrada) {
        if (textoEntrada == null) return '';
        String resultado = textoEntrada.toLowerCase();
        resultado = resultado.replace('á', 'a');
        resultado = resultado.replace('é', 'e');
        resultado = resultado.replace('í', 'i');
        resultado = resultado.replace('ó', 'o');
        resultado = resultado.replace('ú', 'u');
        return resultado.replaceAll('[^a-z0-9]', '');
    }

    private static Boolean verificarArchivoIndividual(Set<String> archivos, String palabraClave, Set<String> extensionesValidas) {
        for (String archivo : archivos) {
            for (String ext : extensionesValidas) {
                if (archivo.contains(palabraClave) && archivo.endsWith('.' + ext)) {
                    return true;
                }
            }
        }
        return false;
    }
}