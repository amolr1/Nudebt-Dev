public class ProgramFeeTemplateMappingTriggerHandler {
    
    public static Map<String, Map<String, String>> programAndItsMappingValuesMap = new Map<String, Map<String, String>>();
    public static Set<Id> processedProgramIdSet = new Set<Id>();
    public static Map<String, String> originalAndNewPolicyGroupIdMap = new Map<String, String> ();
    
    public static void ProgramFeeTemplateMapping(Map<Id, nu_dse__Program__c> programOldMap, List<nu_dse__Program__c> programList) {
    
        List<nu_dse__Program__c> ndsProgramList = new List<nu_dse__Program__c> ();
        List<nu_dse__Program__c> ndsProgramFinalList = new List<nu_dse__Program__c> ();
        Set<Id> processorIdSet = new Set<Id>();
        Set<Id> feeTemplateIdSet = new Set<Id>();
        Set<String> feeTemplateNameSet = new Set<String>();
        
        Set<String> targetFeeTemplateKeySet = new Set<String>();
        Set<String> targetPolicyGroupIdSet = new Set<String>();
        Map<String, Id> targetKeySetAndItsPolicyGroupId = new Map<String, Id>();
        
        for (nu_dse__Program__c programInst : programList) {
            //PDI-684: programOldMap.get(programInst.Id).DNL_Status__c=='Lead Active'  //Added Converted status for S20-320
            if ((processedProgramIdSet.contains(programInst.Id) == False && (programInst.DNL_Status__c != programOldMap.get(programInst.Id).DNL_Status__c)
                    && programInst.DNL_Status__c == 'Pre-TILA Signed' && (programOldMap.get(programInst.Id).DNL_Status__c=='Lead Active' || programOldMap.get(programInst.Id).DNL_Status__c=='Converted')
                    && programInst.nu_dse__Fee_Template__c != null && programInst.nu_dse__Processor__c != null)) {
                
                ndsProgramList.add(programInst);
                processorIdSet.add(programInst.nu_dse__Processor__c);
                feeTemplateIdSet.add(programInst.nu_dse__Fee_Template__c);
                
                processedProgramIdSet.add(programInst.Id);
            }
        }
        System.debug('ndsProgramList-->'+ndsProgramList);
        
        //Construction of Fee Template mapping based on Field Mapping records
        if (ndsProgramList.isEmpty() == False || Test.isRunningTest()) {
            
            if (originalAndNewPolicyGroupIdMap.isEmpty() == True) {
                
                for (nu_dse__Field_mapping__c fieldMappingInst : [SELECT Id, Original_Policy_Group_Id__c, New_Policy_Group_Id__c, 
                                                                    Trust_Account_Provider__c, Program_Portfolio__c,Program_Type__c,Amount_Category__c  //Program_Type__c
                                                                    FROM nu_dse__Field_mapping__c 
                                                                    WHERE nu_dse__Data_Mapping__r.Name = 'FeeTemplateAssignment-PreTILA_signed']) {
                    
                    if (String.isNotBlank(fieldMappingInst.Original_Policy_Group_Id__c) == True
                         && String.isNotBlank(fieldMappingInst.Trust_Account_Provider__c) == True
                         && String.isNotBlank(fieldMappingInst.New_Policy_Group_Id__c) == True) {
                         //S20-226 --> Changes done for this ticket...
                         //&& String.isNotBlank(fieldMappingInst.Program_Type__c) == True) {   //Replace:Program_Portfolio__c
                         //&& String.isNotBlank(fieldMappingInst.Amount_Category__c) == True) { Commention out Amount category just to make work for Timberline...
                         
                        String key = fieldMappingInst.Trust_Account_Provider__c + '_' + fieldMappingInst.Program_Type__c + '_' 
                                        + fieldMappingInst.Amount_Category__c + '_' + fieldMappingInst.Original_Policy_Group_Id__c;   //Replace
                        
                        if (originalAndNewPolicyGroupIdMap.containskey(key) == False) {
                            
                            originalAndNewPolicyGroupIdMap.put(key, fieldMappingInst.New_Policy_Group_Id__c);
                        }
                    }
                }
            }
            System.debug('originalAndNewPolicyGroupIdMap-->'+originalAndNewPolicyGroupIdMap);
            
            Map<Id, nu_dse__Processor__c>  processorMap = new Map<Id, nu_dse__Processor__c>([SELECT Id, nu_dse__Type__c 
                                                                                                FROM nu_dse__Processor__c 
                                                                                                WHERE Id IN : processorIdSet]);
            
            Map<Id, nu_dse__Fee_Template__c> originalFeeTemplateMap = new Map<Id, nu_dse__Fee_Template__c> ([SELECT Id, Portfolio_Name__c,Program_Type__c, Debt_Amount__c,
                                                                                                            nu_dse__GCS_Fee_Group_Id__c, nu_dse__RAMS_Fee_Group_Id__c,
                                                                                                            nu_dse__Settlement_Pct__c, Service_Fee_Percentage__c 
                                                                                                            FROM nu_dse__Fee_Template__c
                                                                                                            WHERE Id IN :feeTemplateIdSet]);   //Program_Type__c
            
            for (nu_dse__Program__c programInstance : ndsProgramList) {
                
                if (originalFeeTemplateMap.containsKey(programInstance.nu_dse__Fee_Template__c) == True 
                    && processorMap.containsKey(programInstance.nu_dse__Processor__c) == True) {
                    
                    nu_dse__Fee_Template__c  feeTemplateInst = originalFeeTemplateMap.get(programInstance.nu_dse__Fee_Template__c);
                    
                    nu_dse__Processor__c processorInst = processorMap.get(programInstance.nu_dse__Processor__c);
                        
                    if (processorInst.nu_dse__Type__c == 'RAMS' || processorInst.nu_dse__Type__c == 'GCS') {    
                        
                        ndsProgramFinalList.add(programInstance);
                        
                        String key = feeTemplateInst.Program_Type__c + '_' + feeTemplateInst.Debt_Amount__c + '_' 
                                    + feeTemplateInst.nu_dse__Settlement_Pct__c + '_' + feeTemplateInst.Service_Fee_Percentage__c + '_';  //Program_Type__c
                        
                        String targetFeeGroupId = '';
                        String policyGroupIdMapKey = '';
                        
                        System.debug('Generated - key-->'+key);
                        
                        if (processorInst.nu_dse__Type__c == 'GCS') {
                            
                            policyGroupIdMapKey = processorInst.nu_dse__Type__c + '_' + feeTemplateInst.Program_Type__c + '_' 
                                            + feeTemplateInst.Debt_Amount__c+ '_'+ feeTemplateInst.nu_dse__GCS_Fee_Group_Id__c;  //Program_Type__c
                            
                        } else if(processorInst.nu_dse__Type__c == 'RAMS') {
                            
                            policyGroupIdMapKey = processorInst.nu_dse__Type__c + '_' + feeTemplateInst.Program_Type__c + '_' 
                                            + feeTemplateInst.Debt_Amount__c+ '_'+ feeTemplateInst.nu_dse__RAMS_Fee_Group_Id__c; //Program_Type__c
                        }
                        
                        if (originalAndNewPolicyGroupIdMap.containsKey(policyGroupIdMapKey) == True) {
                            
                            targetFeeGroupId = originalAndNewPolicyGroupIdMap.get(policyGroupIdMapKey);
                        }
                        
                        System.debug('policyGroupIdMapKey-->'+policyGroupIdMapKey);
                        System.debug('targetFeeGroupId-->'+targetFeeGroupId);
                        
                        if (String.isNotBlank(targetFeeGroupId) == True) {
                            
                            key += targetFeeGroupId;
                            targetFeeTemplateKeySet.add(key);
                            targetPolicyGroupIdSet.add(targetFeeGroupId);
                            
                            System.debug('Generated - key-with fee Group Id->'+key);
                            System.debug('Generated - targetFeeTemplateKeySet->'+targetFeeTemplateKeySet);
                            System.debug('Generated - key-with fee Group targetPolicyGroupIdSet->'+targetPolicyGroupIdSet);
                        }
                    }
                }
            }
            
            if (ndsProgramFinalList.isEmpty() == False) {
                
                //Based on target policy group Id, Fee template is queried and generate a key string and Id map...
                if (targetPolicyGroupIdSet.isEmpty() == False) {
                    
                    for (nu_dse__Fee_Template__c  feeTemplateInst : [SELECT Id, Debt_Amount__c, Portfolio_Name__c,Program_Type__c, nu_dse__Settlement_Pct__c,   
                                                                    Service_Fee_Percentage__c, nu_dse__GCS_Fee_Group_Id__c, nu_dse__RAMS_Fee_Group_Id__c
                                                                    FROM nu_dse__Fee_Template__c WHERE (nu_dse__GCS_Fee_Group_Id__c IN : targetPolicyGroupIdSet 
                                                                    OR nu_dse__RAMS_Fee_Group_Id__c IN : targetPolicyGroupIdSet) AND
                                                                    (nu_dse__Settlement_Pct__c != null //replace AND Program_Type__c!= null AND Debt_Amount__c != null AND
                                                                    AND Service_Fee_Percentage__c != null)]) {
                        
                        //Portfolio Name, Debt Amount, Estimated Settlement %, Service Fee Percentage
                        
                        String key = feeTemplateInst.Program_Type__c + '_' + feeTemplateInst.Debt_Amount__c + '_' 
                                    + feeTemplateInst.nu_dse__Settlement_Pct__c + '_' + feeTemplateInst.Service_Fee_Percentage__c + '_';  //Program_Type__c
                        
                        System.debug('Generated - key-with target Policy Group Id->'+key);
                        
                        //Adding GCS Fee Group Id...
                        if (targetFeeTemplateKeySet.contains(key + feeTemplateInst.nu_dse__GCS_Fee_Group_Id__c) == True) {
                            
                            if (targetKeySetAndItsPolicyGroupId.containsKey(key + feeTemplateInst.nu_dse__GCS_Fee_Group_Id__c) == False) {
                                
                                targetKeySetAndItsPolicyGroupId.put(key + feeTemplateInst.nu_dse__GCS_Fee_Group_Id__c, feeTemplateInst.Id);
                            }
                        }
                        
                        //Adding RAMS Fee Group Id...
                        if (targetFeeTemplateKeySet.contains(key + feeTemplateInst.nu_dse__RAMS_Fee_Group_Id__c) == True) {
                            
                            if (targetKeySetAndItsPolicyGroupId.containsKey(key + feeTemplateInst.nu_dse__RAMS_Fee_Group_Id__c) == False) {
                                
                                targetKeySetAndItsPolicyGroupId.put(key + feeTemplateInst.nu_dse__RAMS_Fee_Group_Id__c, feeTemplateInst.Id);
                            }
                        }
                        
                        System.debug('Generated - key-with targetKeySetAndItsPolicyGroupId->'+targetKeySetAndItsPolicyGroupId);
                    }
                }
                
                Integer failedRecordCount = 0;
                                
                for (nu_dse__Program__c programInstance :ndsProgramFinalList) {
                    
                    nu_dse__Fee_Template__c  feeTemplateInst = originalFeeTemplateMap.get(programInstance.nu_dse__Fee_Template__c);
                    nu_dse__Processor__c processorInst = processorMap.get(programInstance.nu_dse__Processor__c);
                    
                    String key = feeTemplateInst.Program_Type__c + '_' + feeTemplateInst.Debt_Amount__c + '_' 
                                + feeTemplateInst.nu_dse__Settlement_Pct__c + '_' + feeTemplateInst.Service_Fee_Percentage__c + '_' ;  //Program_Type__c
                    
                    String policyGroupIdMapKey = '';
                    
                    if (processorInst.nu_dse__Type__c == 'GCS') {
                            
                        policyGroupIdMapKey = processorInst.nu_dse__Type__c + '_'+ feeTemplateInst.Program_Type__c + '_' + feeTemplateInst.Debt_Amount__c + '_' 
                                            + feeTemplateInst.nu_dse__GCS_Fee_Group_Id__c; //Program_Type__c:replace
                        
                    } else if(processorInst.nu_dse__Type__c == 'RAMS') {
                        
                        policyGroupIdMapKey = processorInst.nu_dse__Type__c + '_'+ feeTemplateInst.Program_Type__c + '_' + feeTemplateInst.Debt_Amount__c + '_' 
                                            + feeTemplateInst.nu_dse__RAMS_Fee_Group_Id__c;  //Program_Type__c:replace
                    }
                    
                    if (originalAndNewPolicyGroupIdMap.containsKey(policyGroupIdMapKey) == True) {
                        
                        key += originalAndNewPolicyGroupIdMap.get(policyGroupIdMapKey);
                    }
                    
                    System.debug('Generated - key- From ProgramInstance ->'+key);
                    
                    //Assigning Fee template if the current Fee template matches relavent fee item...
                    if (targetKeySetAndItsPolicyGroupId.containsKey(Key) == True) {
                        
                        programInstance.nu_dse__Fee_Template__c = targetKeySetAndItsPolicyGroupId.get(Key);
                        programInstance.isPre_Tila__c=True;  //@
                        
                        //ND-50 Adding GCS Policy Group in program level
                        programInstance.GCS_Policy_Group__c = originalAndNewPolicyGroupIdMap.get(policyGroupIdMapKey);
                  
                    } else {
                        
                        //If there are no Matching Fee Template then particular record is considered as Failed...
                        //If already fee template assigned do throw any error...
                        if(programInstance.isPre_Tila__c == False) {
                        
                            programInstance.addError('The fee template relevant to DNL interim not found.');
                        }
                    }
                }
            }
        }
    }    
}