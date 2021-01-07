/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

global with sharing class FHIRcareplanSTU3 {
    
    @InvocableMethod(label='Get Care Plan')
    global static List<FHIRapptSTU3ActionResult> getCarePlan(List<FHIRapptSTU3ActionRequest> requests){

        List<FHIRapptSTU3ActionResult> results = new List<FHIRapptSTU3ActionResult>();
        for (FHIRapptSTU3ActionRequest request : requests) {
          results.add(findCarePlan(request));
          System.debug ('Inside getCarePlan');
        }
        return results;


    }
    
    
    public static FHIRapptSTU3ActionResult findCarePlan(FHIRapptSTU3ActionRequest request) {    
        
        List<FHIRapptSTU3ActionResult> results = new List<FHIRapptSTU3ActionResult>();
        
        
        
        FHIRapptSTU3ActionResult result = new FHIRapptSTU3ActionResult();
        String errorMessage ='';
        Http http = new Http();
        HttpRequest httpReq = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();
        
        List<Epic_Access__c> EpicAccessListNew = [Select Id, Name,Access_Token__c,Expires_In_Seconds__c,ExpireEpoch__c  From EPIC_Access__c Where Name='EPICAccess'];
        List<Contact> ContactListNew = [Select Id, Name  From Contact Where AccountId=:request.patientRecordId];

        System.debug('#### Second Step ');
        httpReq.SetMethod('GET');
        httpReq.setEndpoint(' https://fhir.epic.com/interconnect-fhir-oauth/api/FHIR/DSTU2/CarePlan/'+request.patientFHIRId);
                             
        httpReq.setHeader('Authorization', 'Bearer '+EpicAccessListNew[0].Access_Token__c);
        httpReq.setHeader('Accept', 'application/json');
        httpReq.setHeader('Content-Length', '0');
        try{
            httpRes = http.send(httpReq);
            System.debug('Response Code: ' + httpRes.getStatusCode());
            if(httpRes.getStatusCode() == 200){
                JSONParse root = new JSONParse(httpRes.getBody());
                
                Case[] careplans = [SELECT Subject, External_ID__c FROM Case WHERE 	External_ID__c = :root.get('id').getStringValue()];
                        if (careplans.size()==0) {


                            Case newCarePlan = new Case();
        
                            newCarePlan.Subject =  'FHIR Generated Care Plan';
                            newCarePlan.recordTypeId = request.recordTypeId;
                            newCarePlan.contactId = ContactListNew[0].Id;
                            newCarePlan.ownerId = request.ownerId;
                            newCarePlan.External_ID__c = root.get('id').getStringValue();
        
                            //insert newCarePlan;
                            careplans.add(newCarePlan);
                            try {
                                upsert careplans;
                            }
                            catch (DmlException e) {
                                System.debug('Upsert Failed:' + e);
                            }

                            //Problem

                            HealthCloudGA__CarePlanProblem__c newProblem = new HealthCloudGA__CarePlanProblem__c();
                            
                            newProblem.HealthCloudGA__CarePlan__c = newCarePlan.Id;
                            newProblem.HealthCloudGA__Account__c = request.patientRecordId;
                            newProblem.Name = root.get('addresses').get('[0].display').getStringValue();

                            insert newProblem;

                            //Goals

                            if (root.get('goal').get('[0].display').getStringValue() != null){
                                HealthCloudGA__CarePlanGoal__c newGoal = new HealthCloudGA__CarePlanGoal__c();
                                newGoal.HealthCloudGA__CarePlanProblem__c = newProblem.Id;
                                newGoal.HealthCloudGA__CarePlan__c = newCarePlan.Id;
                                newGoal.HealthCloudGA__Description__c = root.get('goal').get('[0].display').getStringValue();
                                newGoal.Name = root.get('goal').get('[0].display').getStringValue();

                                insert newGoal;

                                HealthCloudGA__CarePlanGoal__c newGoal2 = new HealthCloudGA__CarePlanGoal__c();
                                newGoal2.HealthCloudGA__CarePlanProblem__c = newProblem.Id;
                                newGoal2.HealthCloudGA__CarePlan__c = newCarePlan.Id;
                                newGoal2.HealthCloudGA__Description__c = root.get('goal').get('[1].display').getStringValue();
                                newGoal2.Name = root.get('goal').get('[1].display').getStringValue();

                                insert newGoal2;
                            }

                            
                        }


                //accounttoUpdate.FHIRdata2__c = root.toStringPretty();

                //update accounttoUpdate;

                result.accountId = request.patientRecordId;
                
              
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
        return result;
    }

    global class FHIRapptSTU3ActionRequest {

        @InvocableVariable(required=true)
        global String patientRecordId;
        
        @InvocableVariable(required=true)
        global String patientFHIRId;

        @InvocableVariable(required=true)
        global String ownerId;

        @InvocableVariable(required=true)
        global String recordTypeId;
    }

    global class FHIRapptSTU3ActionResult {
        @InvocableVariable
        global ID accountId;
     
       
      }

}