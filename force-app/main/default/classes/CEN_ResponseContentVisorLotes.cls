public class CEN_ResponseContentVisorLotes {
    	public String Idhistlote;
        @AuraEnabled
        public String Idlote {get;set;}
        public String Feciniciovigencia;
        public String Fecfinvigencia;
    	@AuraEnabled
        public String Codlote {get;set;}
    	@AuraEnabled
        public String Idproyecto {get;set;}
        public String Codcompania;
    	@AuraEnabled
        public String Descripcioncorta;
    	@AuraEnabled
        public String Descripcionlote {get;set;}
        public String Tipoinmueble;
        public String Usoinmueble;
        public String Fecingresonotaria;
        public String Numeroficharegistral;
    	@AuraEnabled
        public String Manzana {get;set;}
    	@AuraEnabled
        public String Codestadolote {get;set;}
        public String Codsituacionlote;
        public String Codestadoentrega;
        public String Fecingreso;
        public String Fecventa;
        public String Fecentrega;
        public String Fecdescargo;
    	@AuraEnabled
        public Double Area {get;set;}
        public String Medidafrente;
        public String Medidafondo;
        public String Medidaderecha;
        public String Medidaizquierda;
        public String Linderofrente;
        public String Linderofondo;
        public String Linderoizquierda;
        public String Linderoderecha;
    	@AuraEnabled
        public Double Precioventafun {get;set;}
        public String Precioventaext;
    	@AuraEnabled
        public Double Precioventam2fun {get;set;}
    	@AuraEnabled
        public String Precioventam2ext {get;set;}
        public String Preciocostofun;
    	@AuraEnabled
        public String Preciocostom2fun {get;set;}
        public String Valorhipoteca;
        public String Numerokardex;
        public String Codnotaria;
        public String Cuentacontablecosto;
        public String Codcarga;
        public String Creadopor;
        public String Modificadopor;
        public String Fechacreacion;
        public String Fechaactualizacion;
        public String FillerStr01;
    	@AuraEnabled
        public String FillerStr02 {get;set;}
        public String FillerStr03;
        public String FillerStr04;
        public String FillerStr05;
        public String FillerNum01;
        public String FillerNum02;
        public String FillerNum03;
        public String FillerNum04;
        public String FillerNum05;
        public String FillerDt01;
        public String FillerDt02;
        public String FillerDt03;
        public String FillerDt04;
        public String FillerDt05;
        @AuraEnabled
        public String Codmonedafuncional {get;set;}
        @AuraEnabled
        public String Codmonedafuncional2 {get;set;}
        public String Codmonedaext;
        @AuraEnabled
        public String Numeroletra {get;set;}
        @AuraEnabled
        public String Proforma {get;set;}
        @AuraEnabled
        public String Bimoneda {get;set;}
        @AuraEnabled
        public String Precioventafuncional2 {get;set;}
        @AuraEnabled
        public Double PrecioOriginal {get;set;}
        @AuraEnabled
        public String MonedaOriginal {get;set;}
    public static CEN_ResponseContentVisorLotes parseFromXMLitem(Dom.XmlNode item){
        Decimal precioventam2fun_calculated = 0.00;
        CEN_ResponseContentVisorLotes newlote = new CEN_ResponseContentVisorLotes();
        //newlote.Idhistlote=item.getChildElement('Idhistlote',null).getText();
        newlote.Idlote=item.getChildElement('Idlote',null).getText();
        newlote.Feciniciovigencia=item.getChildElement('Feciniciovigencia',null).getText();
        newlote.Fecfinvigencia=item.getChildElement('Fecfinvigencia',null).getText();
        newlote.Codlote=String.valueOf(Integer.valueOf(item.getChildElement('Codlote',null).getText()));
        newlote.Idproyecto=item.getChildElement('Idproyecto',null).getText();
        newlote.Codcompania=item.getChildElement('Codcompania',null).getText();
        newlote.Descripcioncorta=item.getChildElement('Descripcioncorta',null).getText();
        newlote.Descripcionlote=item.getChildElement('Descripcionlote',null).getText();
        newlote.Tipoinmueble=item.getChildElement('Tipoinmueble',null).getText();
        newlote.Usoinmueble=item.getChildElement('Usoinmueble',null).getText();
        newlote.Fecingresonotaria=item.getChildElement('Fecingresonotaria',null).getText();
        newlote.Numeroficharegistral=item.getChildElement('Numeroficharegistral',null).getText();
        newlote.Manzana=item.getChildElement('Manzana',null).getText();
        newlote.Codestadolote=item.getChildElement('Codestadolote',null).getText();
        newlote.Codsituacionlote=item.getChildElement('Codsituacionlote',null).getText();
        newlote.Codestadoentrega=item.getChildElement('Codestadoentrega',null).getText();
        newlote.Fecingreso=item.getChildElement('Fecingreso',null).getText();
        newlote.Fecventa=item.getChildElement('Fecventa',null).getText();
        newlote.Fecentrega=item.getChildElement('Fecentrega',null).getText();
        newlote.Fecdescargo=item.getChildElement('Fecdescargo',null).getText();
        
        newlote.Area=Double.valueOf(item.getChildElement('Area',null).getText());
        newlote.Medidafrente=item.getChildElement('Medidafrente',null).getText();
        newlote.Medidafondo=item.getChildElement('Medidafondo',null).getText();
        newlote.Medidaderecha=item.getChildElement('Medidaderecha',null).getText();
        newlote.Medidaizquierda=item.getChildElement('Medidaizquierda',null).getText();
        newlote.Linderofrente=item.getChildElement('Linderofrente',null).getText();
        newlote.Linderofondo=item.getChildElement('Linderofondo',null).getText();
        newlote.Linderoizquierda=item.getChildElement('Linderoizquierda',null).getText();
        newlote.Linderoderecha=item.getChildElement('Linderoderecha',null).getText();
        newlote.Precioventafun= Double.valueOf(item.getChildElement('Precioventafun',null).getText());
        newlote.Numerokardex=item.getChildElement('Numerokardex',null).getText();
    
        newlote.Fechacreacion=item.getChildElement('Fechacreacion',null).getText();
        newlote.Fechaactualizacion=item.getChildElement('Fechaactualizacion',null).getText();
        newlote.FillerStr01=item.getChildElement('FillerStr01',null).getText();
        newlote.Codmonedafuncional=item.getChildElement('Codmonedafuncional',null).getText();
        newlote.Codmonedafuncional2=item.getChildElement('Codmonedafuncional2',null).getText();
        newlote.Codmonedaext=item.getChildElement('Codmonedaext',null).getText();
        newlote.FillerNum01=item.getChildElement('FillerNum01',null).getText();
        newlote.FillerDt01=item.getChildElement('FillerDt01',null).getText();
        newlote.Numeroletra=item.getChildElement('Numeroletra',null).getText();
        newlote.Proforma=item.getChildElement('Proforma',null).getText();
        newlote.Bimoneda=item.getChildElement('Bimoneda',null).getText();
        newlote.Precioventafuncional2= item.getChildElement('Precioventafuncional2',null).getText();
        if((newlote.Area==null||newlote.Area==0)){
           precioventam2fun_calculated=Decimal.valueOf(newlote.Precioventafun);
        }else{
            precioventam2fun_calculated=Decimal.valueOf(newlote.Precioventafun/newlote.Area);
        }
        newlote.Precioventam2fun = Double.valueOf(precioventam2fun_calculated.setScale(2));
        newlote.FillerStr02=item.getChildElement('FillerStr02',null).getText();
        newlote.PrecioOriginal = newlote.Precioventafun;
        newlote.MonedaOriginal = newlote.Codmonedafuncional;

        // newlote.Bimoneda = newlote.Codlote=='840034487' ? 'X' : ''; //PRUEBAS BIMONEDA
        // newlote.Precioventafuncional2 = newlote.Codlote=='840034487' ? '37500' : ''; //PRUEBAS BIMONEDA
        // newlote.Codmonedafuncional2 = newlote.Codlote=='840034487' ? 'USD' : ''; //PRUEBAS BIMONEDA
        
        /*
            newlote.Precioventaext=item.getChildElement('Precioventaext',null).getText();
            newlote.Precioventam2fun=item.getChildElement('Precioventam2fun',null).getText();
            newlote.Precioventam2ext=item.getChildElement('Precioventam2ext',null).getText();
            newlote.Preciocostofun=item.getChildElement('Preciocostofun',null).getText();
            newlote.Preciocostom2fun=item.getChildElement('Preciocostom2fun',null).getText();
            newlote.Valorhipoteca=item.getChildElement('Valorhipoteca',null).getText();            
            newlote.Codnotaria=item.getChildElement('Codnotaria',null).getText();
            newlote.Cuentacontablecosto=item.getChildElement('Cuentacontablecosto',null).getText();
            newlote.Codcarga=item.getChildElement('Codcarga',null).getText();
            newlote.Creadopor=item.getChildElement('Creadopor',null).getText();
            newlote.Modificadopor=item.getChildElement('Modificadopor',null).getText();*/
                    
        /*
            newlote.FillerStr03=item.getChildElement('FillerStr03',null).getText();
            newlote.FillerStr04=item.getChildElement('FillerStr04',null).getText();
            newlote.FillerStr05=item.getChildElement('FillerStr05',null).getText();*/
           
         /*newlote.FillerNum02=item.getChildElement('FillerNum02',null).getText();
            newlote.FillerNum03=item.getChildElement('FillerNum03',null).getText();
            newlote.FillerNum04=item.getChildElement('FillerNum04',null).getText();
            newlote.FillerNum05=item.getChildElement('FillerNum05',null).getText();*/
           
        /*
            newlote.FillerDt02=item.getChildElement('FillerDt02',null).getText();
            newlote.FillerDt03=item.getChildElement('FillerDt03',null).getText();
            newlote.FillerDt04=item.getChildElement('FillerDt04',null).getText();
            newlote.FillerDt05=item.getChildElement('FillerDt05',null).getText();
		*/
            
        return newlote;
    }
}