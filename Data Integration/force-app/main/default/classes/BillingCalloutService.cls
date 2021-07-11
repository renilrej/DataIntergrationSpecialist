public class BillingCalloutService 
{
    //Implement business and callout logic methods here
    @future(callout=true)
    public static void callBillingService(String projectRef, Decimal billableAmount)
    {
        ServiceCredentials__c serviceCred = ServiceCredentials__c.getValues('BillingServiceCredential');

        BillingServiceProxy.project projectInst = new BillingServiceProxy.project();
        projectInst.username = serviceCred.Username__c;
        projectInst.password = serviceCred.Password__c;
        projectInst.billAmount = billableAmount;
        
        BillingServiceProxy.InvoicesPortSoap11 invPortSoapInst = new BillingServiceProxy.InvoicesPortSoap11();
        String response = invPortSoapInst.billProject(projectInst);
        
        List<Project__c> lstOfProjects = new List<Project__c>();
        if(response != null && response.equalsIgnoreCase('OK')){
            List<Project__c> lstOfPrjts = [SELECT Status__c FROM Project__c WHERE ProjectRef__c = :projectRef];
            for(Project__c prjt : lstOfPrjts){
                prjt.Status__c = 'Billed';
                
                lstOfProjects.add(prjt);
            }
            
            UPDATE lstOfProjects;
        }
    }
}