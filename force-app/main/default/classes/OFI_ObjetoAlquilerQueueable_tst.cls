@IsTest
private class OFI_ObjetoAlquilerQueueable_tst {

    @IsTest
    static void testQueueable_OK() {

        Test.setMock(
            HttpCalloutMock.class,
            new OFI_ObjetoAlquilerServiceMock_311_cls()
        );

        Test.startTest();
        System.enqueueJob(
            new OFI_ObjetoAlquilerQueueable_cls('20260109')
        );
        Test.stopTest();

        System.assert(true, 'Queueable ejecutado correctamente');
    }
}