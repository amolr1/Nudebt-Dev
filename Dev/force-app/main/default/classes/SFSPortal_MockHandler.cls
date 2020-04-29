/* Date : 05-02-2019
 * Author : Team IDev
 * Description : MockHandler
 */

@isTest
global class SFSPortal_MockHandler implements HttpCalloutMock {

    global HTTPResponse respond(HTTPRequest req) {
        
        system.debug('mockkk::'+req.getEndpoint());
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        
        if((req.getEndpoint()).contains('https://verify.twilio.com/v2/Services/')) {
        
            TwilioConfig__c twilioConfig = TwilioConfig__c.getInstance();
            
            if(req.getEndpoint().Equals('https://verify.twilio.com/v2/Services/' + twilioConfig.ApplicationSid__c + '/Verifications')) {
                
                res.setStatusCode(201);
            }
        } else if((req.getEndpoint()).contains('https://www.routingnumbers.info/api/data.json')) {
        
            SFSPortal_ADHOCPaymentController.RoutingResponse response = new SFSPortal_ADHOCPaymentController.RoutingResponse();
            response.message = 'Test Message';
            response.code = 'Test Code';
            response.city = 'Clio';
            response.state = 'AL';
            response.zip = '94405';
            response.telephone = '+9155156656';
            response.customer_name = 'Test Customer Name';
            
            res.setStatusCode(201);
            res.setBody(JSON.serialize(response));
            
        }
        
        return res; 
    }
}