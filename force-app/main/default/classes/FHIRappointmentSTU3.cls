global with sharing class FHIRappointmentSTU3 {
    
    @InvocableMethod(label='Get Appointments')
    global static List<FHIRapptSTU3ActionResult> getAppointments(List<FHIRapptSTU3ActionRequest> requests){

        List<FHIRapptSTU3ActionResult> results = new List<FHIRapptSTU3ActionResult>();
        for (FHIRapptSTU3ActionRequest request : requests) {
          results.add(findAppointments(request));
          System.debug ('Inside getAppointments');
        }
        return results;


    }
    
    
    public static FHIRapptSTU3ActionResult findAppointments(FHIRapptSTU3ActionRequest request) {    
        
        List<FHIRapptSTU3ActionResult> results = new List<FHIRapptSTU3ActionResult>();
        
        
        
        FHIRapptSTU3ActionResult result = new FHIRapptSTU3ActionResult();
        String errorMessage ='';
        Http http = new Http();
        HttpRequest httpReq = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();
        
        List<Epic_Access__c> EpicAccessListNew = [Select Id, Name,Access_Token__c,Expires_In_Seconds__c,ExpireEpoch__c  From EPIC_Access__c Where Name='EPICAccess'];

        System.debug('#### Second Step ');
        httpReq.SetMethod('POST');
        httpReq.setEndpoint('https://fhir.epic.com/interconnect-fhir-oauth/api/FHIR/STU3/Appointment/$find');
                             
        httpReq.setHeader('Authorization', 'Bearer '+EpicAccessListNew[0].Access_Token__c);
        httpReq.setHeader('Accept', 'application/json');
        httpReq.setHeader('Content-Length', '0');
        try{
            httpRes = http.send(httpReq);
            System.debug('Response Code: ' + httpRes.getStatusCode());
            if(httpRes.getStatusCode() == 200){
                JSONParse root = new JSONParse(httpRes.getBody());
                
                //Condition 1
                
                String ApptName = root.get('entry').get('[0].resource').get('serviceType').get('[0].coding').get('[0].display').getStringValue();
                String ApptDateTime = root.get('entry').get('[0].resource').get('start').getStringValue();
                String ApptProvider = '0034W00002DysYyQAJ';
                String ApptStatus = 'Scheduled';

                Appointment__c	newAppt = new Appointment__c();
        
                newAppt.Name =  ApptName;
                newAppt.Provider__c =  ApptProvider;
                newAppt.Status__c =  ApptStatus;
                newAppt.Appointment_time__c =  DateTime.now().addMinutes(5); //DEMO USER HARD CODED
                newAppt.Patient__c = request.patientRecordId;
        
                insert newAppt;

                Account accounttoUpdate;
                System.debug('Account Sent in: ' + request.patientRecordId);
                accounttoUpdate = [SELECT PersonBirthdate, FHIRdata1__c FROM Account WHERE Id = :request.patientRecordId];
                accounttoUpdate.FHIRdata2__c = root.toStringPretty();

                update accounttoUpdate;

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
    }

    global class FHIRapptSTU3ActionResult {
        @InvocableVariable
        global ID accountId;
     
       
      }

}
