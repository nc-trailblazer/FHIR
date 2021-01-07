/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

global with sharing class FHIRdemoHelper {
        @InvocableVariable(required=true)
        global String firstName;
    
        @InvocableVariable(required=true)
        global String lastName;
    
        @InvocableVariable(required=true)
        global DateTime dob;
    private static 	FHIR_JWT_SETTINGS__mdt FHIRjwtSettings;
   
    public static FHIR_JWT_SETTINGS__mdt settings() {
        if(FHIRjwtSettings == null) {
            FHIRjwtSettings = [
                SELECT  MasterLabel, AUD__c, ISS__c, 
                        SUB__c, JTI__c,
                        Cert_Name__c
                FROM    FHIR_JWT_SETTINGS__mdt 
                WHERE   MasterLabel = 'FHIR Settings'
            ];
        }
        return FHIRjwtSettings;
    }
    @InvocableMethod(label='Get Patient Details from Epic Part2' description='Opens a connection to Epic via FHIR and pulls in appropriate data.' category='Account')
    global static void getUserDetail(){
        
    
    
        String errorMessage ='';
        Http http = new Http();
        HttpRequest httpReq = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();
        
        List<Epic_Access__c> EpicAccessListNew = [Select Id, Name,Access_Token__c,Expires_In_Seconds__c,ExpireEpoch__c  From EPIC_Access__c Where Name='EPICAccess'];
        
        httpReq.SetMethod('GET');
        httpReq.setEndpoint('https://fhir.epic.com/interconnect-fhir-oauth/api/FHIR/STU3/Patient/eq081-VQEgP8drUUqCWzHfw3');
        httpReq.setHeader('Authorization', 'Bearer '+ EpicAccessListNew[0].Access_Token__c);
        httpReq.setHeader('Content-Type', 'application/json');
        System.debug('Bearer '+ EpicAccessListNew[0].Access_Token__c);
        try{
            httpRes = http.send(httpReq);
            if(httpRes.getStatusCode() == 200){
                JSONParse root = new JSONParse(httpRes.getBody());
                
                //BasicInfo = 'Patient Name: ' + root.get('name').get('[1].text').getStringValue() + 'has been updated via FHIR connection to EPIC'; //Get Name
                String pcity = root.get('birthDate').getStringValue(); 
                String tel = root.get('telecom').get('[0].value').getStringValue();

                //String add1 = root.get('address').get('line').getStringValue() + ',' + root.get('address').get('city').getStringValue() + ',' + root.get('address').get('state').getStringValue() + ',' + root.get('address').get('postalCode').getStringValue();

                System.debug('Birthdate is: ' + date.valueOf(pcity));
                Account accounttoUpdate;
                accounttoUpdate = [SELECT PersonBirthdate, FHIRdata1__c FROM Account WHERE FirstName = 'Derrick'];
                accounttoUpdate.PersonBirthdate = date.valueOf(pcity);
                accounttoUpdate.FHIRdata1__c = root.toStringPretty();
                accounttoUpdate.Phone = tel;
                accounttoUpdate.Member_ID__pc = root.get('identifier').get('[5].value').getStringValue();
                accounttoUpdate.HealthCloudGA__MedicalRecordNumber__pc = root.get('id').getStringValue();
                accounttoUpdate.Member_ID__c = root.get('identifier').get('[5].value').getStringValue();
                accounttoUpdate.HealthCloudGA__MedicalRecordNumber__c = root.get('id').getStringValue();
                accounttoUpdate.HealthCloudGA__Gender__pc = root.get('gender').getStringValue();
                //accounttoUpdate.BillingAddress = add1;


                update accounttoUpdate;
              
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
        
    }

    


}
