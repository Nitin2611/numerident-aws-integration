public class handleAwsException extends Exception {
    public static void LogException(Exception e) {
        try {
		    String stackTrace = e.getStackTraceString().substringBefore('\n');
		    String className = stackTrace.substringAfter('.').substringBefore('.');	
        	String methodName = stackTrace.substringBefore(':').substringAfter(className).substringAfter('.');
            String QueryLimit = '1. SOQL Queries used / SOQL Queries allowed: ' + Limits.getQueries() + '/' + Limits.getLimitQueries();
            String DMLimit = '2. Number of records queried so far /  Number allowed: ' + Limits.getDmlRows() + '/' + Limits.getLimitDmlRows();
            String DMLStat = '3. Number of DML statements used so far / Number allowed: ' +  Limits.getDmlStatements() + '/' + Limits.getLimitDmlStatements();   
            String CPUT = '4. Amount of CPU time (in ms) used so far / CPU usage time (in ms) allowed: ' + Limits.getCpuTime() + '/' + Limits.getLimitCpuTime();
            String heapLimit = '5. Amount of heap size used so far / heap size allowed: ' + Limits.getHeapSize() + '/' + Limits.getLimitHeapSize();

            AWS_Error_Log__c exc = new AWS_Error_Log__c (
                Govt_Limit_in_Executing_Code__c = String.format(
                    '{0}\n{1}\n{2}\n{3}\n{4}',
                    new List<string>{QueryLimit, DMLimit, DMLStat, CPUT, heapLimit}
                ),
                Exception_Message__c = e.getMessage(),
                Exception_Type__c = e.getTypeName(),
                Line_Number__c = e.getLineNumber(),
                More_Details__c = e.getStackTraceString()
            );
            database.insert(exc);
        } finally {
        
        }
    }

    // For storing bad request
    public static void logBadRequest(String methodName, String contentVersionId, String ordonnanceId, String fileName, String response, String statusCode) {
        try {
            // AWS_Error_Log__c exc = new AWS_Error_Log__c (
            //     Govt_Limit_in_Executing_Code__c = String.format(
            //         '{0}\n{1}\n{2}\n{3}\n{4}',
            //         new List<string>{QueryLimit, DMLimit, DMLStat, CPUT, heapLimit}
            //     ),
            //     Exception_Message__c = e.getMessage(),
            //     Exception_Type__c = e.getTypeName(),
            //     Line_Number__c = e.getLineNumber(),
            //     More_Details__c = e.getStackTraceString()
            // );
            // database.insert(exc);
        } catch (Exception e) {
            
        }
    }
}