public class ONI_StaticResource_cls {

    
    @InvocableMethod(label='Obtener Recurso Desde Archivo' description='Obtener Recurso Desde Archivo')
    public static List<Id> getFileFromStaticResource(List<Request> requestList) {
        Request req = requestList[0]; // Accepts one name
        System.debug(req);
        String rs = 'OFI_sre_'+req.resourceSize;
        StaticResource sr = [SELECT Body, Name FROM StaticResource WHERE Name = :rs LIMIT 1];

        ContentVersion cv = new ContentVersion();
        cv.Title = 'Comunicación_Comercial.pdf';//sr.Name;
        cv.PathOnClient = sr.Name; // Provide a filename with extension
        cv.VersionData = sr.Body;
        insert cv;

        return new List<Id>{cv.Id};
    }
    
    public class Request{
        @InvocableVariable
        public String resourceName;
        @InvocableVariable
        public String resourceSize;
    }

}