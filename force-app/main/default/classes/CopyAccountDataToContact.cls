public with sharing class CopyAccountDataToContact {
    
    @InvocableMethod
    public static void copyAddressFromAccount(List<Account> accounts) {
        
        System.debug('CopyAccountDataToContact - Limits:');
        LimitsHelper.logAll();
    }

}