/*********************************************************************
* @author: Jose Hernandez (jherncal@emeal.nttdata.com)
* @date: 2023-05-31
* @description: Clase para calcular fecha de plazos
*
* VERSION      DATE                 AUTOR                   ACTION
* 0.1          2023-05-31           Jose Hernandez          Creación
*
*********************************************************************/
public with sharing class CEN_DeadlineDate {
    @InvocableMethod(label='calcularFechaPlazosInvocable')
        public static List<Date> calcularFechaPlazoInvocable(List<FlowParameters> parameters) {
            Integer diasContados = 0;
            List<Date> listFechaPlazo = new List<Date>();
            Date fechaInicial=parameters[0].fechaInicial;
            Datetime fechaActual = Datetime.newInstance(fechaInicial.year(),fechaInicial.month(),fechaInicial.day(),0,0,0);
            //Date fechaActual =fechaInicial;
            BusinessHours bh = [SELECT Id FROM BusinessHours WHERE Name ='Dias Laborables'];

         system.debug('Fecha Inicial: ' + fechaInicial);
         while (diasContados < parameters[0].numDiasHabiles) {
             fechaActual = fechaActual.addDays(1);

          // Ignora los fines de semana y los días no laborables personalizados
            Boolean validaSemanaSanta = !calcularSemanaSanta().contains(fechaActual);
            if (BusinessHours.isWithin(bh.id,fechaActual)&&validaSemanaSanta ) {
             system.debug('Fecha : ' + fechaActual);
             diasContados++;
          }

        }

        Date fechaPlazo = Date.valueOf(fechaActual);
        listFechaPlazo.add(fechaPlazo);

        return listFechaPlazo;
    }

    public class FlowParameters {
        @InvocableVariable(label = 'FechaInicial' description = 'Fecha inicial del plazo' required = true)
        public Date fechaInicial;
        @InvocableVariable(label = 'NumerodeDiasHabiles' description = 'numero de dias habiles a sumar' required = true)
        public Integer numDiasHabiles;

    }

        public static Date calcularFechaPlazoParametro(Date fechaInicial,Integer numDiasHabiles) {
            Integer diasContados = 0;
            Datetime fechaActual = Datetime.newInstance(fechaInicial.year(),fechaInicial.month(),fechaInicial.day(),0,0,0);

            //Date fechaActual =fechaInicial;
            BusinessHours bh = [SELECT Id FROM BusinessHours WHERE Name ='Dias Laborables'];

         system.debug('Fecha Inicial: ' + fechaInicial);
         while (diasContados < numDiasHabiles) {
             fechaActual = fechaActual.addDays(1);

          // Ignora los fines de semana y los días no laborables personalizados
            Boolean validaSemanaSanta = !calcularSemanaSanta().contains(fechaActual);
            if (BusinessHours.isWithin(bh.id,fechaActual)&&validaSemanaSanta ) {
             system.debug('Fecha : ' + fechaActual);
             diasContados++;
          }

        }

        return Date.valueOf(fechaActual);
    }

    public static Set<Datetime> calcularSemanaSanta(){
        // Definición collection diasSemanaSanta.
        Set<Datetime> diasSemanaSanta=new Set<Datetime>();
        // Obtener el año actual
        Integer year = Date.today().year();
        // Calcular la fecha de la Pascua
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
        // Calcular el Domingo de Ramos
        Date palmSunday = easter.addDays(-7);
        // Calcular la Semana Santa
        Date holyThursday = easter.addDays(-3);
        Date goodFriday = easter.addDays(-2);
        Date holySaturday = easter.addDays(-1);
        Date easterSunday = easter;
        Date easterMonday = easter.addDays(1);
        diasSemanaSanta.add(DateTime.newInstance(holyThursday.year(),holyThursday.month(),holyThursday.day(),0,0,0));
        diasSemanaSanta.add(DateTime.newInstance(goodFriday.year(),goodFriday.month(),goodFriday.day(),0,0,0));

        return diasSemanaSanta;
    }
}