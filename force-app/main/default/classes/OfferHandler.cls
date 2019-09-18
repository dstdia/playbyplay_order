public class OfferHandler extends TriggerHandler {

    public override void beforeInsert() {
        calculateTotal(Trigger.new);
    }

	public override void beforeUpdate() {
        calculateTotal(Trigger.new);
    }

    
    public static void calculateTotal(List<sObject> records){
        
        for (sObject theRecord : records) {
            Decimal UnitPrice =  (Decimal) theRecord.get('BundleSum__c');
            Decimal Discount =  (Decimal) theRecord.get('Discount__c');
            Decimal TotalPrice = UnitPrice - (UnitPrice * (Discount/100));
            theRecord.put('TotalPrice__c', TotalPrice);
        }
    }
}