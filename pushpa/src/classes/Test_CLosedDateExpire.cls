@isTest
public class Test_CLosedDateExpire{
    static testmethod void closedopportunity(){
        
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];

        
        User usr=new user(LastName = 'Test',
                           FirstName='me',
                           Alias = 'tm',
                           Email = 'test.me@asdf.com',
                           Username = 'user.=@asdf.com',
                           ProfileId = profileId.id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US');
            
        insert usr;
        
        Opportunity opp=new opportunity(name='test',ownerid=usr.id,stagename='prospect',closedate=date.newinstance(2018,8,20));
        insert opp;
        
        test.starttest();
        N_ClosedDateExpire.testopportunitymail();
        test.stoptest();
       } 
    
}