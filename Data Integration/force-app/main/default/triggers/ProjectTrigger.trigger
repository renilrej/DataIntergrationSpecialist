trigger ProjectTrigger on Project__c (after update) 
{
    //Call the Billing Service callout logic here
    if(Trigger.isAfter && Trigger.isUpdate)
    {
        for(Project__c proj : Trigger.new)
        {
            if(proj.status__c != null && proj.status__c.equals('Billable'))
            {
                BillingCalloutService.callBillingService(proj.ProjectRef__c, proj.Billable_Amount__c);
            }
        }
    }
}