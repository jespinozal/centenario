/**
 * @description       :
 * @author            : @nttdata.com
 * @group             :
 * @last modified on  : 10-09-2024
 * @last modified by  : @nttdata.com
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   10-09-2024  @nttdata.com  Initial Version
**/
public with sharing class CEN_ReferidoResponse {
    @AuraEnabled
    public String mensaje {get;set;}
    @AuraEnabled
    public Data[] data {get;set;}

    public class Data{
        public String referente;
        public String referido;
        public String aprobado;
        public String estado;
        //public Date fecCventaEnte;
        public String fecCventaEnte;
        public Decimal precioVentaEnte;
        public String ciudadEnte;
        public String proformaEnte;
        public Integer deudaEnte;
        //public Date fechaArrasEnte;
        public String fechaArrasEnte;
        public String resueltoEnte;
        public String observacionEnte;
        //public Date fecCventaIdo;
        public String fecCventaIdo;
        public Decimal precioVentaIdo;
        public String ciudadIdo;
        public String proformaIdo;
        //public Date fechaArrasIdo;
        public String fechaArrasIdo;
        public String observacionIdo;
    }
}