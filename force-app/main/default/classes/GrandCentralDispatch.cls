public without sharing class GrandCentralDispatch {
    
    private static String topHandler;
    private static Set<Id> processedRecordIds;
    private static Set<String> bypassMethods;
    
    static {
        processedRecordIds = new Set<ID>();
        bypassMethods = new Set<String>();
    }
    
    public static void logExecutionStart(String method) {
        
    }
    
    public static void logExecutionEnd(String method) {
        
    }
    
    public static void setTopHandler(String methodName) {
        
        if (topHandler == NULL) {
            topHandler = methodName;
        } 
    }
    
    public static String getTopHandler() {
        
        return topHandler;
    }
    
    
    
    

}