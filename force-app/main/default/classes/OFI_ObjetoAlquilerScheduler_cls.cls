/*********************************************************************
* @author: Alfredo Morote
* @date: 29-10-2025
* @description: Scheduler diario para Objetos de Alquiler
*********************************************************************/
global class OFI_ObjetoAlquilerScheduler_cls
    implements Schedulable {

    global void execute(SchedulableContext sc) {

        String fecha =
            String.valueOf(Date.today().addDays(-1).year()) +
            String.valueOf(Date.today().addDays(-1).month()).leftPad(2, '0') +
            String.valueOf(Date.today().addDays(-1).day()).leftPad(2, '0');

        System.enqueueJob(
            new OFI_ObjetoAlquilerQueueable_cls(fecha)
        );
    }
}