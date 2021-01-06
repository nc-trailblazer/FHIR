global with sharing class FHIRencounterSTU3 {
    
    @InvocableMethod(label='Get Encounters')
    global static List<FHIRapptSTU3ActionResult> getEncounters(List<FHIRapptSTU3ActionRequest> requests){

        List<FHIRapptSTU3ActionResult> results = new List<FHIRapptSTU3ActionResult>();
        for (FHIRapptSTU3ActionRequest request : requests) {
          results.add(findEncounters(request));
          System.debug ('Inside getEncounters');
        }
        return results;


    }
    
    
    public static FHIRapptSTU3ActionResult findEncounters(FHIRapptSTU3ActionRequest request) {    
        
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
        httpReq.setEndpoint(' https://fhir.epic.com/interconnect-fhir-oauth/api/FHIR/STU3/Encounter?patient='+request.patientFHIRId+'&clinical-status=active,inactive,resolved');
                             
        httpReq.setHeader('Authorization', 'Bearer '+EpicAccessListNew[0].Access_Token__c);
        httpReq.setHeader('Accept', 'application/json');
        httpReq.setHeader('Content-Length', '0');
        try{
            httpRes = http.send(httpReq);
            System.debug('Response Code: ' + httpRes.getStatusCode());
            if(httpRes.getStatusCode() == 200){
                JSONParse root = new JSONParse(httpRes.getBody());
                
                //Create CarePlan aka Case with other stuff 

                //String ApptName = root.get('entry').get('[0].resource').get('serviceType').get('[0].coding').get('[0].display').getStringValue();
               // String ApptDateTime = root.get('entry').get('[0].resource').get('start').getStringValue();
                //String ApptProvider = '0034W00002DysYyQAJ';
               // String ApptStatus = 'Scheduled';

                HealthCloudGA__EhrEncounter__c newEncounter = new HealthCloudGA__EhrEncounter__c();
        
                newEncounter.HealthCloudGA__Location1Description__c =  root.get('entry').get('[0].resource').get('location').get('[0].location').get('display').getStringValue();
                newEncounter.HealthCloudGA__Indication__c = root.get('entry').get('[0].resource').get('reason').get('[0].text').getStringValue();
                newEncounter.HealthCloudGA__Location1StartDate__c = root.get('entry').get('[0].resource').get('period').get('start').getDateValue();
                newEncounter.HealthCloudGA__Location1EndDate__c = root.get('entry').get('[0].resource').get('period').get('end').getDateValue();
                newEncounter.HealthCloudGA__PeriodStart__c = root.get('entry').get('[0].resource').get('period').get('start').getDateValue();
                newEncounter.HealthCloudGA__PeriodEnd__c = root.get('entry').get('[0].resource').get('period').get('end').getDateValue();
                newEncounter.HealthCloudGA__Account__c = request.patientRecordId;
        
                Insert newEncounter;

                
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
    }

    global class FHIRapptSTU3ActionResult {
        @InvocableVariable
        global ID accountId;
     
       
      }

}

