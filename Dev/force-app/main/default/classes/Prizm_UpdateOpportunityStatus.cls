@RestResource(urlMapping='/updateOpportunityStatus/*')
global class Prizm_UpdateOpportunityStatus{

    @HttpPost
    global static String updateOpportunityStatus() {
        String jsonStr;
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        if(!Test.isRunningTest()){
        	 jsonStr = RestContext.request.requestBody.toString();
        } else {
            List<OpportunityStatusWrapper> OppoWrapperList = new List<OpportunityStatusWrapper>();
            OpportunityStatusWrapper oppoW = new OpportunityStatusWrapper();
            oppoW.OpportunityId = [Select Id from Opportunity limit 1].Id;
            oppoW.Status = 'Closed Won';
            OppoWrapperList.add(oppoW);
            jsonStr = JSON.serialize(OppoWrapperList);
        }
        List<OpportunityStatusWrapper> OppoWrapperList = (List<OpportunityStatusWrapper>)JSON.deserialize(jsonStr,List<OpportunityStatusWrapper>.class);
        
        List<Opportunity> OpportunityList = new List<Opportunity>();
        
        for(OpportunityStatusWrapper OppoWrap : OppoWrapperList){
            Opportunity oppo = new Opportunity();
            oppo.Id = oppoWrap.OpportunityId;
            oppo.StageName = oppoWrap.Status;
            OpportunityList.add(oppo);
            
        }
        Update OpportunityList;
        return 'true';
        
    }
    
    public class OpportunityStatusWrapper{
        public string OpportunityId;
        public String Status;
        
        public OpportunityStatusWrapper(){
            OpportunityId = '';
            Status = '';
        }
    }
}