/**
 * @description       : 
 * @author            : @everis.com
 * @group             : 
 * @last modified on  : 07-20-2021
 * @last modified by  : @everis.com
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   06-11-2021   @everis.com   Initial Version
**/
@RestResource(urlMapping='/sap/opportunity/*')
global class  CEN_OpportunitySapService_cls {
    @HttpPost
    global static String doPost(){
        String myResp;
        String msg;
        String myState;
        try {
            String jsonString = RestContext.request.requestBody.toString();
            oppReq myObjReq = (oppReq)JSON.deserialize(jsonString,oppReq.class);
           
            if(myObjReq!=null && myObjReq.budgetNumber!=null && String.isNotEmpty(myObjReq.budgetNumber) && myObjReq.codStateBudget!=null && String.isNotEmpty(myObjReq.codStateBudget) && myObjReq.codSubStateBudget!=null && String.isNotEmpty(myObjReq.codSubStateBudget) ){
                List<Opportunity> opp = [SELECT Id, Estado_Proforma__c, Sub_Estado_Proforma__c FROM Opportunity WHERE StageName <> 'Oportunidad Perdida' AND CEN_Proforma__c = :myObjReq.budgetNumber ];
                if(opp!=null && opp.size()>0){
                    opp[0].Estado_Proforma__c = myObjReq.codStateBudget;
                    opp[0].Sub_Estado_Proforma__c= myObjReq.codSubStateBudget;
                    update opp;

                    myState= 'succes';
                    msg='Estado de Proforma actualizada con exito';

                }else{
                    myState= 'error';
                    msg='Proforma no encontrada';
                }
            }else{
                myState= 'error';
                msg='Indicar proforma y estads para actualizar';
            }
            

        }catch (Exception ex) {
            myState= 'error';
            msg=ex.getMessage();
        }

        oppResp oppEx = new oppResp();
        oppEx.status = myState;
        oppEx.message = msg;
        myResp = JSON.serialize(oppEx);

        return myResp;

    }

    public class oppResp{
        public string status;
        public string message;
    }

    public class oppReq{
        public string budgetNumber;
        public string codStateBudget;
        public string codSubStateBudget;
    }

}