/**
 * @description       :
 * @author            : @everis.com
 * @group             :
 * @last modified on  : 04-02-2022
 * @last modified by  : @everis.com
 * Modifications Log
 * Ver   Date         Author        Modification
 * 1.0   04-02-2022   @everis.com   Initial Version
**/
@isTest
public with sharing class CEN_SubscribeActive_tst {

    public static String respType;

    @testSetup
    public static void setup() {

        Lead ld = new Lead();
        ld.LastName = 'Lead Test';
        ld.CEN_T_rminos_y_condiciones__c = false;
        ld.LeadSource = 'Presencial';
        ld.CEN_Medio__c = '0112';

        insert ld;

        Account acc = new Account();
        acc.Name = 'Account Test';
        acc.Prospecto_acept_t_rminos_y_condiciones__c = false;
        // acc.CEN_Tipo_de_documento__pc = 'DNI';
        // acc.CEN_N_mero_de_documento__pc = '45558711';

        insert acc;
    }

    @isTest
    public static void testAccountSubscriberApi(){
        Test.startTest();
        Account acc = [SELECT Id FROM Account LIMIT 1];
        acc.Prospecto_acept_t_rminos_y_condiciones__c = true;
        update acc;

        CEN_SubscribeActive_tst.respType = 'error';
        Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
        CEN_UpdateSubscriberService_cls.executeSubscriberApi(acc.Id);
        Test.stopTest();
    }

    @isTest
    public static void testLeadSubscriberApi(){
        Test.startTest();
        Lead ld = [SELECT Id FROM Lead LIMIT 1];
        ld.CEN_T_rminos_y_condiciones__c = true;
        update ld;

        CEN_SubscribeActive_tst.respType = 'ok';
        Test.setMock(HttpCalloutMock.class, new CEN_HttpCalloutMock_tst());
        CEN_UpdateSubscriberService_cls.executeSubscriberApi(ld.Id);

        Test.stopTest();
    }

    public class CEN_HttpCalloutMock_tst implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            if (CEN_SubscribeActive_tst.respType.equals('ok')) {
                res.setBody('{"access_token":"eyJhbGciOiJIUzI1NiIsImtpZCI6IjQiLCJ2ZXIiOiIxIiwidHlwIjoiSldUIn0.eyJhY2Nlc3NfdG9rZW4iOiJZZGxuQ2RVOVNSNnNJY05sTUUyaE1paWgiLCJjbGllbnRfaWQiOiI5bGFzajZhaGZoeXJmbHhlNGl3dHpvZjQiLCJlaWQiOjExMDAwNjk0NSwic3RhY2tfa2V5IjoiUzExIiwicGxhdGZvcm1fdmVyc2lvbiI6MiwiY2xpZW50X3R5cGUiOiJTZXJ2ZXJUb1NlcnZlciJ9.Tr4nv3_4mTZA7C9WGARKef0djUoBkE0vZHl1HJ4u890.R0jBRakRS7fco2CN6y9ukJkoevlc6UJogzWbZly6PAkeUUI5huYL-kmlXoMgaEFc62duH5wZcF0GWMF0deRbIWdWbprtNAqyHICvtou_SBv0P3r0Sx1tBeHlMy0lloRlSjwbyfmnb7ddvAIbabnSRhCmgDZpZtZJ6Wm4BwDdjIb7SWxPpH8","token_type":"Bearer","expires_in":1022,"scope":"offline                documents_and_images_read documents_and_images_write saved_content_read saved_content_write automations_execute                automations_read automations_write journeys_execute journeys_read journeys_write email_read email_send email_write                push_read push_send push_write sms_read sms_send sms_write social_post social_publish social_read social_write                web_publish web_read web_write audiences_read audiences_write list_and_subscribers_read list_and_subscribers_write                data_extensions_read data_extensions_write file_locations_read file_locations_write tracking_events_read calendar_read                calendar_write campaign_read campaign_write accounts_read accounts_write users_read users_write webhooks_read                webhooks_write workflows_write approvals_write tags_write approvals_read tags_read workflows_read                ott_chat_messaging_read ott_chat_messaging_send ott_channels_read ott_channels_write marketing_cloud_connect_read                marketing_cloud_connect_write marketing_cloud_connect_send event_notification_callback_create                event_notification_callback_read event_notification_callback_update event_notification_callback_delete                event_notification_subscription_create event_notification_subscription_read event_notification_subscription_update                event_notification_subscription_delete tracking_events_write key_manage_view key_manage_rotate key_manage_revoke                dfu_configure journeys_aspr journeys_delete package_manager_package package_manager_deploy deep_linking_asset_read                deep_linking_asset_write deep_linking_asset_delete deep_linking_settings_read                deep_linking_settings_write","soap_instance_url":"https://mcmg2jwn12ylcb2w1j9nbhr8jpt1.soap.marketingcloudapis.com/","rest_instance_url":"https://mcmg2jwn12ylcb2w1j9nbhr8jpt1.rest.marketingcloudapis.com/"}');
                res.setStatusCode(200);
            }else{
                res.setBody('{"error":"error"}');
                res.setStatusCode(401);
            }
            return res;
        }
    }

}