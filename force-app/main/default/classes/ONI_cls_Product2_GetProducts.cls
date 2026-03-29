public with sharing class ONI_cls_Product2_GetProducts {
    @AuraEnabled(cacheable=true)
    public static List<Product2> ONI_cls_Product2_GetProducts() {
        List<Product2> products = [SELECT Id, Name FROM Product2 WHERE RecordType.DeveloperName IN ('OFI_rt_Product2_Oficina','OFI_rt_Product2_Industrial')];
        return products;
    }
}