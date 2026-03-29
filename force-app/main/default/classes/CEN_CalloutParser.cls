/**
 * @description       : 
 * @author            : @everis.com
 * @group             : 
 * @last modified on  : 05-04-2021
 * @last modified by  : @everis.com
 * Modifications Log 
 * Ver   Date         Author        Modification
 * 1.0   04-05-2021   @everis.com   Initial Version
**/
public interface CEN_CalloutParser {
   /**
	 * @description DTO Request Parser
	 * @param  obj JSON for service request
	 * @return      DTO Request Structure
	 */
	Object parseRequest(String obj);
	
	/**
	 * @description DTO Response Parser
	 * @param  obj JSON for service response
	 * @return      DTO Response Structure
	 * Alan Nayib
	 */
	Object parseResponse(String obj);

}