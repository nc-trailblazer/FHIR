/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

global with sharing class FHIRmedstatementSTU3 {
    
    @InvocableMethod(label='Get Medication Statement')
    global static List<FHIRapptSTU3ActionResult> getMedicationStatement(List<FHIRapptSTU3ActionRequest> requests){

        List<FHIRapptSTU3ActionResult> results = new List<FHIRapptSTU3ActionResult>();
        for (FHIRapptSTU3ActionRequest request : requests) {
          results.add(findMedicationStatements(request));
          System.debug ('Inside ggetMedicationStatement');
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
    
    
    public static FHIRapptSTU3ActionResult findMedicationStatements(FHIRapptSTU3ActionRequest request) {    
        
        List<FHIRapptSTU3ActionResult> results = new List<FHIRapptSTU3ActionResult>();

        System.debug ('Inside getMedicationStatement 2');
        
        FHIRapptSTU3ActionResult result = new FHIRapptSTU3ActionResult();
        String errorMessage ='';
        Http http = new Http();
        HttpRequest httpReq = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();
        
        List<Epic_Access__c> EpicAccessListNew = [Select Id, Name,Access_Token__c,Expires_In_Seconds__c,ExpireEpoch__c  From EPIC_Access__c Where Name='EPICAccess'];

        System.debug('#### Second Step ');
        System.debug('FHIR:  '+ request.FHIRid);
        httpReq.SetMethod('GET');
        httpReq.setEndpoint('https://fhir.epic.com/interconnect-fhir-oauth/api/FHIR/STU3/MedicationStatement?Patient='+ request.FHIRid);
                             
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
                       
                        
                       
                        String medicationName = root.get('entry').get('['+String.valueOf(i)+'].resource').get('medicationReference').get('display').getStringValue();
                        String notes = root.get('entry').get('['+String.valueOf(i)+'].resource').get('dosage').get('[0].text').getStringValue();
                        String id = root.get('entry').get('['+String.valueOf(i)+'].resource').get('id').getStringValue();
                        String prescriber = root.get('entry').get('['+String.valueOf(i)+'].resource').get('informationSource').get('display').getStringValue();
                        date whenGiven = root.get('entry').get('['+String.valueOf(i)+'].resource').get('dateAsserted').getDateValue();
                        
                        
                        System.debug('#### CREATE MedStatement ');
                        HealthCloudGA__EhrMedicationStatement__c[] ehrMedStatements = [SELECT UCIN_External_ID__c, HealthCloudGA__Account__c, HealthCloudGA__MedicationName__c, Notes__c, Prescriber__c, HealthCloudGA__WhenGiven__c  FROM HealthCloudGA__EhrMedicationStatement__c WHERE UCIN_External_ID__c = :id];
                        if (ehrMedStatements.size()==0) {
                            HealthCloudGA__EhrMedicationStatement__c ehrMedStatement = new HealthCloudGA__EhrMedicationStatement__c();
                            ehrMedStatement.HealthCloudGA__Account__c =  request.patientRecordId;  
                            ehrMedStatement.UCIN_External_ID__c = id;
                            ehrMedStatement.HealthCloudGA__MedicationName__c = medicationName;
                            ehrMedStatement.Notes__c = notes; //This reads better
                            ehrMedStatement.Prescriber__c = prescriber;
                            ehrMedStatement.HealthCloudGA__WhenGiven__c = whenGiven;
                            ehrMedStatement.Actively_Taking__c = true;
                            
                            ehrMedStatements.add(ehrMedStatement);
                        }
                        else {
                            ehrMedStatements[0].HealthCloudGA__Account__c =  request.patientRecordId;  
                            ehrMedStatements[0].UCIN_External_ID__c = id;
                            ehrMedStatements[0].HealthCloudGA__MedicationName__c = medicationName;
                            ehrMedStatements[0].Notes__c = notes; //This reads better
                            ehrMedStatements[0].Prescriber__c = prescriber;
                            ehrMedStatements[0].HealthCloudGA__WhenGiven__c = whenGiven;
                            ehrMedStatements[0].Actively_Taking__c = true;
                        }
                        

                        
                        try {
                            upsert ehrMedStatements;
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