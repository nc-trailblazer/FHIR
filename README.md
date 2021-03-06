# Pull EPIC data into your ORG using FHIR APIs

This is a working demo that leverages the fhir.epic.com API sandbox to demonstrate how easy it is to pull EPIC data into Health Cloud.

## Demo Information

The assets and code in this demo have been tailored for use with the fhir.epic.com sandbox.  

Users to use for testing

Derrick Lin
Camila Lopez

The JSON parsing in the code is not production ready.  I have used what will be returned from the API in some cases to shorten the code.

## Installation Instructions

1. Install ShowToast from Unofficial SF ( https://unofficialsf.com/show-toast-flow-action/) and Navigate to Record ( https://unofficialsf.com/navigate-to-salesforce-record-view-or-edit-mode/ )

2. Install Launch Flow in Modal ( https://appexchange.salesforce.com/appxListingDetail?listingId=a0N3A00000FMYinUAH )

3. Navigate to Certificates and Key Management - Create a self signed cert.  You will use this in the next step so remember the name. 

4. Navigate to Identity Providers (Need to do this or you will get an error when importing your cert)
    1. Enable Identity Provider
    ![Image: images/IDP.png](/images/IDP.png)

5. Create a SSL Cert for use on the Epic FHIR Site as well as in your org
```
openssl genrsa -out FHIRDEMO_PRIVATEKEY.pem 2048
openssl req -new -x509 -key FHIRDEMO_PRIVATEKEY.pem -out FHIRDEMO_PUBLICKEY.pem -subj '/CN=CoolFHIRDemo' -days 365
openssl pkcs12 -export -in FHIRDEMO_PUBLICKEY.pem -inkey FHIRDEMO_PRIVATEKEY.pem -out FHIRDEMO_KEYSTORE.p12
keytool -importkeystore -srckeystore FHIRDEMO_KEYSTORE.p12 -srcstoretype pkcs12 -destkeystore FHIRDEMO_KEYSTORE.jks -deststoretype JKS
keytool -keystore FHIRDEMO_KEYSTORE.jks -changealias -alias 1 -destalias FHIRDEMO_CERT
```

6. Note - Some of these command will ask you to create and or enter a password.  

The above creates a certificate and them a keystore.  You will need the public key for the EPIC site and you will need the keystoore for your Org.  Note that changing the alias is what shows us in the org.  

Navigate back to Certificates and Key Management and select import from keystore and import the jks file you created above.  

![Cert Image](/images/cert.png)

7. Now you need to sign up over at fhir.epic.com (http://fhir.epic.com/) for a sandbox account.   

8. Once you have your sand box account navigate to Build Apps. 

9. Create an App and select Backend Systems, name it, add all the APIS and select the PUBLICKEY from the steps above. 
![Build App](/images/createApp.png)

10. Save the app, then agree to terms and save and make available for production. 

11. Make sure you are in the new app or click into it snd you will now see the Client ID needed for the connection. (We use the Non-Production Client ID)
![ClientID Image](/images/clientID.png)

12. Deploy this source to your ORG (You can use this button)  You can also use SFDX or VS Code if you prefer. 
<a href="https://githubsfdeploy.herokuapp.com">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

13. Make sure you see a “Deployment Complete”

14. Open setup and assign the EPIConFHIR Permission Set to your admin user (User giving demo)

15. Open Setup→Custom Metadata Types and select FHIR_jwt_setting, then Manage FHIR_jwt_setting, then click on FHIR Settings.  
This is where you can customize everything needed for your jwt token to authorize into your Epic Sandbox you setup above. 

16.  The Client ID from step 11 will be what yoou enter into the ISS and SUB sections. You can leave AUD as is.  JTI can be whatever you want as it is just a session identifier.  Lastly make sure the Cert Name is the name of the cert you created in step 6.

