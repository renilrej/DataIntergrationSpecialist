@isTest
private class ProjectCalloutServiceTest 
{
    //Implement mock callout tests here
    static testMethod void TestOKPostOpportunityToPMS()
    {
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        Opportunity newOpp = New Opportunity();
        newOpp.Name		= 'Test Opp1';
        newOpp.AccountId	= acc.Id;
        newOpp.Type 		= 'New Project';
        newOpp.Amount 	= 100;
        newOpp.CloseDate 	= Date.today();
        newOpp.StageName 	= 'Submitted Project';
        insert newOpp;
        
        //create the Custom Settings
        ServiceTokens__c servToken = new ServiceTokens__c();
        servToken.Name = 'ProjectServiceToken';
        servToken.Token__c = 'qwertyuiopnjhgft';
        insert servToken;
        
        Opportunity opp = [SELECT Id, Name FROM Opportunity WHERE Name = 'Test Opp1' LIMIT 1];
        List<Id> oppIds = new List<Id>();
        oppIds.add(opp.Id);
        
        //set mock callout class
        Test.setMock(HttpCalloutMock.class, new ProjectCalloutServiceMock());
        
        Test.startTest();
        	ProjectCalloutService.postOpportunityToPMS(oppIds);
        Test.stopTest();
        
        // Verify that the response received contains fake values        
        opp = [select StageName from Opportunity where id =: opp.Id];
        System.assertEquals('Submitted Project',opp.StageName);
    }
    
    static testMethod void TestBadPostOpportunityToPMS()
    {
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        Opportunity oppNew = new Opportunity();
        oppNew.Name			= 'Test Opp2';
        oppNew.AccountId	= acc.Id;
        oppNew.Type 		= 'New Project';
        oppNew.Amount 		= 100;
        oppNew.CloseDate 	= Date.today();
        oppNew.StageName 	= 'Resubmit Project';
        insert oppNew;
        
        ServiceTokens__c token = new ServiceTokens__c();
        token.Name 		= 'ProjectServiceToken';
        token.Token__c	= 'qwertyutipoyu';
        insert token;
        
        Opportunity opp = [SELECT Id, Name FROM Opportunity WHERE Name = 'Test Opp2' LIMIT 1];
        List<Id> oppIds = new List<Id>();
        oppIds.add(opp.Id);
        
      	//set mock callout class
      	Test.setMock(HttpCallOutMock.class, new ProjectCalloutServiceMockFailure());
        
        //call my callout class
        Test.startTest();
        	ProjectCalloutService.postOpportunityToPMS(oppIds);
        Test.stopTest();
        
        // Verify that the response received contains fake values        
        opp = [select StageName from Opportunity where id =: opp.Id];
        System.assertEquals('Resubmit Project',opp.StageName);
    }
}