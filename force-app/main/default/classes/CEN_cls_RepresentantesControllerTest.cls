@isTest
public class CEN_cls_RepresentantesControllerTest {
	@isTest static void TestConst (){
        Account a = New Account(Name = 'CuentaNuevaPrueba');
        insert a;

        ApexPages.StandardController std = new ApexPages.StandardController(a);
        CEN_cls_RepresentantesController repreCont = new CEN_cls_RepresentantesController(std);

        system.debug(a.Name);
        System.assertNotEquals(NULL, 'Valor Nulo');
    }
}