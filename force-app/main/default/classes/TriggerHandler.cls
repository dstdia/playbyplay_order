/**
 * This framework is created by By Kevin O'Hara - Published: May, 2014
 * at https://developer.salesforce.com/page/Trigger_Frameworks_and_Apex_Trigger_Best_Practices
 * URL on GitHub: https://github.com/kevinohara80/sfdc-trigger-framework
 *
 * Enhanced version for DIA by Daniel Stange
 *
 * @author  Kevin O'Hara
 * @author  Daniel Stange
 * @version 1.1
 *
 * VERSION HISTORY
 * 1.0  May 2014    Kevin O'Hara    Published version
 * 1.1  2016        Daniel Stange   Adjusted version. Added topHandler, runOnce methods
 */
global virtual class TriggerHandler {

    // static map of handlername, times run() was invoked
    private static Map<String, LoopCount> loopCountMap;
    private static Set<String> bypassedHandlers;
    @TestVisible
    private static String topHandlerName;
    private static Map<String, Boolean> runOnce;

    // the current context of the trigger, overridable in tests
    @TestVisible
    private TriggerContext context;

    // the current context of the trigger, overridable in tests
    @TestVisible
    private Boolean isTriggerExecuting;

    // static initialization
    static {
        loopCountMap = new Map<String, LoopCount>();
        bypassedHandlers = new Set<String>();
        runOnce = new Map<String, Boolean>();
    }

    /* Static methods */
    // FKR: extension for recursion management
    global static Boolean checkRunOnce(String handlerAndMethodName) {

        if (null==runOnce.get(handlerAndMethodName) ) {
            runOnce.put(handlerAndMethodName, false);
            return true;
        }

        return false;
    }

    // constructor
    global TriggerHandler() {

        this.setTriggerContext();
        if (null==TriggerHandler.topHandlerName) {
            TriggerHandler.topHandlerName=getHandlerName();
        }
    }

    /***************************************
    * global instance methods
    ***************************************/

    // main method that will be called during execution
    global void run() {

        if (!validateRun()) return;

        addToLoopCount();

        // dispatch to the correct handler method
        if (this.context == TriggerContext.BEFORE_INSERT) {
            this.beforeInsert();
        }
        else if (this.context == TriggerContext.BEFORE_UPDATE) {
            this.beforeUpdate();
        }
        else if (this.context == TriggerContext.BEFORE_DELETE) {
            this.beforeDelete();
        }
        else if (this.context == TriggerContext.AFTER_INSERT) {
            this.afterInsert();
        }
        else if (this.context == TriggerContext.AFTER_UPDATE) {
            this.afterUpdate();
        }
        else if (this.context == TriggerContext.AFTER_DELETE) {
            this.afterDelete();
        }
        else if (this.context == TriggerContext.AFTER_UNDELETE) {
            this.afterUndelete();
        }
    }

    global void setMaxLoopCount(Integer max) {

        String handlerName = getHandlerName();

        if (!TriggerHandler.loopCountMap.containsKey(handlerName)) {
            TriggerHandler.loopCountMap.put(handlerName, new LoopCount(max));
        }
        else {
            TriggerHandler.loopCountMap.get(handlerName).setMax(max);
        }
    }

    global void clearMaxLoopCount() {
        this.setMaxLoopCount(-1);
    }

    // FKR: method to invoke the control of method executions.
    global Boolean canRunOnce(String methodName) {
        return checkRunOnce(getHandlerName()+'.'+methodName);
    }

    /***************************************
    * global static methods
    ***************************************/

    global static void bypass(String handlerName) {
        TriggerHandler.bypassedHandlers.add(handlerName);
    }

    global static void clearBypass(String handlerName) {
        TriggerHandler.bypassedHandlers.remove(handlerName);
    }

    global static Boolean isBypassed(String handlerName) {
        return TriggerHandler.bypassedHandlers.contains(handlerName);
    }

    global static void clearAllBypasses() {
        TriggerHandler.bypassedHandlers.clear();
    }

    // FKR: extension for recursion management
    global static String getTopHandlerName() {
        return topHandlerName;
    }

    // FKR: method to reset the control of method executions.
    global static void resetRun() {
        runOnce = new Map<String, Boolean>();
    }
    /***************************************
    * private instancemethods
    ***************************************/

    @TestVisible
    private void setTriggerContext() {
        this.setTriggerContext(null, false);
    }

    @TestVisible
    private void setTriggerContext(String ctx, Boolean testMode) {

        if (!Trigger.isExecuting && !testMode) {
            this.isTriggerExecuting = false;
            return;
        }
        else {
            this.isTriggerExecuting = true;
        }

        if ((Trigger.isExecuting && Trigger.isBefore && Trigger.isInsert) ||
                (ctx != null && ctx == 'before insert')) {
            this.context = TriggerContext.BEFORE_INSERT;
        }
        else if ((Trigger.isExecuting && Trigger.isBefore && Trigger.isUpdate) ||
                (ctx != null && ctx == 'before update')){
            this.context = TriggerContext.BEFORE_UPDATE;
        }
        else if ((Trigger.isExecuting && Trigger.isBefore && Trigger.isDelete) ||
                (ctx != null && ctx == 'before delete')) {
            this.context = TriggerContext.BEFORE_DELETE;
        }
        else if ((Trigger.isExecuting && Trigger.isAfter && Trigger.isInsert) ||
                (ctx != null && ctx == 'after insert')) {
            this.context = TriggerContext.AFTER_INSERT;
        }
        else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isUpdate) ||
                (ctx != null && ctx == 'after update')) {
            this.context = TriggerContext.AFTER_UPDATE;
        }
        else if ((Trigger.isExecuting && Trigger.isAfter && Trigger.isDelete) ||
                (ctx != null && ctx == 'after delete')) {
            this.context = TriggerContext.AFTER_DELETE;
        }
        else if((Trigger.isExecuting && Trigger.isAfter && Trigger.isUndelete) ||
                (ctx != null && ctx == 'after undelete')) {
            this.context = TriggerContext.AFTER_UNDELETE;
        }
    }

    // increment the loop count
    @TestVisible
    private void addToLoopCount() {

        String handlerName = getHandlerName();

        if (TriggerHandler.loopCountMap.containsKey(handlerName)) {

            Boolean exceeded = TriggerHandler.loopCountMap.get(handlerName).increment();

            if (exceeded) {
                Integer max = TriggerHandler.loopCountMap.get(handlerName).max;
                throw new TriggerHandlerException('Maximum loop count of ' + String.valueOf(max) + ' reached in ' + handlerName);
            }
        }
    }

    // make sure this trigger should continue to run
    @TestVisible
    private Boolean validateRun() {

        if (!this.isTriggerExecuting || this.context == null) {
            throw new TriggerHandlerException('Trigger handler called outside of Trigger execution');
        }

        if (TriggerHandler.bypassedHandlers.contains(getHandlerName())) {
            return false;
        }

        return true;
    }

    @TestVisible
    global String getHandlerName() {
        return String.valueOf(this).substring(0, String.valueOf(this).indexOf(':'));
    }

    /***************************************
    * context methods
    ***************************************/

    // context-specific methods for override
    @TestVisible
    global protected virtual void beforeInsert(){}

    @TestVisible
    global protected virtual void beforeUpdate(){}

    @TestVisible
    global protected virtual void beforeDelete(){}

    @TestVisible
    global protected virtual void afterInsert(){}

    @TestVisible
    global protected virtual void afterUpdate(){}

    @TestVisible
    global protected virtual void afterDelete(){}

    @TestVisible
    global protected virtual void afterUndelete(){}

    /***************************************
    * inner classes
    ***************************************/

    // inner class for managing the loop count per handler
    @TestVisible
    global class LoopCount {

        private Integer max;
        private Integer count;

        global LoopCount() {
            this.max = 5;
            this.count = 0;
        }

        global LoopCount(Integer max) {
            this.max = max;
            this.count = 0;
        }

        global Boolean increment() {
            this.count++;
            return this.exceeded();
        }

        global Boolean exceeded() {

            if (this.max < 0) {
                return false;
            }

            if (this.count > this.max) {
                return true;
            }

            return false;
        }

        global Integer getMax() {
            return this.max;
        }

        global Integer getCount() {
            return this.count;
        }

        global void setMax(Integer max) {
            this.max = max;
        }
    }

    // possible trigger contexts
    @TestVisible
    private enum TriggerContext {
        BEFORE_INSERT, BEFORE_UPDATE, BEFORE_DELETE,
        AFTER_INSERT, AFTER_UPDATE, AFTER_DELETE,
        AFTER_UNDELETE
    }

    // exception class
    global class TriggerHandlerException extends Exception {}
}