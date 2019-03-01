@isTest
global class echosignAPIMock implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"signingUrlSetInfos":[{"signingUrls":[{"email":"salesforce@2cloudnine.com","esignUrl":"https://secure.na1.echosign.com/public/apiesign?pid=CBFCIBAA3AAABLblqZhCYOtxQqt5QNkWoAHxBiHtG-6CS_QphVxc8l77C_c6Mj-MRk_woOHZFK1_Y3gDD8Pc*"}]}]}');
        response.setStatusCode(200);
        return response; 
    }
}