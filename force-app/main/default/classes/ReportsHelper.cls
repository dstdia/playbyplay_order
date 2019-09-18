public class ReportsHelper {
    
     public static void  ReportsFilters(){
            List <Report> reportList = [select id ,Name from Report where format !='MultiBlock' LIMIT 1000];
        for(Integer i=0;i<reportList.size();i++){
    
            String reportId = (String)reportList.get(i).get('Id');
            String Name = (String)reportList.get(i).get('Name');
    
            Reports.ReportResults results = Reports.ReportManager.runReport(reportId);
            Reports.ReportMetadata rm = results.getReportMetadata();
    
           system.debug('---Name---'+Name);
            Reports.ReportType rt = rm.getReportType();
    
            System.debug('Report Type'+rt.getType());
    
            for(Reports.ReportFilter rf : rm.getreportFilters()){
                if(rf!=null){
                    system.debug('---col name---'+rf.getcolumn()+'=='+rf.getValue());
    
                }
            }
       }
     }}