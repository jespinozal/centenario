/**
 * @description       :
 * @author            : @nttdata.com
 * @group             :
 * @last modified on  : 10-29-2024
 * @last modified by  : Richard Villafana - NTT DATA
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   14-08-2024   @nttdata.com  Initial Version
**/
@RestResource(urlMapping='/referidoApp/*')
global class CEN_ReferidoAppServices_cls {
    @HttpGet
    global static response doGet(){
        RestRequest req = RestContext.request;
        String documentoReferente = req.params.get('documentoReferente');

        List<CEN_MensajeReferido__mdt> mensajesReferido = [SELECT Id,
            CEN_EstadosLeadOpportunity__c,
            CEN_EstadoReferidoCaso__c,
            CEN_SubEstado__c,
            //CEN_MensajeApp__c,
            CEN_EstadoOrden__c,
            CEN_Valido__c
            FROM CEN_MensajeReferido__mdt
        ];

        Map<String, Decimal> mapEstadosCheck = new Map<String, Decimal>();
        Map<String, Boolean> mapEstadosValidos = new Map<String, Boolean>();

        for(CEN_MensajeReferido__mdt mr : mensajesReferido){
            mapEstadosCheck.put(mr.CEN_EstadosLeadOpportunity__c + mr.CEN_EstadoReferidoCaso__c, mr.CEN_EstadoOrden__c);
            mapEstadosValidos.put(mr.CEN_EstadosLeadOpportunity__c + mr.CEN_EstadoReferidoCaso__c, mr.CEN_Valido__c);
        }

        List<CEN_EstadoReferido__mdt> estadosReferido = [SELECT Id,
            CEN_Orden__c,
            CEN_Estado__c,
            CEN_Valido__c
            FROM CEN_EstadoReferido__mdt
        ];

        Map<String, Decimal> mapMensajeOrden = new Map<String, Decimal>();
        for(CEN_EstadoReferido__mdt er: estadosReferido){
            mapMensajeOrden.put(er.CEN_Estado__c,er.CEN_Orden__c);
        }

        List<Case> lstCase = [SELECT CaseNumber,
            Origin,
            subject,
            Status,
            N_mero_de_documento__c,
            LeadId__r.CEN_N_mero_de_documento__c,
            Account.CEN_Numero_de_documento_del__c, 
            Account.CEN_N_mero_de_documento__pc,
            CEN_Bonificacion__c,
            CEN_MensajeApp__c,
            Description,
            LeadId__r.Status,
            Opportunity__r.stagename,
            CreatedDate
            FROM Case
            WHERE (Account__r.CEN_N_mero_de_documento__pc=:documentoReferente OR Account__r.CEN_Numero_de_documento_del__c=:documentoReferente)
            AND Status !='No Válido'
            AND Origin = 'Referidos'
        ];

        Response resp = new Response();
        List<Referido> listaReferido = new List<Referido>();
        Decimal montoPremio = 0;

        for(Case c : lstCase){
            List<Estado> listaEstados = new List<Estado>();
            List<Estado> listaEstadosNoValidos = new List<Estado>();
            Referido refe = new Referido();
            refe.numeroCaso = c.CaseNumber;
            refe.origen = c.Origin;
            refe.estado = c.Status;
            refe.asunto = c.subject;
            refe.referido = c.LeadId__r.CEN_N_mero_de_documento__c!=null?c.LeadId__r.CEN_N_mero_de_documento__c:(c.Account.CEN_Numero_de_documento_del__c!=null?c.Account.CEN_Numero_de_documento_del__c:c.Account.CEN_N_mero_de_documento__pc);
            refe.bonificacion = c.CEN_Bonificacion__c;
            String estadoSeguimiento = c.Opportunity__r.stagename == null  ? c.LeadId__r.Status: c.Opportunity__r.stagename;
            //refe.estadoLead = c.LeadId__r.Status;
            //refe.etapaOportunidad = c.Opportunity__r.stagename;
            //refe.subEstadoOportunidad = c.Opportunity__r.CEN_SubEstadoCierreGanada__c;
            montoPremio = montoPremioValido(c.Status, c.CreatedDate.date()) ? montoPremio + c.CEN_Bonificacion__c : montoPremio; //AGREGAR LOGICA DE CAMPAÑA
            //montoPremio = montoPremio + c.CEN_Bonificacion__c;
            System.debug('estadoSeguimiento: ' + estadoSeguimiento);
            System.debug('c.Status: ' + c.Status);
            Boolean estadoValido = mapEstadosValidos.get(estadoSeguimiento + c.Status);
            System.debug('estadoValido: ' + estadoValido);
            for(CEN_EstadoReferido__mdt er: estadosReferido){
                Estado est = new Estado();
                if(estadoValido!=null && estadoValido){ //REVISAR ERROR CUANDO EL LEAD SE CONVIERTE Y EL CASO ESTA COMO NO VALIDO
                    if(er.CEN_Valido__c){
                        est.orden = er.CEN_Orden__c;
                        est.estado = er.CEN_Estado__c;
                        est.valor = er.CEN_Orden__c <= mapEstadosCheck.get(estadoSeguimiento + refe.estado) ? true : false;
                        listaEstados.add(est);
                    }
                }else{
                    if(mapEstadosCheck.get(estadoSeguimiento + refe.estado) == er.CEN_Orden__c){
                        est.orden = er.CEN_Orden__c;
                        est.estado = er.CEN_Estado__c;
                        est.valor = true;
                        listaEstados.add(est);
                    }
                }
            }
            refe.estados = listaEstados;
            refe.fecha = c.CreatedDate;
            if(estadoValido!=null)listaReferido.add(refe);
        }

        resp.totalRegistros = listaReferido.size();
        resp.montoPremio = montoPremio;
        resp.referidos = listaReferido;

        return resp;
    }

    public static Boolean montoPremioValido(String estado, Date fecha){
        //List<String> estadosNoValidos = new List<String>{'No Válido','Premio Perdido','Referido no compró'};
        List<String> estadosValidos = new List<String>{'Premiado'};
        //return !estadosNoValidos.contains(estado) && campaniaVigente(fecha);
        return estadosValidos.contains(estado) && campaniaVigente(fecha);
    }

    public static Boolean campaniaVigente(Date fecha){
        List<CEN_PlazoVigencia__c> campaniaVigente =    [
                                                            SELECT Id,CEN_FechaInicio__c,CEN_FechaFin__c
                                                            FROM CEN_PlazoVigencia__c
                                                            WHERE CEN_ActivoVigente__c = true AND CEN_Tipo__c = 'Campaña'
                                                            AND (CEN_FechaInicio__c <=: fecha AND CEN_FechaFin__c >=: fecha)
                                                        ];
        return campaniaVigente.size()>0;
    }

    global class Response {
        private List<Referido> referidos {get;set;}
        private Integer totalRegistros {get;set;}
        private Decimal montoPremio {get;set;}
    }

    global class Referido {
        private String numeroCaso {get;set;}
        private String origen {get;set;}
        private String estado {get;set;}
        private String asunto {get;set;}
        private String referido {get;set;}
        private Decimal bonificacion {get;set;}
        //private String estadoSeguimiento {get;set;}
        //private String estadoLead {get;set;}
        //private String etapaOportunidad {get;set;}
        //private String subEstadoOportunidad {get;set;}
        private List<Estado> estados {get;set;}
        private Datetime fecha {get;set;}
    }

    global class Estado {
        private Decimal orden {get;set;}
        private String estado {get;set;}
        private Boolean valor {get;set;}
    }

}