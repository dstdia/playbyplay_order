trigger Account on Account (before insert, before update, before delete) {
    
    Logger.push();
    Logger.log('Entering Account Trigger');
    Logger.logTrigger(Trigger.operationType, 'Account Trigger entry');
    
    /**
     * That's a worst practice trigger. Let's clean this up later...
     */ 
    switch on Trigger.operationType {
        
        when BEFORE_INSERT, BEFORE_UPDATE {
            
            Logger.push();
            
            for (Account a : Trigger.New) {
                
                Logger.log('Account recursion count in Trigger.new was ' + a.Count__c);
                
                Account oldAcc;
                
                if (Trigger.oldMap!=NULL||a.Id!=NULL) {
                    oldAcc = Trigger.oldMap.get(a.Id);
                    Logger.log('Account recursion count in Trigger.old was ' + oldAcc.Count__c);
                }
                
                if(!Trg_Accounthandler.resetCount.contains(a.Id)) {
                    
                    Logger.log('Reset the recursion count ');
                    
                    a.Count__c = 0;
                    Trg_AccountHandler.resetCount.add(a.Id);
                }
                
                a.Count__c = (a.Count__c == NULL) ? 1 : a.Count__c +1;
                Logger.log('Account recursion count is now ' + a.Count__c);
            }
        } 
        
        when else {
            List<Account> lAccs = [SELECT Id, Count__c, Description FROM Account WHERE Id IN: Trigger.newMap.keySet()];
            
            for (Account a : lAccs) {
                a.Count__c = (a.Count__c == NULL) ? 1 : a.Count__c +1;
            }
            
            try {
                //update lAccs;
            } catch (Exception e) {
                System.debug('And then this happened: ' + e.getMessage());
            }
            
        }
    }
    
    Logger.log('Exiting Account Trigger');
    Logger.pop();
    
}