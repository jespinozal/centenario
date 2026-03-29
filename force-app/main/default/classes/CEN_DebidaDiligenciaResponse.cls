/**
 * @description       :
 * @author            : @nttdata.com
 * @group             :
 * @last modified on  : 09-10-2023
 * @last modified by  : @nttdata.com
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   09-10-2023  @nttdata.com  Initial Version
**/
public with sharing class CEN_DebidaDiligenciaResponse {
    public String wDatetime;
    public String second_keyword;
    public String first_keyword;
    public Boolean exists_results;
    public Results[] results;
    public String wSystem;
    public String dni_ce;
    public String opportunity;
    public String user;

    public class Results {
        public String description;
        public String title;
        public String link;
    }
}