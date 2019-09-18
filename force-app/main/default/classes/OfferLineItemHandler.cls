public class OfferLineItemHandler extends TriggerHandler {
    
    public override void beforeInsert() {
        Logger.push();
        calculateTotal(Trigger.new);
        Logger.pop();
    }

	public override void beforeUpdate() {
        Logger.push();
        calculateTotal(Trigger.new);
        Logger.pop();
    }

    public static void calculateTotal(List<sObject> records){
        
        for (sObject theRecord : records) {
            Decimal UnitPrice =  (Decimal) theRecord.get('UnitPrice__c');
            Decimal Discount =  (Decimal) theRecord.get('Discount__c');
            Decimal Quantity =  (Decimal) theRecord.get('Quantity__c');
            Decimal TotalPrice = UnitPrice * Quantity;
            TotalPrice = TotalPrice - (TotalPrice * (Discount/100));
            theRecord.put('TotalPrice__c', TotalPrice);
        }
    }
}