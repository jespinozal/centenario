global with sharing class ONI_InventarioLauncherScheduler_cls implements Schedulable {

    global void execute(SchedulableContext sc) {
        ONI_InventarioLauncher_cls.run();
    }
}