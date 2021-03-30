/*
 * Copyright (c) 2018, salesforce.com, inc.
 * All rights reserved.
 * SPDX-License-Identifier: BSD-3-Clause
 * For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
 */

global with sharing class FHIRallergyIntolR4 {
    
    @InvocableMethod(label='Get R4 Allergy Intolerance')
    global static List<FHIRallergyIntolR4ActionResult> getConditions(List<FHIRallergyIntolR4ActionRequest> requests){

        List<FHIRallergyIntolR4ActionResult> results = new List<FHIRallergyIntolR4ActionResult>();
        for (FHIRallergyIntolR4ActionRequest request : requests) {
          results.add(findAllergyIntolerance(request));
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
    
    
    public static FHIRallergyIntolR4ActionResult findAllergyIntolerance(FHIRallergyIntolR4ActionRequest request) {    
        
        List<FHIRallergyIntolR4ActionResult> results = new List<FHIRallergyIntolR4ActionResult>();

        System.debug ('Inside findAllergyIntolerance');
        
        FHIRallergyIntolR4ActionResult result = new FHIRallergyIntolR4ActionResult();
        String errorMessage ='';
        Http http = new Http();
        HttpRequest httpReq = new HttpRequest();
        HttpResponse httpRes = new HttpResponse();
        
        List<Epic_Access__c> EpicAccessListNew = [Select Id, Name,Access_Token__c,Expires_In_Seconds__c,ExpireEpoch__c  From EPIC_Access__c Where Name='EPICAccess'];

        System.debug('#### Second Step ');
        System.debug('FHIR:  '+ request.FHIRid);
        httpReq.SetMethod('GET');
        httpReq.setEndpoint('https://fhir.epic.com/interconnect-fhir-oauth/api/FHIR/R4/allergyIntolerance?patient='+ request.FHIRid +'&clinical-status=active');
                             
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
                String validReturn = root.get('entry').get('[0].resource').get('code').get('text').getStringValue();
                System.debug('validReturn: '+ validReturn);
               if(entries > 0 && validReturn != 'Not on File') {
                   Integer i = 0;
                   String secondLevel = '['+i+'].resource';
                   
                   while (i < entries){
                       System.debug('Inside loop');
                       
                        String subject = root.get('entry').get('['+String.valueOf(i)+'].resource').get('patient').get('reference').getStringValue();System.debug('Inside loop2');
                        // For R4 they use the code bundle a lot so we will create that inlinehere
                        //String ClinStatusCodeSetSystem = root.get('entry').get('['+String.valueOf(i)+'].resource').get('clinicalStatus').get('coding').get('[0].system').getStringValue();
                        //String ClinStatusCodeSetVersion = root.get('entry').get('['+String.valueOf(i)+'].resource').get('clinicalStatus').get('coding').get('[0].version').getStringValue();
                        //String ClinStatusCodeSetCode = root.get('entry').get('['+String.valueOf(i)+'].resource').get('clinicalStatus').get('coding').get('[0].code').getStringValue();
                        String ClinStatusCodeSetDisplay = root.get('entry').get('['+String.valueOf(i)+'].resource').get('clinicalStatus').get('coding').get('[0].display').getStringValue();System.debug('Inside loop3');
                        //
                        String clinicalStatus = root.get('entry').get('['+String.valueOf(i)+'].resource').get('clinicalStatus').get('coding').get('[0].display').getStringValue();System.debug('Inside loop4');
                        //
                        //String VerStatusCodeSetSystem = root.get('entry').get('['+String.valueOf(i)+'].resource').get('category').get('[0].coding').get('[0].system').getStringValue();
                        //String VerStatusCodeSetVersion = root.get('entry').get('['+String.valueOf(i)+'].resource').get('category').get('[0].coding').get('[0].version').getStringValue();
                       // String VerStatusCodeSetCode = root.get('entry').get('['+String.valueOf(i)+'].resource').get('category').get('[0].coding').get('[0].code').getStringValue();
                        String VerStatusCodeSetDisplay = root.get('entry').get('['+String.valueOf(i)+'].resource').get('verificationStatus').get('coding').get('[0].display').getStringValue();System.debug('Inside loop5');
                        //
                        String verificationStatus = root.get('entry').get('['+String.valueOf(i)+'].resource').get('verificationStatus').get('coding').get('[0].display').getStringValue();System.debug('Inside loop6');
                        //
                        String category = root.get('entry').get('['+String.valueOf(i)+'].resource').get('category').get('[0]').getStringValue();System.debug('Inside loop7');
                        //
                        String codeCodeSetSystem = root.get('entry').get('['+String.valueOf(i)+'].resource').get('verificationStatus').get('coding').get('[0].system').getStringValue();System.debug('Inside loop8');
                        String codeCodeSetCode = root.get('entry').get('['+String.valueOf(i)+'].resource').get('verificationStatus').get('coding').get('[0].code').getStringValue();System.debug('Inside loop9');
                        String codeCodeSetDescription = root.get('entry').get('['+String.valueOf(i)+'].resource').get('verificationStatus').get('coding').get('[0].display').getStringValue();System.debug('Inside loop11');
                        //
                        String codeCodeSetBundleName = root.get('entry').get('['+String.valueOf(i)+'].resource').get('code').get('text').getStringValue();System.debug('Inside loop12');
                        //
                        // Elijah has a bad date so not using this for now. 
                        //date recordedDate = root.get('entry').get('['+String.valueOf(i)+'].resource').get('recordedDate').getDateValue();System.debug('Inside loop13');
                        //
                        String id = root.get('entry').get('['+String.valueOf(i)+'].resource').get('id').getStringValue();System.debug('Inside loop14');

                        //Reaction Data
                        String severity = root.get('entry').get('['+String.valueOf(i)+'].resource').get('reaction').get('[0].severity').getStringValue();System.debug('Inside loop15');
                        String manifestText = root.get('entry').get('['+String.valueOf(i)+'].resource').get('reaction').get('[0].description').getStringValue();System.debug('Inside loop16');
                        String causeText = root.get('entry').get('['+String.valueOf(i)+'].resource').get('code').get('coding').get('[0].display').getStringValue();System.debug('Inside loop17');

                
                       
                       
                     //   date assertionDate = root.get('entry').get('['+String.valueOf(i)+'].resource').get('assertedDate').getDateValue();
                        
                        System.debug('Code Text is: ' + codeCodeSetBundleName);
                        

                        // Create all the CodeSets First so we can attach them to the HealthCondition record
                        CodeSet[] newCodeSets = [SELECT Code, SourceSystem FROM CodeSet WHERE Name = :codeCodeSetBundleName];
                        if (newCodeSets.size() ==0) {
                            CodeSet cset = new CodeSet();
                            cset.Name = codeCodeSetBundleName;
                            cset.Code = codeCodeSetBundleName;
                            cset.SourceSystem = codeCodeSetSystem;
                            cset.CodeDescription = codeCodeSetDescription;

                            newCodeSets.add(cset);
                            try {
                                upsert newCodeSets;
                            }
                            catch (DmlException e) {
                                System.debug('Upsert Failed:' + e);
                            }
                        }
                        CodeSetBundle[] codeSetBundleArray = [SELECT Name, CodeSet1Id FROM CodeSetBundle WHERE Name = :codeCodeSetBundleName];
                            if (codeSetBundleArray.size() == 0) {
                                CodeSetBundle csetbdl = new CodeSetBundle();
                                csetbdl.Name = codeCodeSetBundleName;
                                csetbdl.CodeSet1Id = newCodeSets[0].id;
                                System.debug('Upsert 1');
                                codeSetBundleArray.add(csetbdl);
                                try {
                                    upsert codeSetBundleArray;
                                }
                                catch (DmlException e) {
                                    System.debug('Upsert Failed:' + e);
                                }
                            }
                        AllergyIntolerance[] allergyArray = [SELECT Status, VerificationStatus, Type, PatientId, Category, Severity, CodeId FROM AllergyIntolerance WHERE CodeId = :codeSetBundleArray[0].id];
                            if(allergyArray.size() == 0) {
                                AllergyIntolerance newAllergyIntol = new AllergyIntolerance();
                                newAllergyIntol.Status = clinicalStatus;
                                newAllergyIntol.VerificationStatus = verificationStatus;
                                newAllergyIntol.Type = 'Intolerance';
                                newAllergyIntol.PatientId = request.patientRecordId;
                                newAllergyIntol.Category = category;
                                newAllergyIntol.Severity = severity;
                                newAllergyIntol.CodeId = codeSetBundleArray[0].id;
                                //newAllergyIntol.RecordCreationDateTime = recordedDate;

                                allergyArray.add(newAllergyIntol);
                                try {
                                    upsert allergyArray;
                                }
                                catch (DmlException e) {
                                    System.debug('Upsert Failed:' + e);
                                }
                            }        
                        CodeSet[] manifestCodeSet= [SELECT Code, Name FROM CodeSet WHERE Name = :manifestText];
                            if (manifestCodeSet.size() ==0) {
                            //reaction codeset
                                CodeSet manifestCode = new CodeSet();
                                manifestCode.Name = manifestText;
                                manifestCode.Code = manifestText;
                                manifestCodeSet.add(manifestCode);
                                System.debug('Upsert 2');
                                try {
                                    upsert manifestCodeSet;
                                }
                                    catch (DmlException e) {
                                    System.debug('Upsert Failed:' + e);
                                }
                            }
                            CodeSetBundle[] manifestBundle = [SELECT Name, CodeSet1Id FROM CodeSetBundle WHERE Name = :manifestText];
                                if (manifestBundle.size() == 0) {
                                    CodeSetBundle manifestBundleCS = new CodeSetBundle();
                                    manifestBundleCS.Name = manifestText;
                                    manifestBundleCS.CodeSet1Id = manifestCodeSet[0].id;
                                    System.debug('Upsert 3');
                                    manifestBundle.add(manifestBundleCS);
                                    try {
                                        upsert manifestBundle;
                                    }
                                        catch (DmlException e) {
                                        System.debug('Upsert Failed:' + e);
                                    }
                                }
                            CodeSet[] causeCodeSet= [SELECT Code, Name FROM CodeSet WHERE Name = :causeText];
                                if (causeCodeSet.size() ==0) {
                                //reaction codeset
                                    CodeSet causeCode = new CodeSet();
                                    causeCode.Name = causeText;
                                    causeCode.Code = causeText;
                                    causeCodeSet.add(causeCode);
                                    System.debug('Upsert 2');
                                    try {
                                        upsert causeCodeSet;
                                    }
                                        catch (DmlException e) {
                                        System.debug('Upsert Failed:' + e);
                                    }
                                }
                            CodeSetBundle[] causeBundle = [SELECT Name, CodeSet1Id FROM CodeSetBundle WHERE Name = :causeText];
                                    if(causeBundle.size()==0) {
                                        CodeSetBundle causeBundleCS = new CodeSetBundle();
                                        causeBundleCS.Name = causeText;
                                        causeBundleCS.CodeSet1Id = causeCodeSet[0].id;
                                        System.debug('Upsert 3');
                                        causeBundle.add(causeBundleCS);
                                        try {
                                            upsert causeBundle;
                                        }
                                            catch (DmlException e) {
                                            System.debug('Upsert Failed:' + e);
                                        }
                                    }
                            PatientHealthReaction[] newReaction = [SELECT ParentId, severity, CausativeSubstanceId, ManifestedSymptomId FROM PatientHealthReaction WHERE CausativeSubstanceId = :causeBundle[0].id];
                                    if (newReaction.size()==0){
                                        PatientHealthReaction newReactionRecord = new PatientHealthReaction();
                                        newReactionRecord.ParentId = allergyArray[0].id;
                                        newReactionRecord.severity = severity;
                                        newReactionRecord.CausativeSubstanceId = causeBundle[0].id;
                                        newReactionRecord.ManifestedSymptomId = manifestBundle[0].id;

                                        System.debug('Upsert 5');
                                        newReaction.add(newReactionRecord);
                                        try {
                                            upsert newReactionRecord;
                                        }
                                        catch (DmlException e) {
                                            System.debug('Upsert Failed:' + e);
                                        }

                                    }

                        i++;
                    }
                
                result.FoundData = 'True';
               }
               else {
                   result.FoundData = 'False';
               }
            }   
        
           else{
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
        System.debug('Sending in result:' + result.FoundData);
        result.accountId = request.patientRecordId;
        return result;
    }

    global class FHIRallergyIntolR4ActionRequest {

        @InvocableVariable(required=true)
        global String patientRecordId;

        @InvocableVariable(required=true)
        global String FHIRid;
    }

    global class FHIRallergyIntolR4ActionResult {
        @InvocableVariable
        global ID accountId;

        @InvocableVariable
        global String FoundData;
     
       
      }
     

      

}
