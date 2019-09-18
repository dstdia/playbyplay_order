@isTest
private class Test_ContactAndAccounts {
    
    @isTest
    private static void insertSingleAccount() {
        
        Test.startTest();
        createAccounts(1, true);
        Test.stopTest();
        
    }
    
    @isTest
    private static void insertBulkAccounts() {
       Test.startTest();
        createAccounts(200, true);
        Test.stopTest(); 
    }
    
    @isTest
    private static void updateSingleAccount() {
        
        Account acc = createAccounts(1, true)[0];
        
        Test.startTest();
        update acc;
        Test.stopTest();
        
    }
    
    @isTest
    private static void updateBulkAccounts() {
        
        List<Account> lAccs = createAccounts(200, true);
        
        Test.startTest();
        update lAccs;
        Test.stopTest();
        
    }
    
    private static List<Account> createAccounts(Integer iAccountNo, Boolean doSave) {
        
        List<Account> newAccs = new List<Account>();
        
        for (Integer i = 0; i < iAccountNo; i++) {
            
           newAccs.add(
               new Account(
                Name = 'Testaccount ' + i,
                ExtId__c = 'T-' + i
            ));
        }
        
        if (doSave) {
            upsert newAccs ExtId__c;
        }
        return newAccs;
    }
    
    

}