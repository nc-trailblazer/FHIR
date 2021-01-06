/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

global with sharing class FHIRconditionSTU3 {
    
    @InvocableMethod(label='Get Conditions')
    global static List<FHIRapptSTU3ActionResult> getConditions(List<FHIRapptSTU3ActionRequest> requests){

        List<FHIRapptSTU3ActionResult> results = new List<FHIRapptSTU3ActionResult>();
        for (FHIRapptSTU3ActionRequest request : requests) {
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
    
    
    public static FHIRapptSTU3ActionResult findConditions(FHIRapptSTU3ActionRequest request) {    
        
        List<FHIRapptSTU3ActionResult> results = new List<FHIRapptSTU3ActionResult>();

        System.debug ('Inside getConditions 2');
        
        FHIRapptSTU3ActionResult result = new FHIRapptSTU3ActionResult();
        String errorMessage ='';
        Http http = new Http();
        HttpRequest httpReq = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();
        
        List<Epic_Access__c> EpicAccessListNew = [Select Id, Name,Access_Token__c,Expires_In_Seconds__c,ExpireEpoch__c  From EPIC_Access__c Where Name='EPICAccess'];

        System.debug('#### Second Step ');
        System.debug('FHIR:  '+ request.FHIRid);
        httpReq.SetMethod('GET');
        httpReq.setEndpoint('https://fhir.epic.com/interconnect-fhir-oauth/api/FHIR/STU3/Condition?patient='+ request.FHIRid +'&clinical-status=active,inactive,resolved');
                             
        httpReq.setHeader('Authorization', 'Bearer '+EpicAccessListNew[0].Access_Token__c);
        httpReq.setHeader('Accept', 'application/json');
        httpReq.setHeader('Content-Length', '0');
        try{
            httpRes = http.send(httpReq);
            if(httpRes.getStatusCode() == 200){
                JSONParse root = new JSONParse(httpRes.getBody());
               // explore(root,0);  <- Uncomment to see JSON Structure in Debug
                //System.debug(root.toStringPretty());
                Integer entries = Integer.ValueOf(root.get('total').getStringValue());
                System.debug('Entries: '+ entries);
                
               if(entries > 0) {
                   Integer i = 0;
                   String secondLevel = '['+i+'].resource';
                   
                   while (i < entries){
                       System.debug('Inside loop');
                       
                        
                       
                        String condcode1 = root.get('entry').get('['+String.valueOf(i)+'].resource').get('category').get('[0].coding').get('[0].code').getStringValue();
                        String source1 = root.get('entry').get('['+String.valueOf(i)+'].resource').get('category').get('[0].coding').get('[0].system').getStringValue();
                        String label1 = root.get('entry').get('['+String.valueOf(i)+'].resource').get('category').get('[0].coding').get('[0].display').getStringValue();
                        String id1 = root.get('entry').get('['+String.valueOf(i)+'].resource').get('id').getStringValue();
                        String notes1 = root.get('entry').get('['+i+'].resource').get('code').get('text').getStringValue();
                        date assertionDate = root.get('entry').get('['+String.valueOf(i)+'].resource').get('assertedDate').getDateValue();
                        
                        System.debug('#### CREATE COND ');
                        HealthCloudGA__EhrCondition__c[] ehrconditions = [SELECT HealthCloudGA__SourceSystemId__c, HealthCloudGA__Account__c, HealthCloudGA__Code__c, HealthCloudGA__SourceSystem__c, HealthCloudGA__CodeLabel__c, HealthCloudGA__Notes__c FROM HealthCloudGA__EhrCondition__c WHERE HealthCloudGA__SourceSystemId__c = :id1];
                        if (ehrconditions.size()==0) {
                            HealthCloudGA__EhrCondition__c ehrcondition = new HealthCloudGA__EhrCondition__c();
                            ehrcondition.HealthCloudGA__Account__c =  request.patientRecordId;  
                            ehrcondition.HealthCloudGA__Code__c = condcode1;
                            ehrcondition.HealthCloudGA__SourceSystem__c = source1;
                            ehrcondition.HealthCloudGA__CodeLabel__c = notes1; //This reads better
                            ehrcondition.HealthCloudGA__Notes__c = notes1;
                            ehrcondition.HealthCloudGA__SourceSystemId__c = id1;
                            ehrcondition.HealthCloudGA__DateAsserted__c = assertionDate;
                            ehrconditions.add(ehrcondition);
                        }
                        else {
                            ehrconditions[0].HealthCloudGA__Account__c =  request.patientRecordId;  
                            ehrconditions[0].HealthCloudGA__Code__c = condcode1;
                            ehrconditions[0].HealthCloudGA__SourceSystem__c = source1;
                            ehrconditions[0].HealthCloudGA__CodeLabel__c = notes1; //This reads better
                            ehrconditions[0].HealthCloudGA__Notes__c = notes1;
                            ehrconditions[0].HealthCloudGA__SourceSystemId__c = id1;
                            ehrconditions[0].HealthCloudGA__DateAsserted__c = assertionDate;
                        }
                        

                        
                        try {
                            upsert ehrconditions;
                        }
                        catch (DmlException e) {
                            System.debug('Upsert Failed:' + e);
                        }
                        


                        i++;
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

    global class FHIRapptSTU3ActionRequest {

        @InvocableVariable(required=true)
        global String patientRecordId;

        @InvocableVariable(required=true)
        global String FHIRid;
    }

    global class FHIRapptSTU3ActionResult {
        @InvocableVariable
        global ID accountId;
     
       
      }

}
