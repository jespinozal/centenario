public class ONI_EnviarBrochurePDF_cls {
    public List<Product2> imagenesFiles { get; set; }
    public List<String> openingResourceList { get; set; }
    public List<String> closureResourceList { get; set; }
    

    public ONI_EnviarBrochurePDF_cls(ApexPages.StandardController stdController) {
        
    }

    public ONI_EnviarBrochurePDF_cls() {
        System.debug(3);
        Map<String, String> params = ApexPages.currentPage().getParameters();
        List<Id> idList = (List<Id>)JSON.deserialize(params.get('idList'),List<Id>.class);
        //IMAGENES DE APERTURA DEL BROCHURE
        openingResourceList = getResourceURL('OFI_str_CaratulaPdf%');
        //IMAGENES DE LOS PRODUCTOS SELECCIONADOS
        system.debug('idList::::::::: '+idList);
        imagenesFiles = [
            SELECT Id, Imagen_URL__c
            FROM Product2
            WHERE Id IN :idList 
        ];
        system.debug('imagenesFiles first item::::::::: '+this.imagenesFiles);
        //IMAGENES DE CIERRE DEL BROCHURE
        closureResourceList=getResourceURL('OFI_str_CierrePdf%');
    }

    @AuraEnabled
    public static List<Product2> getListProducts(String recordType){
        try {
          List<Product2> pList =  [SELECT Id, name
            FROM Product2 
            WHERE RecordType.Name = :recordType WITH USER_MODE ];
            return pList;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public static List<String> getResourceURL(String text) {
        List<String> resourceList= new List<String>();
        List<StaticResource> stResourceList = [
            SELECT Name, NamespacePrefix, SystemModStamp 
            FROM StaticResource 
            WHERE Name like :text
            ORDER BY Name ASC
        ];
        system.debug('stResourceList::::::::: '+stResourceList); 
        for (StaticResource res : stResourceList) {
            resourceList.add(PageReference.forResource(res.name).getUrl());
        }
        system.debug('resourceList::::::::: '+resourceList);
        return resourceList;
    }

    @AuraEnabled
    public static String generateAndAttachPdfEx(Id id,List<Id> idList) {

        // Generate a PDF for each record passed to the method
        PageReference pdfPage = Page.ONI_vfp_BrochurePDF;
        //pdfPage.getParameters().put('id', recordId);
        pdfPage.getParameters().put('idList',JSON.serialize(idList));

        // Get the PDF content as a Blob
        Blob pdfBlob;
        System.debug(1);
        try {
            if (Test.isRunningTest()) {
                //Simulación para test
                pdfBlob = Blob.valueOf('Test PDF Content');
            } else {
                pdfBlob = pdfPage.getContentAsPDF();
            }
        } catch (Exception e) {
            throw new AuraHandledException('Error generating PDF for record: ' + e.getMessage());
        }
        System.debug(2);
        ContentVersion cv = new ContentVersion();
        cv.Title = 'Brochure - ' + System.now().format('yyyy-MM-dd HH:mm:ss');
        cv.PathOnClient = cv.Title + '.pdf';
        cv.VersionData = pdfBlob;
        cv.Origin = 'H'; // Designates the file as being from a Chatter post, which allows for linking

        insert cv;
        
        return cv.Id;
    }

    @AuraEnabled
    public static void sendEmailWithBrochure(Id id, String cvId) {
        ContentVersion cv = [SELECT Id, Title, VersionData FROM ContentVersion WHERE Id = :cvId LIMIT 1];
        Lead lead = [SELECT Id, Name, Email FROM Lead WHERE Id  =:id WITH USER_MODE];
        OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'informes@terreno.pe' LIMIT 1];
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] { lead.Email });
        mail.setSubject('Brochure de Oficinas');
        mail.setPlainTextBody('Estimado/a ' + lead.Name + ',\n\n' +
            'Espero que se encuentre muy bien.\n\n' +
            'Adjunto encontrará el brochure con la información detallada de nuestras oficinas disponibles, ' +
            'incluyendo características, ubicaciones y beneficios.\n\n' +
            'Quedamos atentos para coordinar una llamada o visita y resolver cualquier consulta que pueda tener.\n\n' +
            'Saludos cordiales\n'+
            'Centenario\n');
        if (!Test.isRunningTest() && !owea.isEmpty()) {
            mail.setOrgWideEmailAddressId(owea[0].Id);
        }
        
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName(cv.Title + '.' + 'pdf'); // Set the filename with extension
        efa.setBody(cv.VersionData); // Set the attachment body from VersionData

        // Add the attachment to the email
        mail.setFileAttachments(new Messaging.EmailFileAttachment[] { efa });

        // Send the email
        Messaging.SendEmailResult[] results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });

        System.debug(4);
        if (results[0].isSuccess()) {
            System.debug('Email sent successfully!');
        } else {
            System.debug('Email failed to send: ' + results[0].getErrors());
        }
    }

}