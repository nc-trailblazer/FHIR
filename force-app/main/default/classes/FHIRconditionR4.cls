/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

global with sharing class FHIRconditionR4 {
    
    @InvocableMethod(label='Get R4 Conditions')
    global static List<FHIRcondR4ActionResult> getConditions(List<FHIRcondR4ActionRequest> requests){

        List<FHIRcondR4ActionResult> results = new List<FHIRcondR4ActionResult>();
        for (FHIRcondR4ActionRequest request : requests) {
          results.add(findConditions(request));
          System.debug ('Inside getConditions');
        }
        return results;


    }

    public static void explore(JSONParse node, Integer depth) {

        if(!(node.isObject() || node.isArray())) {
            System.debug( '*'.repeat(depth) + node.getValue());
        }
        
        if(node.isObject()) {
            for(String key : node.asMap().keySet()) {
                explore(node.get(key), depth + 1);
            }
        }
        
        if(node.isArray()) {
            for(JSONParse item : node.asList()) {
                explore(item, depth + 1);
            }
        }
    }
    
    
    public static FHIRcondR4ActionResult findConditions(FHIRcondR4ActionRequest request) {    
        
        List<FHIRcondR4ActionResult> results = new List<FHIRcondR4ActionResult>();

        System.debug ('Inside getConditions 2');
        
        FHIRcondR4ActionResult result = new FHIRcondR4ActionResult();
        String errorMessage ='';
        Http http = new Http();
        HttpRequest httpReq = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();
        
        List<Epic_Access__c> EpicAccessListNew = [Select Id, Name,Access_Token__c,Expires_In_Seconds__c,ExpireEpoch__c  From EPIC_Access__c Where Name='EPICAccess'];

        System.debug('#### Second Step ');
        System.debug('FHIR:  '+ request.FHIRid);
        httpReq.SetMethod('GET');
        httpReq.setEndpoint('https://fhir.epic.com/interconnect-fhir-oauth/api/FHIR/R4/Condition?patient='+ request.FHIRid +'&category=problem-list-item');
                             
        httpReq.setHeader('Authorization', 'Bearer '+EpicAccessListNew[0].Access_Token__c);
        httpReq.setHeader('Accept', 'application/json');
        httpReq.setHeader('Content-Length', '0');
        try{
            httpRes = http.send(httpReq);
            if(httpRes.getStatusCode() == 200){
                JSONParse root = new JSONParse(httpRes.getBody());
               // explore(root,0);  <- Uncomment to see JSON Structure in Debug
                System.debug(root.toStringPretty());
                Integer entries = Integer.ValueOf(root.get('total').getStringValue());
                System.debug('Entries: '+ entries);
               if(entries > 0) {
                   Integer i = 0;
                   String secondLevel = '['+i+'].resource';
                   
                   while (i < entries){
                       System.debug('Inside loop');
                       
                        String subject = root.get('entry').get('['+String.valueOf(i)+'].resource').get('subject').get('reference').getStringValue();System.debug('Inside loop');
                        // For R4 they use the code bundle a lot so we will create that inlinehere
                        String ClinStatusCodeSetSystem = root.get('entry').get('['+String.valueOf(i)+'].resource').get('clinicalStatus').get('coding').get('[0].system').getStringValue();
                        String ClinStatusCodeSetVersion = root.get('entry').get('['+String.valueOf(i)+'].resource').get('clinicalStatus').get('coding').get('[0].version').getStringValue();
                        String ClinStatusCodeSetCode = root.get('entry').get('['+String.valueOf(i)+'].resource').get('clinicalStatus').get('coding').get('[0].code').getStringValue();
                        String ClinStatusCodeSetDisplay = root.get('entry').get('['+String.valueOf(i)+'].resource').get('clinicalStatus').get('coding').get('[0].display').getStringValue();
                        //
                        String clinicalStatus = root.get('entry').get('['+String.valueOf(i)+'].resource').get('clinicalStatus').get('coding').get('[0].display').getStringValue();
                        //
                        String VerStatusCodeSetSystem = root.get('entry').get('['+String.valueOf(i)+'].resource').get('category').get('[0].coding').get('[0].system').getStringValue();
                        //String VerStatusCodeSetVersion = root.get('entry').get('['+String.valueOf(i)+'].resource').get('category').get('[0].coding').get('[0].version').getStringValue();
                        String VerStatusCodeSetCode = root.get('entry').get('['+String.valueOf(i)+'].resource').get('category').get('[0].coding').get('[0].code').getStringValue();
                        String VerStatusCodeSetDisplay = root.get('entry').get('['+String.valueOf(i)+'].resource').get('category').get('[0].coding').get('[0].display').getStringValue();
                        //
                        String verificationStatus = root.get('entry').get('['+String.valueOf(i)+'].resource').get('verificationStatus').get('coding').get('[0].display').getStringValue();
                        //
                        String catCodeSetSystem = root.get('entry').get('['+String.valueOf(i)+'].resource').get('verificationStatus').get('coding').get('[0].system').getStringValue();
                        String catCodeSetCode = root.get('entry').get('['+String.valueOf(i)+'].resource').get('verificationStatus').get('coding').get('[0].code').getStringValue();
                        String catCodeSetDisplay = root.get('entry').get('['+String.valueOf(i)+'].resource').get('verificationStatus').get('coding').get('[0].display').getStringValue();
                        //
                        String category = root.get('entry').get('['+String.valueOf(i)+'].resource').get('verificationStatus').get('coding').get('[0].display').getStringValue();
                        //
                        String codeCodeSetSystem = root.get('entry').get('['+String.valueOf(i)+'].resource').get('verificationStatus').get('coding').get('[0].system').getStringValue();
                        String codeCodeSetCode = root.get('entry').get('['+String.valueOf(i)+'].resource').get('verificationStatus').get('coding').get('[0].code').getStringValue();
                        //
                        String codeCodeSetBundleName = root.get('entry').get('['+String.valueOf(i)+'].resource').get('code').get('text').getStringValue();
                        //
                        date recordedDate = root.get('entry').get('['+String.valueOf(i)+'].resource').get('recordedDate').getDateValue();
                        //
                        String id = root.get('entry').get('['+String.valueOf(i)+'].resource').get('id').getStringValue();
                
                       
                       
                     //   date assertionDate = root.get('entry').get('['+String.valueOf(i)+'].resource').get('assertedDate').getDateValue();
                        
                        System.debug('#### CREATE New R4 HealthCondition Object Record ');


                        // Create all the CodeSets First so we can attach them to the HealthCondition record
                        CodeSet[] newCodeSets = [SELECT Code, SourceSystem, SystemVersion FROM CodeSet WHERE Name = :ClinStatusCodeSetDisplay];
                        if (newCodeSets.size() ==0) {
                            CodeSet cset = new CodeSet();
                            cset.Name = codeCodeSetCode;
                            cset.Code = codeCodeSetCode;
                            cset.SourceSystem = codeCodeSetSystem;

                            newCodeSets.add(cset);
                            try {
                                upsert newCodeSets;
                            }
                            catch (DmlException e) {
                                System.debug('Upsert Failed:' + e);
                            }
                            CodeSetBundle csetbdl = new CodeSetBundle();
                            csetbdl.Name = codeCodeSetBundleName;
                            csetbdl.CodeSet1Id = cset.id;
                            try {
                                upsert csetbdl;
                            }
                            catch (DmlException e) {
                                System.debug('Upsert Failed:' + e);
                            }
                        

                        HealthCondition[] conditionList = [SELECT PatientId, ConditionStatus, DiagnosticStatus, Type, ConditionCodeId, RecordCreationDateTime, SourceSystem FROM HealthCondition WHERE SourceSystemIdentifier = :id];
                        if (conditionList.size()==0) {
                            HealthCondition cond = new HealthCondition();
                            cond.SourceSystemIdentifier = id;
                            cond.PatientId = request.patientRecordId;  
                            cond.ConditionStatus = clinicalStatus;
                            cond.DiagnosticStatus = verificationStatus;
                            cond.Type = category;
                            cond.RecordCreationDateTime = recordedDate;
                            cond.ConditionCodeId = csetbdl.id;
                            conditionList.add(cond);
                        }
                        else {
                            conditionList[0].SourceSystemIdentifier = id;
                            conditionList[0].PatientId = request.patientRecordId;  
                            conditionList[0].ConditionStatus = clinicalStatus;
                            conditionList[0].DiagnosticStatus = verificationStatus;
                            conditionList[0].Type = category;
                            conditionList[0].RecordCreationDateTime = recordedDate;
                            conditionList[0].ConditionCodeId = csetbdl.id;
                        
                        }
                        
                        
                        
                        try {
                            upsert conditionList;
                        }
                        catch (DmlException e) {
                            System.debug('Upsert Failed:' + e);
                        }
                        


                        i++;
                    }
                }
               }
                
           }else{
               errorMessage = 'Unexpected Error while communicating with LinkedIn API. '
                                   +'Status '+httpRes.getStatus()+' and Status Code '+httpRes.getStatuscode();
           }       
               
       }catch(System.Exception e){
           System.debug('#### Exception Excuted '+e.getStackTraceString()+'  '+e.getMessage());
           if(String.valueOf(e.getMessage()).startsWith('Unauthorized endpoint')){
               errorMessage =  'Unauthorize endpoint: An Administer must go to Setup -> Administer -> Security Control ->'
                                   +' Remote Site Setting and add '+' '+ 'https://api.linkedin.com/ '+' Endpoint';
               
           }else{
               errorMessage = 'Unexpected Error while communicating with LinkedIn API. '
                                   +'Status '+httpRes.getStatus()+' and Status Code '+httpRes.getStatuscode();
               
           }
            
        }
        result.accountId = request.patientRecordId;
        return result;
    }

    global class FHIRcondR4ActionRequest {

        @InvocableVariable(required=true)
        global String patientRecordId;

        @InvocableVariable(required=true)
        global String FHIRid;
    }

    global class FHIRcondR4ActionResult {
        @InvocableVariable
        global ID accountId;
     
       
      }
     

      

}