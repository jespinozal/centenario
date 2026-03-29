public class OFI_PdfPlantillaCotizador_Sala_cls {
    public Quote q;
    public Account acc;
    public List<QuoteLineItem> salas;

    public OFI_PdfPlantillaCotizador_Sala_cls(ApexPages.StandardController controller) {
      System.debug('Inicio');
      // Id recordId = ApexPages.currentPage().getParameters().get('Id');
      // System.debug(newId);
      Id recordId = controller.getRecord().Id;
      System.debug('1');
      System.debug(LoggingLevel.INFO, recordId);
      System.debug('2');

      q = [SELECT Id, CreatedDate, AccountId, IND_fld_Cotizacion_Condiciones__c, CEN_Precio_de_venta__c, CEN_Precio_de_venta_con_descuento__c, ONI_fld_Quote_Lead__c FROM Quote WHERE Id = :recordId];
      System.debug('3');

      List<Lead> leads;


      if (String.isBlank(q.ONI_fld_Quote_Lead__c)) {
        acc = [SELECT Id, Name FROM Account WHERE Id =: q.AccountId];
      }else{
        leads = [SELECT Name, Company FROM Lead WHERE Id = :q.ONI_fld_Quote_Lead__c LIMIT 1];
        
        if (!leads.isEmpty()) {
          Lead ld = leads[0];
          acc = new Account(
            Name = String.isNotBlank(ld.Company) ? ld.Company : ld.Name
          );
        } else {
          acc = new Account(Name = 'Cliente');
        }
      }


      // acc = [SELECT Id, Name FROM Account WHERE Id =: q.AccountId];






      salas = [SELECT Id, Product2Id, Product2.Name, OFI_fld_QLI_FechaHoraEvento__c, OFI_fld_QLI_FechaHoraFinEvento__c, OFI_fld_QLI_Asistentes__c, OFI_fld_QLI_Montaje__c, CEN_TotalPriceEspejo__c
      FROM QuoteLineItem WHERE QuoteId = :recordId ORDER BY LineNumber ASC];
    }

    public Quote getQuote() {
      System.debug(LoggingLevel.INFO, q);
      return this.q;
    }

    public Account getAccount() {
      System.debug(LoggingLevel.INFO, acc);
      return this.acc;
    }

    public List<QuoteLineItem> getSalas() {
      System.debug(LoggingLevel.INFO, salas);

      if (this.salas.isEmpty()) {
        return new List<QuoteLineItem>();
      }
      
      for(QuoteLineItem sala : this.salas){
        sala.OFI_fld_QLI_FechaHoraEvento__c = sala.OFI_fld_QLI_FechaHoraEvento__c.addHours(-5);
        sala.OFI_fld_QLI_FechaHoraFinEvento__c = sala.OFI_fld_QLI_FechaHoraFinEvento__c.addHours(-5);
      }
      return this.salas;
    }

    public List<Map<String,Object>> getCondiciones(){
        if (String.isBlank(q.IND_fld_Cotizacion_Condiciones__c)) {
            return new List<Map<String,Object>>();
        }
        
        List<Object> tempList = (List<Object>) JSON.deserializeUntyped(q.IND_fld_Cotizacion_Condiciones__c);
        List<Map<String,Object>> condiciones = new List<Map<String,Object>>();
        
        for (Object obj : tempList) {
            Map<String,Object> item = (Map<String,Object>) obj;
            
            // Format date from yyyy-MM-dd to dd/MM/yyyy
            String rDate = (String) item.get('rDate');
            if (String.isNotBlank(rDate) && rDate.contains('-')) {
                String[] dateParts = rDate.split('-');
                if (dateParts.size() == 3) {
                    item.put('rDate', dateParts[2] + '/' + dateParts[1] + '/' + dateParts[0]);
                }
            }
            
            // Format unitAmount as currency
            String unitAmount = (String) item.get('unitAmount');
            if (String.isNotBlank(unitAmount)) {
                try {
                    Decimal amount = Decimal.valueOf(unitAmount);
                    item.put('unitAmount', amount.format());
                } catch (Exception e) {
                    // Keep original value if conversion fails
                }
            }
            
            // Format totalAmount as currency
            String totalAmount = (String) item.get('totalAmount');
            if (String.isNotBlank(totalAmount)) {
                try {
                    Decimal amount = Decimal.valueOf(totalAmount);
                    item.put('totalAmount', amount.format());
                } catch (Exception e) {
                    // Keep original value if conversion fails
                }
            }
            
            condiciones.add(item);
        }
        
        return condiciones;
    }

    public Decimal getTotalAmount() {
        Decimal total = 0;
        List<Map<String,Object>> items = getCondiciones();
        for (Map<String,Object> item : items) {
            String totalAmountStr = (String) item.get('totalAmount');
            if (String.isNotBlank(totalAmountStr)) {
                total += Decimal.valueOf(totalAmountStr);
            }
        }
        return total;
    }

    public Decimal getTotalSalas(){
      Decimal total = 0;
      for(QuoteLineItem sala:salas){
        total += sala.CEN_TotalPriceEspejo__c;
      }
      return total;
    }

    public Decimal getGrandTotal(){
      return getTotalAmount() + getTotalSalas();
    }

    public Integer getTotalItemsCount() {
          Integer condicionesCount = getCondiciones().size();
          Integer salasCount = salas.size();
        return condicionesCount + salasCount;
    }

    public Boolean getIsThree(){
      Integer totalCount = getTotalItemsCount();
      return totalCount == 3;
    }

    public Boolean getIsOne(){
      Integer totalCount = getTotalItemsCount();
      return totalCount == 1;
    }

    public Boolean getIsTwo(){
      Integer totalCount = getTotalItemsCount();
      return totalCount == 2;
    }

    public Boolean   getIsMoreThanThree(){
      Integer totalCount = getTotalItemsCount();
      return totalCount > 3;
    }
}