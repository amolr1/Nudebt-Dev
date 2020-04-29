@isTest
public class Test_Attorney_StaticVariableUtility {
    @isTest static void schedulerTest () {
        Attorney_StaticVariableUtility obj = new Attorney_StaticVariableUtility ();
        Attorney_StaticVariableUtility.dateToUTC (Date.Today ());
    }
    
    private static testMethod void test_reProcessRecordCheck(){
        Set<String>stringSet = New Set<String>();
        stringSet.Add('TEst1');
        string IntegrationReason = 'TEst1';
        Attorney_StaticVariableUtility.reProcessRecordCheck(stringSet,IntegrationReason);
        Attorney_StaticVariableUtility.convertToDecimal('3.0');
    }
    
     private static testMethod void test_reProcessConfigs(){
        Set<String>stringSet = New Set<String>();
      
        Attorney_StaticVariableUtility.reProcessConfigs('Program',true);
        
    }
}