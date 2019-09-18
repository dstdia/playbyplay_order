trigger OfferLineItem on OfferLineItem__c (before insert, before update) {
    
    new OfferLineItemHandler().run(); 

}