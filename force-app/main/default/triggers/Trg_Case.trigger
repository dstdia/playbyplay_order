trigger Trg_Case on Case (
    before insert, after insert, 
    before update, after update, 
    before delete, after undelete) {
        
        new Trg_Case().run();

}