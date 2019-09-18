trigger OfferBundle on OfferBundle__c (before insert, before update) {
    
    new BundleHandler().run(); 
}