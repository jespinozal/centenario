public with sharing class ONI_InventarioLauncher_cls {
    public ONI_InventarioLauncher_cls() {

    }

    public static void run () {
        List<Proyecto__c> proList = [SELECT Id FROM Proyecto__c WHERE Name LIKE 'Macr%' AND CEN_CODIGOSAP__c != null];
        for(Proyecto__c pro : proList) {
            System.enqueueJob(new ONI_Inventario_cls(pro.Id));
        }
    }
}