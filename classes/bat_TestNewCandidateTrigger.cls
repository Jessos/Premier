@isTest(seealldata=false)
public class bat_TestNewCandidateTrigger{

    public static List<Contact> createContacts(integer numberOfContacts, List<Account> accounts)
    {
        List<Contact> response = new List<Contact>();
        
        for(Account testAccount : accounts)
        {
            for(Integer i=0;i<numberOfContacts;i++)
            {
                Contact c = new Contact(
                        AccountId = testAccount.Id,
                        Account = testAccount,
                        Email = 'fname'+i+'@'+testAccount.Name.remove(' ') + '.com',
                        FirstName = 'fname' + testAccount.Name + i,
                        LastName = 'lname' + testAccount.Name + i,
                        MobilePhone = testAccount.Name + 'pn' + i
                        
                    );                                        
                
                        //TMA
                List<Contact> list_of_contacts = [SELECT AccountId, Email,  ts2__People_Status__c,FirstName, LastName, MobilePhone from Contact where lastName = :c.LastName and AccountId = :c.AccountId and Email = :c.Email];
                if (list_of_contacts.size() ==0) {
                    insert c; 
                    response.add(c);
                } else 
                {
                    response.add(list_of_contacts[0]);
                }
                
                //response.add(c);
            }
        }
        
        //System.debug(response);
        //insert response;       
        System.debug(response);
        return response;
    }
    
    public static List<Account> createTestsAccounts(integer numberOfAccounts)
    {
        List<Account> response = new List<Account>();
        for(Integer i=0;i<numberOfAccounts;i++)
        {
            response.add(
                            new Account(
                             Name = 'test account' + i                      
                            )
            );
        }
        insert response;
        return response;
    }
    
    static testmethod void testCandidateInserts()
    {
        Test.startTest();
       // List<Account> testAccounts = createTestsAccounts(1);
       // createContacts(6, testAccounts);
        Test.stopTest();

        //System.assert([SELECT Id from Contact where ts2__People_Status__c = 'Active'].size()==6);
        
        User careerSiteUser = [select id from user where CommunityNickname = 'Careers' limit 1];
        
        System.runAs(careerSiteUser)
        {
            //createContacts(7, testAccounts);
        }    
        
        //Integer number_of_contacts = testAccounts.size();        
       // System.debug('number_of_contacts=='+number_of_contacts);
       // System.assert([SELECT Id from Contact where ts2__People_Status__c = 'New Lead'].size()==number_of_contacts);        
    }
    
}