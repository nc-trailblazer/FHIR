public with sharing class FHIRgetAppointmentController {
	
    public List<EPIC_Access__c> EpicAccessList { get; set; }
	@AuraEnabled
    public static void createAppointments(string ApptName, string ApptDateTime, string ApptProvider, string ApptStatus) {
        System.debug('#### CREATE COND ');
        
        Appointment__c	newAppt = new Appointment__c();
        
        newAppt.Name =  ApptName;
        newAppt.Provider__c =  ApptProvider;
        newAppt.Status__c =  ApptStatus;
        newAppt.Appointment_time__c =  DateTime.now().addMinutes(5); //DEMO USER HARD CODED
        
        insert newAppt;

    }
    
    @AuraEnabled
    public static void getAppointments(){
        System.debug('In GetAppointments');
    
        String errorMessage ='';
        Http http = new Http();
        HttpRequest httpReq = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();
        
        List<EPIC_Access__c> EpicAccessListNew = [Select Id, Name,Access_Token__c,Expires_In_Seconds__c,ExpireEpoch__c  From Epic_Access__c Where Name='EPICAccess'];
        System.debug('#### Second Step ');
        httpReq.SetMethod('POST');
        httpReq.setEndpoint('https://fhir.epic.com/interconnect-fhir-oauth/api/FHIR/STU3/Appointment/$find');
        httpReq.setHeader('Authorization', 'Bearer '+EpicAccessListNew[0].Access_Token__c);
        httpReq.setHeader('Accept', 'application/json');
        
        try{
             httpRes = http.send(httpReq);
            if(httpRes.getStatusCode() == 200){
                JSONParse root2 = new JSONParse(httpRes.getBody());
                
                
               
                //Condition 1
                
                String ApptName = root2.get('entry').get('[0].resource').get('serviceType').get('[0].coding').get('[0].display').getStringValue();
                String ApptDateTime = root2.get('entry').get('[0].resource').get('start').getStringValue();
                String ApptProvider = '0014W000025SKn7QAG';
                String ApptStatus = 'Scheduled';
                
                createAppointments(ApptName, ApptDateTime, ApptProvider, ApptStatus);
                
                
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