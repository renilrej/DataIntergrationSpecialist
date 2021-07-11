// This annotation is need for web service class so that the external system can interact with salesforce. urlMapping saying which object that you want to connect.
@RestResource(urlMapping='/Project/*') 
global class ProjectRESTService 
{
    //Implement service logic here
    @HttpPost // this annotation says what the external system can do with salesforce data.(GET,POST,PUT,DELETE,PATCH)
    global static String postProjectData(String ProjectRef, String ProjectName, String OpportunityId, Date StartDate, Date EndDate, Double Amount, String Status)
    {
        String retStr = 'Error'; // should return ERROR if anything fails
        
        //Database. setSavepoint() is used to define a point at which DML operations can be rolled back. 
        //If any error occurs during DML Operations, that contains many statements, 
        //the application will be rolled back to the most recent save point and the entire transaction will not be aborted.
        SavePoint sp = Database.setSavePoint(); 

        try
        {
            List<Opportunity> oppListToUpdate = new List<Opportunity>();

            if(OpportunityId != null)
            {
                Opportunity opp = [SELECT Id, Name, DeliveryInstallationStatus__c FROM Opportunity WHERE Id =: OpportunityId];
                opp.DeliveryInstallationStatus__c = 'In Progress';
                oppListToUpdate.add(opp);   
            }
            update oppListToUpdate;

            List<Project__c> projList = new List<Project__c>();

            Project__c proj = new Project__c();
            proj.ProjectRef__c      = ProjectRef;
            proj.Name               = ProjectName;
            proj.Opportunity__c     = OpportunityId;
            proj.Start_Date__c      = StartDate;
            proj.End_Date__c        = EndDate;
            proj.Billable_Amount__c = Amount;
            proj.Status__c          = Status;

            projList.add(proj);

            upsert projList;

            retStr = 'OK';
        }
        catch(Exception ex)
        {
            Database.rollback(sp);
            retStr = ex.getMessage();
        }

        return retStr;
    }
}