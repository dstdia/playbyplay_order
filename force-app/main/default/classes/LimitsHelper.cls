public without sharing class LimitsHelper {
    
    public static void logAll () {
        
        System.debug(
            String.format('SOQL Queries: {0} of {1}', 
                          New List<Object>{System.Limits.getQueries(), System.Limits.getLimitQueries()}
                         ));
        System.debug(
            String.format('DML Statements: {0} of {1}', 
                          New List<Object>{System.Limits.getDmlStatements(), System.Limits.getLimitDmlStatements()}
                         ));
        System.debug(
            String.format('SOQL Rows: {0} of {1}', 
                          New List<Object>{System.Limits.getQueryRows(), System.Limits.getLimitQueryRows()}
                         ));
        System.debug(
            String.format('DML Rows: {0} of {1}', 
                          New List<Object>{System.Limits.getDMLRows(), System.Limits.getLimitDMLRows()}
                         ));
        System.debug(
            String.format('CPU Time: {0} of {1}', 
                          New List<Object>{System.Limits.getCpuTime(), System.Limits.getLimitCpuTime()}
                         ));
                     
        
    }

}