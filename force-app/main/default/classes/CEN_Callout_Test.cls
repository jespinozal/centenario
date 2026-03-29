/**
 * @description       : 
 * @author            : @everis.com
 * @group             : 
 * @last modified on  : 05-04-2021
 * @last modified by  : @everis.com
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   04-21-2021   @everis.com   Initial Version
**/
@isTest
public with sharing class CEN_Callout_Test {
    //  Para aumentar cubrimiento, agregar una implementación de prueba de CEN_Callout_clsParser
	static String testImplCEN_Callout_clsParser = 'CEN_Callout_Test.TestParser';
	@isTest
	static void shouldConstructException() {
		CEN_Callout_cls CEN_Callout_cls;
		String errorMessage = '';
		Test.startTest();
		try {
			CEN_Callout_cls = new CEN_Callout_cls('testCmt');
		} catch (Exception ex) {
			errorMessage = ex.getMessage();
		}
		Test.stopTest();
		System.assertEquals(null, CEN_Callout_cls, 'Debe ser nulo');
		//System.assert(errorMessage.contains('Error en configuración de Callout'),'Debe tener el mensaje de error adecuado: Error en configuración de Callout');
	}
	@isTest
	static void shouldSetHeaders() {
		CEN_AvailableWebservices__mdt testCmt = new CEN_AvailableWebservices__mdt(
			Label = 'testCmt',
			CEN_Method__c = 'GET',
			CEN_NamedCredential__c = 'namedCredential',
			CEN_Endpoint__c = '/endpoint'
		);
		Test.setMock(HttpCalloutMock.class, new ResponseMock('String'));
		Test.startTest();
		CEN_Callout_cls CEN_Callout_cls = new CEN_Callout_cls(testCmt);
		Map<String, String> headers = new Map<String, String>{ 'Content-Type' => 'application/json' };
		CEN_Callout_cls.setHeaders(headers).setTimeout(12345).makeCallout();
		Test.stopTest();
		System.assertEquals(200, CEN_Callout_cls.getResponse().getStatusCode(), 'Debe ser 200');
		System.assertEquals(
			'application/json',
			CEN_Callout_cls.getRequest().getHeader('Content-Type'),
			'Debe tener json como header'
		);
	}
	@isTest
	static void shouldSetAdditionalHeaders() {
		CEN_AvailableWebservices__mdt testCmt = new CEN_AvailableWebservices__mdt(
			Label = 'testCmt',
			CEN_Method__c = 'GET',
			CEN_NamedCredential__c = 'namedCredential',
			CEN_Endpoint__c = '/endpoint',
			CEN_AdditionalHeaders__c = '{"Content-Type":"application/json"}'
		);
		Test.setMock(HttpCalloutMock.class, new ResponseMock('String'));
		Test.startTest();
		CEN_Callout_cls CEN_Callout_cls = new CEN_Callout_cls(testCmt);
		CEN_Callout_cls.makeCallout();
		Test.stopTest();
		System.assertEquals(200, CEN_Callout_cls.getResponse().getStatusCode(), 'Debe ser 200');
		System.assertEquals(
			'application/json',
			CEN_Callout_cls.getRequest().getHeader('Content-Type'),
			'Debe tener json como header'
		);
	}
	@isTest
	static void shouldFailSetAdditionalHeaders() {
		CEN_AvailableWebservices__mdt testCmt = new CEN_AvailableWebservices__mdt(
			Label = 'testCmt',
			CEN_Method__c = 'GET',
			CEN_NamedCredential__c = 'namedCredential',
			CEN_Endpoint__c = '/endpoint',
			CEN_AdditionalHeaders__c = 'Content-Type=>application/json'
		);
		String errorMessage = '';
		Test.setMock(HttpCalloutMock.class, new ResponseMock('String'));
		Test.startTest();
		CEN_Callout_cls CEN_Callout_cls = new CEN_Callout_cls(testCmt);
		try {
			CEN_Callout_cls.makeCallout();
		} catch (Exception ex) {
			errorMessage = ex.getMessage();
		}
		Test.stopTest();
		System.assertNotEquals(
			'application/json',
			CEN_Callout_cls.getRequest().getHeader('Content-Type'),
			'Debe tener json como header'
		);
		// System.assert(
		// 	errorMessage.contains('Error de encabezados adicionales'),
		// 	'Debe tener el mensaje de error adecuado: Error de encabezados adicionales'
		// );
	}
	@isTest
	static void shouldSetParams() {
		CEN_AvailableWebservices__mdt testCmt = new CEN_AvailableWebservices__mdt(
			Label = 'testCmt',
			CEN_Method__c = 'GET',
			CEN_NamedCredential__c = 'namedCredential',
			CEN_Endpoint__c = '/endpoint'
		);
		Map<String, String> params = new Map<String, String>{ 'key' => 'value' };
		Test.setMock(HttpCalloutMock.class, new ResponseMock('String'));
		Test.startTest();
		CEN_Callout_cls CEN_Callout_cls = new CEN_Callout_cls(testCmt);
		CEN_Callout_cls.setParams(params).makeCallout();
		Test.stopTest();
		System.assertEquals(
			'callout:namedCredential/endpoint?key=value',
			CEN_Callout_cls.getRequest().getEndpoint(),
			'Debe ser correcto el endpoint'
		);
	}
	//  No hay shouldSetCertificate debido a que no hay forma de simularlo... toca vivir con eso...
	@isTest
	static void shouldFailBadCert() {
		CEN_AvailableWebservices__mdt testCmt = new CEN_AvailableWebservices__mdt(
			Label = 'testCmt',
			CEN_Method__c = 'GET',
			CEN_NamedCredential__c = 'namedCredential',
			CEN_Endpoint__c = '/endpoint'
		);
		String errorMessage = '';
		Test.setMock(HttpCalloutMock.class, new ResponseMock('String', 404, 'NOT FOUND'));
		Test.startTest();
		CEN_Callout_cls CEN_Callout_cls = new CEN_Callout_cls(testCmt);
		try {
			CEN_Callout_cls.setClientCertificateName('nonExistingCert');
		} catch (Exception ex) {
			errorMessage = ex.getMessage();
		}
		Test.stopTest();
		System.assertNotEquals('', errorMessage, 'Debe tener mensaje de error');
	}
	@isTest
	static void shouldSetRequestBodyBlob() {
		CEN_AvailableWebservices__mdt testCmt = new CEN_AvailableWebservices__mdt(
			Label = 'testCmt',
			CEN_Method__c = 'GET',
			CEN_NamedCredential__c = 'namedCredential',
			CEN_Endpoint__c = '/endpoint'
		);
		Test.setMock(HttpCalloutMock.class, new ResponseMock('String'));
		Blob body = Crypto.generateDigest('SHA-256', Blob.valueOf('Test String'));
		Test.startTest();
		CEN_Callout_cls CEN_Callout_cls = new CEN_Callout_cls(testCmt);
		CEN_Callout_cls.setRequestBody(body).makeCallout();
		Test.stopTest();
		System.assert(CEN_Callout_cls.getRequest().getHeader('Content-Type').contains('multipart'), 'Debe tener el content-type');
		System.assertEquals(200, CEN_Callout_cls.getResponse().getStatusCode(), 'Debe ser 200');
	}
	@isTest
	static void shouldSetRequestBodyString() {
		CEN_AvailableWebservices__mdt testCmt = new CEN_AvailableWebservices__mdt(
			Label = 'testCmt',
			CEN_Method__c = 'GET',
			CEN_NamedCredential__c = 'namedCredential',
			CEN_Endpoint__c = '/endpoint'
		);
		Test.setMock(HttpCalloutMock.class, new ResponseMock('String'));
		String body = 'Test String';
		Test.startTest();
		CEN_Callout_cls CEN_Callout_cls = new CEN_Callout_cls(testCmt);
		CEN_Callout_cls.setRequestBody(body).makeCallout();
		Test.stopTest();
		System.assert(
			CEN_Callout_cls.getRequest().getHeader('Content-Type').contains('application/json'),
			'Debe tener el content-type'
		);
		System.assertEquals(200, CEN_Callout_cls.getResponse().getStatusCode(), 'Debe ser 200');
	}
	@isTest
	static void shouldSetRequestBodyDomDoc() {
		CEN_AvailableWebservices__mdt testCmt = new CEN_AvailableWebservices__mdt(
			Label = 'testCmt',
			CEN_Method__c = 'GET',
			CEN_NamedCredential__c = 'namedCredential',
			CEN_Endpoint__c = '/endpoint'
		);
		Test.setMock(HttpCalloutMock.class, new ResponseMock('String'));
		Dom.Document body = new Dom.Document();
		body.createRootElement('head', 'ns', 'test').addChildElement('body', 'ns', 'test').addTextNode('content');
		Test.startTest();
		CEN_Callout_cls CEN_Callout_cls = new CEN_Callout_cls(testCmt);
		CEN_Callout_cls.setRequestBody(body).makeCallout();
		Test.stopTest();
		System.assert(CEN_Callout_cls.getRequest().getHeader('Content-Type').contains('text/xml'), 'Debe tener el content-type');
		System.assertEquals(200, CEN_Callout_cls.getResponse().getStatusCode(), 'Debe ser 200');
	}
	@isTest
	static void shouldSetRequestBodyObject() {
		CEN_AvailableWebservices__mdt testCmt = new CEN_AvailableWebservices__mdt(
			Label = 'testCmt',
			CEN_Method__c = 'GET',
			CEN_NamedCredential__c = 'namedCredential',
			CEN_Endpoint__c = '/endpoint'
		);
		Test.setMock(HttpCalloutMock.class, new ResponseMock('String'));
		CEN_AvailableWebservices__mdt body = testCmt;
		Test.startTest();
		CEN_Callout_cls CEN_Callout_cls = new CEN_Callout_cls(testCmt);
		CEN_Callout_cls.setRequestBody(body).makeCallout();
		Test.stopTest();
		System.assert(
			CEN_Callout_cls.getRequest().getHeader('Content-Type').contains('application/json'),
			'Debe tener el content-type'
		);
		System.assertEquals(200, CEN_Callout_cls.getResponse().getStatusCode(), 'Debe ser 200');
	}
	@isTest
	static void shouldParseCEN_Callout_cls200() {
		CEN_AvailableWebservices__mdt testCmt = new CEN_AvailableWebservices__mdt(
			Label = 'testCmt',
			CEN_Method__c = 'GET',
			CEN_NamedCredential__c = 'namedCredential',
			CEN_Endpoint__c = '/endpoint'
		);
		Test.setMock(HttpCalloutMock.class, new ResponseMock('String'));
		Test.startTest();
		CEN_Callout_cls CEN_Callout_cls = new CEN_Callout_cls(testCmt);
		Object parsedResponse = CEN_Callout_cls.makeCallout().getParsedResponse();
		Test.stopTest();
		System.assertEquals(
			'callout:namedCredential/endpoint',
			CEN_Callout_cls.getRequest().getEndpoint(),
			'Debe ser correcto el endpoint'
		);
		System.assertEquals(200, CEN_Callout_cls.getResponse().getStatusCode(), 'Debe ser 200');
		System.assert(parsedResponse instanceof String, 'Debe ser una cadena');
	}
	@isTest
	static void shouldParseCEN_Callout_clsParserClass() {
		CEN_AvailableWebservices__mdt testCmt = new CEN_AvailableWebservices__mdt(
			Label = 'testCmt',
			CEN_Method__c = 'GET',
			CEN_NamedCredential__c = 'namedCredential',
			CEN_Endpoint__c = '/endpoint',
			CEN_ParserClass__c = TestImplCEN_Callout_clsParser
		);
		Test.setMock(HttpCalloutMock.class, new ResponseMock('Json'));
		Test.startTest();
		CEN_Callout_cls CEN_Callout_cls = new CEN_Callout_cls(testCmt);
		CEN_Callout_cls.makeCallout().getParsedResponse();
		Test.stopTest();
		System.assertEquals(
			'callout:namedCredential/endpoint',
			CEN_Callout_cls.getRequest().getEndpoint(),
			'Debe ser correcto el endpoint'
		);
		System.assertEquals(200, CEN_Callout_cls.getResponse().getStatusCode(), 'Debe ser 200');
	}
	@isTest
	static void shouldParseCEN_Callout_clsBlob() {
		CEN_AvailableWebservices__mdt testCmt = new CEN_AvailableWebservices__mdt(
			Label = 'testCmt',
			CEN_Method__c = 'GET',
			CEN_NamedCredential__c = 'namedCredential',
			CEN_Endpoint__c = '/endpoint'
		);
		Test.setMock(HttpCalloutMock.class, new ResponseMock('Blob'));
		Test.startTest();
		CEN_Callout_cls CEN_Callout_cls = new CEN_Callout_cls(testCmt);
		CEN_Callout_cls.makeCallout().getParsedResponse();
		Test.stopTest();
		System.assertEquals(
			'callout:namedCredential/endpoint',
			CEN_Callout_cls.getRequest().getEndpoint(),
			'Debe ser correcto el endpoint'
		);
		System.assertEquals(200, CEN_Callout_cls.getResponse().getStatusCode(), 'Debe ser 200');
	}
	@isTest
	static void shouldParseCEN_Callout_clsXml() {
		CEN_AvailableWebservices__mdt testCmt = new CEN_AvailableWebservices__mdt(
			Label = 'testCmt',
			CEN_Method__c = 'GET',
			CEN_NamedCredential__c = 'namedCredential',
			CEN_Endpoint__c = '/endpoint'
		);
		Test.setMock(HttpCalloutMock.class, new ResponseMock('Xml'));
		Test.startTest();
		CEN_Callout_cls CEN_Callout_cls = new CEN_Callout_cls(testCmt);
		CEN_Callout_cls.makeCallout().getParsedResponse();
		Test.stopTest();
		System.assertEquals(
			'callout:namedCredential/endpoint',
			CEN_Callout_cls.getRequest().getEndpoint(),
			'Debe ser correcto el endpoint'
		);
		System.assertEquals(200, CEN_Callout_cls.getResponse().getStatusCode(), 'Debe ser 200');
	}
	@isTest
	static void shouldParseCEN_Callout_clsJson() {
		CEN_AvailableWebservices__mdt testCmt = new CEN_AvailableWebservices__mdt(
			Label = 'testCmt',
			CEN_Method__c = 'GET',
			CEN_NamedCredential__c = 'namedCredential',
			CEN_Endpoint__c = '/endpoint'
		);
		Test.setMock(HttpCalloutMock.class, new ResponseMock('Json'));
		Test.startTest();
		CEN_Callout_cls CEN_Callout_cls = new CEN_Callout_cls(testCmt);
		CEN_Callout_cls.makeCallout().getParsedResponse();
		Test.stopTest();
		System.assertEquals(
			'callout:namedCredential/endpoint',
			CEN_Callout_cls.getRequest().getEndpoint(),
			'Debe ser correcto el endpoint'
		);
		System.assertEquals(200, CEN_Callout_cls.getResponse().getStatusCode(), 'Debe ser 200');
	}
	@isTest
	static void shouldParseCEN_Callout_clsOther() {
		CEN_AvailableWebservices__mdt testCmt = new CEN_AvailableWebservices__mdt(
			Label = 'testCmt',
			CEN_Method__c = 'GET',
			CEN_NamedCredential__c = 'namedCredential',
			CEN_Endpoint__c = '/endpoint'
		);
		Test.setMock(HttpCalloutMock.class, new ResponseMock('Other'));
		Test.startTest();
		CEN_Callout_cls CEN_Callout_cls = new CEN_Callout_cls(testCmt);
		CEN_Callout_cls.makeCallout().getParsedResponse();
		Test.stopTest();
		System.assertEquals(
			'callout:namedCredential/endpoint',
			CEN_Callout_cls.getRequest().getEndpoint(),
			'Debe ser correcto el endpoint'
		);
		System.assertEquals(200, CEN_Callout_cls.getResponse().getStatusCode(), 'Debe ser 200');
	}
	@isTest
	static void shouldParseCEN_Callout_cls404() {
		CEN_AvailableWebservices__mdt testCmt = new CEN_AvailableWebservices__mdt(
			Label = 'testCmt',
			CEN_Method__c = 'GET',
			CEN_NamedCredential__c = 'namedCredential',
			CEN_Endpoint__c = '/endpoint'
		);
		String errorMessage = '';
		Test.setMock(HttpCalloutMock.class, new ResponseMock('String', 404, 'NOT FOUND'));
		Test.startTest();
		CEN_Callout_cls CEN_Callout_cls = new CEN_Callout_cls(testCmt);
		try {
			CEN_Callout_cls.makeCallout().getParsedResponse();
		} catch (Exception ex) {
			errorMessage = ex.getMessage();
		}
		Test.stopTest();
		System.assertEquals(404, CEN_Callout_cls.getResponse().getStatusCode(), 'Debe ser 404');
		System.assertNotEquals('', errorMessage, 'Debe tener mensaje de error');
	}
	private class ResponseMock implements HttpCalloutMock {
		private String bodyType;
		private Integer statusCode;
		private String status;

		private ResponseMock(String bodyType) {
			this(bodyType, 200, 'OK');
		}

		private ResponseMock(String bodyType, Integer statusCode, String status) {
			this.bodyType = bodyType;
			this.statusCode = statusCode;
			this.status = status;
		}
		/**
		 * @description HttpCalloutMock Implementation
		 * @param  req Test request
		 * @return     Mocked response
		 */
		public HTTPResponse respond(HTTPRequest req) {
			HttpResponse res = new HttpResponse();
			res.setStatusCode(this.statusCode);
			res.setStatus(this.status);
			switch on this.bodyType {
				when 'Blob' {
					res.setBodyAsBlob(Blob.valueOf('Test String'));
					res.setHeader('Content-Type', 'multipart/form-data; charset=utf-8');
				}
				when 'Xml' {
					res.setBody(
						'<?xml version="1.0" encoding="UTF-8"?><test:head xmlns:test="ns"><test:body>content</test:body></test:head>'
					);
					res.setHeader('Content-Type', 'text/xml; charset=utf-8');
				}
				when 'Json' {
					res.setBody('{"content":[{"id":1,"key":"value"},{"id":2,"key":"value 2"},{"3":2,"key":"value 2"}]}');
					res.setHeader('Content-Type', 'application/json; charset=utf-8');
				}
				when else {
					res.setBody(this.bodyType);
				}
			}
			return res;
		}
	}
	/**
	 * @description Parser exclusivamente creado para la prueba
	 */
	public class TestParser implements CEN_CalloutParser {
		/**
		 * @description Implementación del método parseRequest
		 * @param request grupo de llaves
		 * @return   DTO Simple
		 *
		 */
		public Object parseRequest(String request) {
			return (DTO) JSON.deserialize(request, DTO.class);
		}
		/**
		 * @description Implementación del método parseResponse
		 * @param request grupo de llaves
		 * @return   DTO Simple
		 *
		 */
		public Object parseResponse(String request) {
			return (DTO) JSON.deserialize(request, DTO.class);
		}
	}

	/**
	 * @description DTO de prueba, únicamente existe para modelar el mocking del framework
	 */
	public class DTO {
		Map<String, String> entries;
	}
}