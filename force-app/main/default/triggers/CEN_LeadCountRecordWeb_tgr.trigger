/**
 * @description       : 
 * @author            : Richard Villafana - NTT DATA
 * @group             : 
 * @last modified on  : 10-31-2024
 * @last modified by  : Richard Villafana - NTT DATA
**/
trigger CEN_LeadCountRecordWeb_tgr on Lead (before insert) {
Integer Nrec;
Integer NrecReferido;
DateTime dT = DateTime.Now();
Datetime dt2 = date.newinstance(dT.year(), dT.month(),1);
   
//AggregateResult[] LeadResult=[Select CEN_Web__c, count(Id) Nrecord from Lead where CEN_Web__c='Macropolis' and CreatedDate=LAST_N_DAYS:30 group by CEN_Web__c];       

AggregateResult[] LeadResult=[Select CEN_Web__c, count(Id) Nrecord from Lead where CEN_Web__c='Macropolis' and CreatedDate>=:dt2 group by CEN_Web__c];  
//Query de Referidos de Medio Propietario
AggregateResult[] LeadResultReferidos=[Select LeadSource, count(Id) Nrecord from Lead where LeadSource='Referidos' and CEN_Medio__c='0013' group by LeadSource];       
    
    if(LeadResultReferidos != null && LeadResultReferidos.size() > 0){ NrecReferido=integer.valueOf(LeadResultReferidos[0].get('Nrecord'));
      System.debug('Numero registro Referido y Medio Propietario: '+NrecReferido);    
    }else{
      NrecReferido=0;
    }

    if(LeadResult != null && LeadResult.size() > 0){ Nrec=integer.valueOf(LeadResult[0].get('Nrecord'));
        System.debug('Numero registro: '+Nrec);    

    }else{
        
        Nrec=0;
    }
    
  for(Lead l : Trigger.New) {
      if(l.LeadSource == 'Referidos' && l.CEN_Medio__c=='0013'){ NrecReferido=NrecReferido+1;
        l.CEN_ContadorReferidos__c = NrecReferido;   
      }
      
      if(l.CEN_Web__c=='Macropolis'){
        Nrec=Nrec+1;
        l.CEN_ItemCaseLead__c = Nrec;           
          
      }

    }   
    
}