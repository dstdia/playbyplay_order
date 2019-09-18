public class Trg_AccountHandler extends TriggerHandler {
    
    public static Set<Id> resetCount;
    
    static {
        resetCount = new Set<Id>();
    }

    public override void beforeInsert() {
        
        Logger.push();
        
        resetCounter();
        increaseCount();
        
        Logger.pop();
    }
        
    public override void beforeUpdate() {
        
        Logger.push();
        
        resetCounter();
        increaseCount();
        
        Logger.pop();
    }
    
    public override void afterUpdate() {
        
        Logger.push();
        
        increaseCountAfter();
        
        Logger.pop();
    }
        
        private void increaseCount() {
            
            if (canRunOnce('increaseCount') 
                && TriggerHandler.getTopHandlerName() == 'Trg_AccountHandler'){
                for (Account a : (List<Account>)Trigger.New) {
        			a.Count__c = (a.Count__c == NULL) ? 1 : a.Count__c +1;
    			}
            }    
        }
    	
    private void resetCounter() {
        
        for (Account acc : (List<Account>) Trigger.new) {
            if (!resetCount.contains(acc.Id)) {
                acc.Count__c = 0;
                resetCount.add(acc.Id);
            }
        }
    }
    
    private void increaseCountAfter() {
        
        List<Account> lAccs = [SELECT Id, Count__c, Description FROM Account WHERE Id IN: Trigger.newMap.keySet()];
            
            for (Account a : lAccs) {
        		a.Count__c = (a.Count__c == NULL) ? 1 : a.Count__c +1;
    		}
            
            try {
                // this will bypass the functionality next time
                TriggerHandler.bypass('Trg_AccountHandler');
                update lAccs;
                TriggerHandler.clearBypass('Trg_AccountHandler');
            } catch (Exception e) {
                System.debug('And then this happened: ' + e.getMessage());
            }
    }
}