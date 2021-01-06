/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

global with sharing class FHIRsearchSTU3 {

    @InvocableMethod(label='Get Patient')
    global static List<FHIRsearchSTU3ActionResult> getPatient(List<FHIRsearchSTU3ActionRequest> requests){

        List<FHIRsearchSTU3ActionResult> results = new List<FHIRsearchSTU3ActionResult>();
        for (FHIRsearchSTU3ActionRequest request : requests) {
          results.add(searchPatient(request));
          System.debug ('Inside getPatient');
        }
        return results;


    }


    public static FHIRsearchSTU3ActionResult searchPatient(FHIRsearchSTU3ActionRequest request) {    
        List<FHIRsearchSTU3ActionResult> results = new List<FHIRsearchSTU3ActionResult>();
        System.debug('Inside search Patient');
        System.debug('FirstName is: ' + request.firstName);
        System.debug('LastName is: ' + request.lastName);
        
        System.debug('DOB is: ' + String.valueOf(request.dob));
        String fixedDOB = String.valueOf(request.dob);
        
        System.debug('fixedDOB : '+ fixedDOB.substringBefore(' '));

        FHIRsearchSTU3ActionResult result = new FHIRsearchSTU3ActionResult();
        String errorMessage ='';
        Http http = new Http();
        HttpRequest httpReq = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();
        
        List<Epic_Access__c> EpicAccessListNew = [Select Id, Name,Access_Token__c,Expires_In_Seconds__c,ExpireEpoch__c  From EPIC_Access__c Where Name='EPICAccess'];

        String URL = 'https://fhir.epic.com/interconnect-fhir-oauth/api/FHIR/STU3/Patient?family='+ request.lastName+'&given='+request.firstName+'&birthdate='+ String.valueOf(request.dob);
        System.debug('URL is: ' + URL);
        httpReq.SetMethod('GET');
        //httpReq.setEndpoint('https://fhir.epic.com/interconnect-fhir-oauth/api/FHIR/STU3/Patient/eq081-VQEgP8drUUqCWzHfw3');
        httpReq.setEndpoint(URL);
        httpReq.setHeader('Authorization', 'Bearer '+ EpicAccessListNew[0].Access_Token__c);
        httpReq.setHeader('Content-Type', 'application/json');
        System.debug('Bearer '+ EpicAccessListNew[0].Access_Token__c);
        try{
            httpRes = http.send(httpReq);
            System.debug('Response Code: ' + httpRes.getStatusCode());
            if(httpRes.getStatusCode() == 200){
                JSONParse root = new JSONParse(httpRes.getBody());
                
                //BasicInfo = 'Patient Name: ' + root.get('name').get('[1].text').getStringValue() + 'has been updated via FHIR connection to EPIC'; //Get Name
                //String pcity = root.get('birthDate').getStringValue(); 
                //String tel = root.get('telecom').get('[0].value').getStringValue();

                //String add1 = root.get('address').get('line').getStringValue() + ',' + root.get('address').get('city').getStringValue() + ',' + root.get('address').get('state').getStringValue() + ',' + root.get('address').get('postalCode').getStringValue();

                //System.debug('Return JSON is: ' + root.toStringPretty());
                if(Integer.ValueOf(root.get('total').getStringValue())>0) {
                    System.debug('We found one ' );
                    result.match = 'Yes';
                    String searchKey = request.firstName;
                    System.debug('SearchKey is: ' + searchKey);
                    Account accounttoUpdate;
                    System.debug('Account Sent in: ' + request.patientRecordId);
                    accounttoUpdate = [SELECT PersonBirthdate, FHIRdata1__c FROM Account WHERE Id = :request.patientRecordId];
                    accounttoUpdate.PersonBirthdate = date.valueOf(root.get('entry').get('[0].resource').get('birthDate').getStringValue());
                    accounttoUpdate.FHIRdata1__c = root.toStringPretty();
                    accounttoUpdate.Phone = root.get('entry').get('[0].resource').get('telecom').get('[0].value').getStringValue();
                    accounttoUpdate.Patient_Phone_Number__c = root.get('entry').get('[0].resource').get('telecom').get('[0].value').getStringValue();
                    accounttoUpdate.PersonHomePhone = root.get('entry').get('[0].resource').get('telecom').get('[0].value').getStringValue();
                    accounttoUpdate.PersonMobilePhone = root.get('entry').get('[0].resource').get('telecom').get('[1].value').getStringValue();
                    accounttoUpdate.Member_ID__pc = root.get('entry').get('[0].resource').get('identifier').get('[5].value').getStringValue();
                    accounttoUpdate.HealthCloudGA__MedicalRecordNumber__pc = root.get('entry').get('[0].resource').get('identifier').get('[4].value').getStringValue();
                    accounttoUpdate.Member_ID__c = root.get('entry').get('[0].resource').get('identifier').get('[5].value').getStringValue();
                    accounttoUpdate.HealthCloudGA__MedicalRecordNumber__c = root.get('entry').get('[0].resource').get('identifier').get('[4].value').getStringValue();
                    accounttoUpdate.HealthCloudGA__Gender__pc = root.get('entry').get('[0].resource').get('gender').getStringValue();
                    //accounttoUpdate.BillingAddress = add1;

                    //Set Address
                    accounttoUpdate.BillingCity = root.get('entry').get('[0].resource').get('address').get('[0].city').getStringValue();
                    accounttoUpdate.BillingState = root.get('entry').get('[0].resource').get('address').get('[0].state').getStringValue();
                    accounttoUpdate.BillingStreet = root.get('entry').get('[0].resource').get('address').get('[0].line').get('[0]').getStringValue();
                    accounttoUpdate.BillingPostalCode = root.get('entry').get('[0].resource').get('address').get('[0].postalCode').getStringValue();

                    //Set preferred language
                    accounttoUpdate.dkom__Language__c = root.get('entry').get('[0].resource').get('communication').get('[0].language').get('text').getStringValue();

                    //Patient Card 
                    HealthCloudGA__EhrPatient__c[] ehrPatients = [SELECT HealthCloudGA__Account__c, HealthCloudGA__BirthDate__c, HealthCloudGA__GenderLabel__c, HealthCloudGA__Communication1Label__c, HealthCloudGA__SourceSystemId__c FROM HealthCloudGA__EhrPatient__c WHERE HealthCloudGA__SourceSystemId__c = :root.get('entry').get('[0].resource').get('identifier').get('[4].value').getStringValue()];
                        if (ehrPatients.size()==0) {
                            HealthCloudGA__EhrPatient__c ehrpatient = new HealthCloudGA__EhrPatient__c();
                            ehrPatient.Risk_Level__c = 'High';
                            ehrPatient.HealthCloudGA__Account__c = accounttoUpdate.Id;
                            ehrPatient.HealthCloudGA__BirthDate__c = date.valueOf(root.get('entry').get('[0].resource').get('birthDate').getStringValue());
                            ehrPatient.HealthCloudGA__GenderLabel__c = root.get('entry').get('[0].resource').get('gender').getStringValue();
                            ehrPatient.HealthCloudGA__Communication1Label__c = root.get('entry').get('[0].resource').get('communication').get('[0].language').get('text').getStringValue();
                            ehrPatient.HealthCloudGA__SourceSystemId__c = root.get('entry').get('[0].resource').get('identifier').get('[4].value').getStringValue();
                            ehrpatients.add(ehrpatient);
                        }
                        else {
                            ehrPatients[0].Risk_Level__c = 'High';
                            ehrPatients[0].HealthCloudGA__Account__c = accounttoUpdate.Id;
                            ehrPatients[0].HealthCloudGA__BirthDate__c = date.valueOf(root.get('entry').get('[0].resource').get('birthDate').getStringValue());
                            ehrPatients[0].HealthCloudGA__GenderLabel__c = root.get('entry').get('[0].resource').get('gender').getStringValue();
                            ehrPatients[0].HealthCloudGA__Communication1Label__c = root.get('entry').get('[0].resource').get('communication').get('[0].language').get('text').getStringValue();
                            ehrPatients[0].HealthCloudGA__SourceSystemId__c = root.get('entry').get('[0].resource').get('identifier').get('[4].value').getStringValue();
                        }
                        try {
                            upsert ehrpatients;
                        }
                        catch (DmlException e) {
                            System.debug('Upsert Failed:' + e);
                        }
                        
                    update accounttoUpdate; //We know this exists because we created it in the flow
                    
                
                    result.accountId = accounttoUpdate.id;
                    result.FHIRid = root.get('entry').get('[0].resource').get('identifier').get('[3].value').getStringValue();
                    result.STU3id = root.get('entry').get('[0].resource').get('identifier').get('[4].value').getStringValue();

                }
                else {
                    System.debug('Not Found');
                    result.match = 'No';
                }
                
              
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

    global class FHIRsearchSTU3ActionRequest {
        @InvocableVariable(required=true)
        global String firstName;
        
        @InvocableVariable(required=true)
        global String lastName;
        
        @InvocableVariable(required=true)
        global Date dob;

        @InvocableVariable(required=true)
        global String patientRecordId;
    }

    global class FHIRsearchSTU3ActionResult {
        @InvocableVariable
        global ID accountId;

        @InvocableVariable
        global String FHIRid;

        @InvocableVariable
        global String match;

        @InvocableVariable
        global String STU3id;
       
      }

}
