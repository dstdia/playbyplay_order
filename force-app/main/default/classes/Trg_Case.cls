/**
 * Trigger logic for Cases:
 * 
 * 
 */ 
public class Trg_Case extends TriggerHandler {
    
    /* TRIGGER OPERATION METHOD */
    public override void afterInsert() {
        rollUpOpenCases((List<Case>) Trigger.new);
    }
    
    public override void afterUpdate() {
        rollUpOpenCases((List<Case>) Trigger.new);
    }
    
    public override void afterDelete() {
        rollUpOpenCases((List<Case>) Trigger.old);
    }
    
    public override void afterUndelete() {
        rollUpOpenCases((List<Case>) Trigger.new);
    }
    
    /* SERVICE METHODS */
    
    /**
     * Rollup the current number of open cases to the parent Account (if any)
     * 
     */  
    private void rollUpOpenCases(List<Case> cases){
        
        Map<Id, Account> accountMap = new Map<Id, Account>();
        
        for (Case c : cases) {
            
            if (c.AccountId != NULL){
                accountMap.put(c.AccountId, NULL);   
            }
        }
        
        accountMap = new Map<Id, Account>([
            SELECT  Id,
                    OpenCaseCount__c
            FROM    Account
            WHERE   Id IN: accountMap.keySet()       
        ]);
        
        List<AggregateResult> caseCountResult = [
            SELECT  Count(Id) CaseCount, 
                    AccountId 
            FROM    Case
            WHERE   isClosed = FALSE 
            AND     AccountId IN: accountMap.keySet() GROUP BY AccountId];
        
        for (AggregateResult ar : caseCountResult) {
            Account acc = accountMap.get((Id) ar.get('AccountId'));
            acc.OpenCaseCount__c = (Decimal) ar.get('CaseCount');
        }    
        update accountMap.values();
    }
}