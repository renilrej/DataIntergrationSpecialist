public class ProjectCalloutService {
    public static Id opportunityId;
    
    @InvocableMethod
    public static void postOpportunityToPMS(List<Id> opportunityIds){
        opportunityId=opportunityIds.get(0);
        Opportunity opp=[Select Id,Name, closeDate,amount,Account.Name FROM Opportunity Where Id =: opportunityId];
        ID jobID = System.enqueueJob(new QueueablePMSCall(opp));
    }    
    
    public class QueueablePMSCall implements System.Queueable,Database.AllowsCallouts
    {
        private String inputJson;
        private Opportunity opportunityObject;
        
        public QueueablePMSCall(Opportunity opp)
        {
            opportunityObject = opp;
            
            JSONGenerator gen = JSON.createGenerator(true);
            
            gen.writeStartObject();
            gen.writeStringField('opportunityId', opp.Id);
            gen.writeStringField('opportunityName', opp.Name);
            gen.writeStringField('accountName', opp.account.Name);
            gen.writeDateField('closeDate', opp.closeDate);
            gen.writeNumberField('amount', opp.amount); 
            gen.writeEndObject();            
            
            inputJson = gen.getAsString();
            
        }
        public void execute(QueueableContext context) {
            
            ServiceTokens__c token= ServiceTokens__c.getValues('ProjectServiceToken');
            
            // create an HTTPrequest object    
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setEndpoint('callout:ProjectService/'+ token.Token__c);
            req.setHeader('Content-Type', 'application/json');
            req.setBody(inputJson);    
            
            // create a new HTTP object
            Http http = new Http();
            HTTPResponse res = http.send(req);
            Opportunity oppo = new Opportunity(Id=opportunityObject.Id);
            if(res.getStatusCode() == 201){
                oppo.StageName = 'Submitted Project';                
            }else{
                oppo.StageName = 'Resubmit Project';
            }
            update oppo;     
        }
        
    } 
}