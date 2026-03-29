public class dataTableCtrl{
    @AuraEnabled 
    public static ListWrapper fetchAccountWrapper(string Idproyecto){     
        ListWrapper obj =  new ListWrapper();
        try{
            obj.getlotes  = CEN_ConsultVisorLotes.ByProyect(Idproyecto);
        }catch(Exception ex){
            obj.getlotes = new List<CEN_ResponseContentVisorLotes>();
            System.debug('CEN Consult Visor Lotes error: '+ ex.getMessage() + '. Line: '+ex.getLineNumber());
        }

        if(obj.getlotes.size()>0){
            obj.tamanioMax=obj.getlotes[0].Area;
            obj.tamanioMin = obj.getlotes[0].Area;
            obj.precioMax = obj.getlotes[0].Precioventafun;
            obj.precioMin = obj.getlotes[0].Precioventafun;    
            
            for(CEN_ResponseContentVisorLotes lst:obj.getlotes){
                    
                if(obj.tamanioMax<lst.Area){
                    obj.tamanioMax=lst.Area;
                }
                if(obj.tamanioMin>lst.Area){
                    obj.tamanioMin=lst.Area;
                }
                if(obj.precioMax<lst.Precioventafun){
                    obj.precioMax=lst.Precioventafun;
                }
                if(obj.precioMin>lst.Precioventafun){
                    obj.precioMin=lst.Precioventafun;
                }
                lst.Codestadolote = cambiarEstadoLote(lst.Codestadolote);
            }
            
            //	tratar valores a multiplos de 10
            obj.tamanioMax = Double.valueOf(roundMax(Integer.valueOf(obj.tamanioMax)));
            obj.tamanioMin = Double.valueOf(roundMin(Integer.valueOf(obj.tamanioMin)));
            obj.precioMax = Double.valueOf(roundMax(Integer.valueOf(obj.precioMax)));
            obj.precioMin = Double.valueOf(roundMin(Integer.valueOf(obj.precioMin)));
                        
            obj.estado = 'ok';
            obj.mensaje = 'todo ok';
            
        }else{ 
               System.debug('El proyecto no tiene lotes.');
            obj.estado = 'error';
            obj.mensaje = 'SAP: El proyecto no tiene lotes.';
        }
        return obj; 
    }
    
    private static Integer roundMax(Integer n){ 
        Integer sd = Integer.valueOf(n/10);
        sd = (sd + 1)*10;
        return sd;
    } 
     private static Integer roundMin(Integer n){ 
        Integer sd = Integer.valueOf(n/10);
        sd = (sd)*10;
        return sd;
    }
    
    /* wrapper class */  
    public class ListWrapper {
        @AuraEnabled public boolean isChecked {get;set;}
        //@AuraEnabled public  account objAccount{get;set;}
        @AuraEnabled public List<CEN_ResponseContentVisorLotes> getlotes {get;set;}
        @AuraEnabled public Double tamanioMax {get;set;}
        @AuraEnabled public Double tamanioMin {get;set;}
        @AuraEnabled public Double precioMax {get;set;}
        @AuraEnabled public Double precioMin {get;set;}
        @AuraEnabled public String mensaje {get;set;}
        @AuraEnabled public String estado {get;set;}
        /*public accountListWrapper(boolean isChecked, CEN_ResponseContentVisorLotes getlotes){
            this.isChecked = isChecked;
            this.objAccount = objAccount;
            this.getlotes = getlotes;
        }*/ 
    }
    
    private static String cambiarEstadoLote(String estadoLote){
        estadoLote = estadoLote.toUpperCase();
        switch on estadoLote{
            when 'E'{return 'Entregado';}
            when 'B'{return 'Borrado';}
            when 'L'{return 'Libre';}
            when 'Q'{return 'Bloqueado';}
            when 'C'{return 'Vendido';}
            when 'R'{return 'Reservado';}
            when else{return estadoLote;}
        }
    }

}