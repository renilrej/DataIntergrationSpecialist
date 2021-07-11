@isTest
public class ProjectCalloutServiceMockFailure implements HttpCalloutMock 
{
   //Implement http mock callout failure here 
	public HttpResponse respond(HttpRequest req)
    {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatus('Bad Response');
        res.setStatusCode(500);
        
        return res;
    }
}