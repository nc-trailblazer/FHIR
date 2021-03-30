@IsTest
public class FHIRHealthCondR4_Test {
	
	// This test method should give 100% coverage
	static testMethod void testParse() {
		String json = '{'+
		'    \"resourceType\": \"Bundle\",'+
		'    \"type\": \"searchset\",'+
		'    \"total\": 1,'+
		'    \"link\": ['+
		'        {'+
		'            \"relation\": \"self\",'+
		'            \"url\": \"https://fhir.epic.com/interconnect-fhir-oauth/api/FHIR/R4/Condition?patient=eq081-VQEgP8drUUqCWzHfw3&category=problem-list-item\"'+
		'        }'+
		'    ],'+
		'    \"entry\": ['+
		'        {'+
		'            \"link\": ['+
		'                {'+
		'                    \"relation\": \"self\",'+
		'                    \"url\": \"https://fhir.epic.com/interconnect-fhir-oauth/api/FHIR/R4/Condition/eVGf2YljIMIk76IcfbNpjWQ3\"'+
		'                }'+
		'            ],'+
		'            \"fullUrl\": \"https://fhir.epic.com/interconnect-fhir-oauth/api/FHIR/R4/Condition/eVGf2YljIMIk76IcfbNpjWQ3\",'+
		'            \"resource\": {'+
		'                \"resourceType\": \"Condition\",'+
		'                \"id\": \"eVGf2YljIMIk76IcfbNpjWQ3\",'+
		'                \"clinicalStatus\": {'+
		'                    \"coding\": ['+
		'                        {'+
		'                            \"system\": \"http://terminology.hl7.org/CodeSystem/condition-clinical\",'+
		'                            \"version\": \"4.0.0\",'+
		'                            \"code\": \"active\",'+
		'                            \"display\": \"Active\"'+
		'                        }'+
		'                    ],'+
		'                    \"text\": \"Active\"'+
		'                },'+
		'                \"verificationStatus\": {'+
		'                    \"coding\": ['+
		'                        {'+
		'                            \"system\": \"http://terminology.hl7.org/CodeSystem/condition-ver-status\",'+
		'                            \"version\": \"4.0.0\",'+
		'                            \"code\": \"confirmed\",'+
		'                            \"display\": \"Confirmed\"'+
		'                        }'+
		'                    ],'+
		'                    \"text\": \"Confirmed\"'+
		'                },'+
		'                \"category\": ['+
		'                    {'+
		'                        \"coding\": ['+
		'                            {'+
		'                                \"system\": \"http://terminology.hl7.org/CodeSystem/condition-category\",'+
		'                                \"code\": \"problem-list-item\",'+
		'                                \"display\": \"Problem List Item\"'+
		'                            }'+
		'                        ],'+
		'                        \"text\": \"Problem List Item\"'+
		'                    },'+
		'                    {'+
		'                        \"coding\": ['+
		'                            {'+
		'                                \"system\": \"http://loinc.org\",'+
		'                                \"code\": \"75310-3\",'+
		'                                \"display\": \"Health concerns\"'+
		'                            },'+
		'                            {'+
		'                                \"system\": \"http://hl7.org/fhir/us/core/CodeSystem/condition-category\",'+
		'                                \"code\": \"health-concern\",'+
		'                                \"display\": \"Health Concern\"'+
		'                            }'+
		'                        ],'+
		'                        \"text\": \"Health Concern\"'+
		'                    }'+
		'                ],'+
		'                \"code\": {'+
		'                    \"coding\": ['+
		'                        {'+
		'                            \"system\": \"urn:oid:2.16.840.1.113883.6.90\",'+
		'                            \"code\": \"Z91.89\"'+
		'                        },'+
		'                        {'+
		'                            \"system\": \"urn:oid:2.16.840.1.113883.6.96\",'+
		'                            \"code\": \"315016007\"'+
		'                        }'+
		'                    ],'+
		'                    \"text\": \"Risk for coronary artery disease between 10% and 20% in next 10 years\"'+
		'                },'+
		'                \"subject\": {'+
		'                    \"reference\": \"Patient/eq081-VQEgP8drUUqCWzHfw3\",'+
		'                    \"display\": \"Lin, Derrick\"'+
		'                },'+
		'                \"recordedDate\": \"2019-05-28\"'+
		'            },'+
		'            \"search\": {'+
		'                \"mode\": \"match\"'+
		'            }'+
		'        }'+
		'    ]'+
		'}';
		FHIRHealthCondR4 r = FHIRHealthCondR4.parse(json);
		System.assert(r != null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		FHIRHealthCondR4.Search_Z objSearch_Z = new FHIRHealthCondR4.Search_Z(System.JSON.createParser(json));
		System.assert(objSearch_Z != null);
		System.assert(objSearch_Z.mode == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		FHIRHealthCondR4.Entry objEntry = new FHIRHealthCondR4.Entry(System.JSON.createParser(json));
		System.assert(objEntry != null);
		System.assert(objEntry.link == null);
		System.assert(objEntry.fullUrl == null);
		System.assert(objEntry.resource == null);
		System.assert(objEntry.search_Z == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		FHIRHealthCondR4.Category objCategory = new FHIRHealthCondR4.Category(System.JSON.createParser(json));
		System.assert(objCategory != null);
		System.assert(objCategory.coding == null);
		System.assert(objCategory.text == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		FHIRHealthCondR4.Coding objCoding = new FHIRHealthCondR4.Coding(System.JSON.createParser(json));
		System.assert(objCoding != null);
		System.assert(objCoding.system_Z == null);
		System.assert(objCoding.version == null);
		System.assert(objCoding.code == null);
		System.assert(objCoding.display == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		FHIRHealthCondR4.ClinicalStatus objClinicalStatus = new FHIRHealthCondR4.ClinicalStatus(System.JSON.createParser(json));
		System.assert(objClinicalStatus != null);
		System.assert(objClinicalStatus.coding == null);
		System.assert(objClinicalStatus.text == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		FHIRHealthCondR4.Coding_Y objCoding_Y = new FHIRHealthCondR4.Coding_Y(System.JSON.createParser(json));
		System.assert(objCoding_Y != null);
		System.assert(objCoding_Y.system_Z == null);
		System.assert(objCoding_Y.code == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		FHIRHealthCondR4.Coding_Z objCoding_Z = new FHIRHealthCondR4.Coding_Z(System.JSON.createParser(json));
		System.assert(objCoding_Z != null);
		System.assert(objCoding_Z.system_Z == null);
		System.assert(objCoding_Z.code == null);
		System.assert(objCoding_Z.display == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		FHIRHealthCondR4.Resource objResource = new FHIRHealthCondR4.Resource(System.JSON.createParser(json));
		System.assert(objResource != null);
		System.assert(objResource.resourceType == null);
		System.assert(objResource.id == null);
		System.assert(objResource.clinicalStatus == null);
		System.assert(objResource.verificationStatus == null);
		System.assert(objResource.category == null);
		System.assert(objResource.code == null);
		System.assert(objResource.subject == null);
		System.assert(objResource.recordedDate == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		FHIRHealthCondR4 objFHIRHealthCondR4 = new FHIRHealthCondR4(System.JSON.createParser(json));
		System.assert(objFHIRHealthCondR4 != null);
		System.assert(objFHIRHealthCondR4.resourceType == null);
		System.assert(objFHIRHealthCondR4.type_Z == null);
		System.assert(objFHIRHealthCondR4.total == null);
		System.assert(objFHIRHealthCondR4.link == null);
		System.assert(objFHIRHealthCondR4.entry == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		FHIRHealthCondR4.Code objCode = new FHIRHealthCondR4.Code(System.JSON.createParser(json));
		System.assert(objCode != null);
		System.assert(objCode.coding == null);
		System.assert(objCode.text == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		FHIRHealthCondR4.Link objLink = new FHIRHealthCondR4.Link(System.JSON.createParser(json));
		System.assert(objLink != null);
		System.assert(objLink.relation == null);
		System.assert(objLink.url == null);

		json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
		FHIRHealthCondR4.Subject objSubject = new FHIRHealthCondR4.Subject(System.JSON.createParser(json));
		System.assert(objSubject != null);
		System.assert(objSubject.reference == null);
		System.assert(objSubject.display == null);
	}
}