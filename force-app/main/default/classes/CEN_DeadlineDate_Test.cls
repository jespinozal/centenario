/*********************************************************************
* @author: Jose Hernandez (jherncal@emeal.nttdata.com)
* @date: 2023-05-31
* @description: Clase test CEN_DeadlineDate
*
* VERSION      DATE                 AUTOR                   ACTION
* 0.1          2023-05-31           Jose Hernandez          Creación
*
*********************************************************************/
@isTest
public with sharing class CEN_DeadlineDate_Test {
    @isTest
    static void calcularFechaPlazosInvocableTest(){
        // Initialize parameters class
        CEN_DeadlineDate.FlowParameters params = new CEN_DeadlineDate.FlowParameters();
        params.fechaInicial= system.today();
        params.numDiasHabiles = 5;


        // Invoke target method
        //List<Date> result = CEN_DeadlineDate.calcularFechaPlazoInvocable(new List<FlowParameters>{params});
        List<Date> result = CEN_DeadlineDate.calcularFechaPlazoInvocable(new List<CEN_DeadlineDate.FlowParameters>{params});
 
        // Verify results
        Date expected=CEN_DeadlineDate.calcularFechaPlazoParametro(params.fechaInicial,params.numDiasHabiles);
        System.assertEquals(result[0], expected, 'Expected date was not found');
    }

    @isTest
    static void calcularSemanaSantaTest(){
        // Declare and initialize vars
        Set<Datetime> semanaSantaActual = CEN_DeadlineDate.calcularSemanaSanta();
        Integer year = Date.today().year();
        //Calulate Easter
        Integer goldenNumber = math.mod(year,19) + 1;
        Integer century = year / 100 + 1;
        Integer x = (3 * century) / 4 - 12;
        Integer z = ((8 * century + 5) / 25) - 5;
        Integer d = (5 * year) / 4 - x - 10;
        Integer epact = math.mod((11 * goldenNumber + 20 + z - x), 30);
        if (epact == 25 && goldenNumber > 11 || epact == 24) {
            epact++;
        }
        Integer n = 44 - epact;
        if (n < 21) {
            n += 30;
        }
        n = n + 7 - (math.mod((d + n), 7));
        Date easter = Date.newInstance(year, 3, 1).addDays(n - 1);
        //Calculations for certain days in Semana Santa
        Datetime holyThursday = DateTime.newInstance(easter.addDays(-3).year(),easter.addDays(-3).month(),easter.addDays(-3).day(),0,0,0);
        Datetime goodFriday = DateTime.newInstance(easter.addDays(-2).year(),easter.addDays(-2).month(),easter.addDays(-2).day(),0,0,0);
        //Verify values
        System.assert(semanaSantaActual.contains(holyThursday),'Holy Thursday was not found');
        System.assert(semanaSantaActual.contains(goodFriday),'Good Friday was not found');
    }

}