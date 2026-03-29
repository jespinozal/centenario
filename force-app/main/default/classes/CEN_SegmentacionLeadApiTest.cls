/**
 * @name               : CEN_SegmentacionLeadApiTest
 * @description        : Clase de prueba para CEN_SegmentacionLeadApi.
 * @author             : Jesus Jaime Poco Salvador
 * @creation date      : 10-04-2025
 */
@isTest
private class CEN_SegmentacionLeadApiTest {
    
    @isTest
    static void testParseToken_NullAccessToken() {
        String jsonToken = '{"token_type":"Bearer","expires_in":3600,"ext_expires_in":3600}';
        Test.startTest();
        CEN_SegmentacionLeadApi token = CEN_SegmentacionLeadApi.parseToken(jsonToken);
        Test.stopTest();
        
        System.assertEquals('Bearer', token.token_type, 'El tipo de token debería ser Bearer.');
        System.assertEquals(3600, token.expires_in, 'El expires_in debería ser 3600.');
        System.assertEquals(3600, token.ext_expires_in, 'El ext_expires_in debería ser 3600.');
        System.assertEquals(null, token.access_token, 'El access_token debería ser null si no está en el JSON.');
    }
    @isTest
    static void testParseSegmentacion_NullGlosa() {
        String jsonResponse = '{"codigoOperacion":"01"}';
        Test.startTest();
        CEN_SegmentacionLeadApi.SegmetacionResponse resp = CEN_SegmentacionLeadApi.parseSegmentacion(jsonResponse);
        Test.stopTest();
        
        System.assertEquals('01', resp.codigoOperacion, 'El código debería ser 01.');
        System.assertEquals(null, resp.glosaOperacion, 'La glosa debería ser null si no está en el JSON.');
    }
    @isTest
    static void testParseToken() {
        String jsonToken = '{"token_type":"Bearer","expires_in":3600,"ext_expires_in":3600,"access_token":"abc123"}';
        Test.startTest();
        CEN_SegmentacionLeadApi token = CEN_SegmentacionLeadApi.parseToken(jsonToken);
        
        token.Bearer = 'TestBearer';
        String bearerValue = token.Bearer;
        Test.stopTest();
        
        System.assertEquals('Bearer', token.token_type, 'El tipo de token debería ser Bearer.');
        System.assertEquals('abc123', token.access_token, 'El access token debería coincidir.');
    }
    
    @isTest
    static void testParseSegmentacion() {
        String jsonResponse = '{"codigoOperacion":"00","glosaOperacion":"Éxito"}';
        Test.startTest();
        CEN_SegmentacionLeadApi.SegmetacionResponse resp = CEN_SegmentacionLeadApi.parseSegmentacion(jsonResponse);
        Test.stopTest();
        
        System.assertEquals('00', resp.codigoOperacion, 'El código debería ser 00.');
        System.assertEquals('Éxito', resp.glosaOperacion, 'La glosa debería ser Éxito.');
    }
}