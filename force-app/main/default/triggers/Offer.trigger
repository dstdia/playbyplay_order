trigger Offer on Offer__c (before insert, before update) {

    new OfferHandler().run();
}