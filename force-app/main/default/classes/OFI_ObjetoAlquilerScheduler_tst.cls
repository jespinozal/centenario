@IsTest
private class OFI_ObjetoAlquilerScheduler_tst {

    @IsTest
    static void testScheduler_OK() {

        Test.setMock(
            HttpCalloutMock.class,
            new OFI_ObjetoAlquilerServiceMock_311_cls()
        );

        Test.startTest();


        OFI_ObjetoAlquilerScheduler_cls sched = new OFI_ObjetoAlquilerScheduler_cls();
        sched.execute(null);

        Test.stopTest();

    }
}