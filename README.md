# Pull EPIC data into your ORG using FHIR APIs

This is a working demo that leverages the fhir.epic.com API sandbox to demonstrate how easy it is to pull EPIC data into Health Cloud.

## Demo Information

The assets and cose in this demo have been tailored for use with the fhir,epic.com sandbox.  

Users to use for testing

Derrick Lin
Camila Lopez

The JSON parsing in the code is not production ready.  i have used what will be returned from the API in some cases to shorten the code.

## Installation Instructions

1. Install ShowToast from Unofficial SF ( https://unofficialsf.com/show-toast-flow-action/)

2. Install Launch Flow in Modal ( https://appexchange.salesforce.com/appxListingDetail?listingId=a0N3A00000FMYinUAH )

3. Navigate to Certificates and Key Management - Create a self signed cert.  You will use this in the next step so remember the name. 

4. Navigate to Identity Providers (Need to do this or you will get an error when importing your cert)
    1. Enable Identity Provider
    ![Image: images/IDP.png](/images/IDP.png)

5. Create a SSL Cert for use on the Epic FHIR Site as well as in your org
```openssl genrsa -out FHIRDEMO_PRIVATEKEY_v2.pem 2048
openssl req -new -x509 -key FHIRDEMO_PRIVATEKEY_v2.pem -out FHIRDEMO_PUBLICKEY_v2.pem -subj '/CN=CoolFHIRDemo' -days 365
openssl pkcs12 -export -in FHIRDEMO_PUBLICKEY_v2.pem -inkey FHIRDEMO_PRIVATEKEY_v2.pem -out FHIRDEMO_KEYSTORE_v2.p12
keytool -importkeystore -srckeystore FHIRDEMO_KEYSTORE_v2.p12 -srcstoretype pkcs12 -destkeystore FHIRDEMO_KEYSTORE_v2.jks -deststoretype JKS
keytool -keystore FHIRDEMO_KEYSTORE_v2.jks -changealias -alias 1 -destalias FHIRDEMO_CERT_v2
```

6. Note - Some of these command will ask you to create and or enter a password.  

The above creates a certificate and them a keystore.  You will need the public key for the EPIC site and you will need the keystoore for your Org.  Note that changing the alias is what shows us in the org.  So in this case you will see a cert named fhirdemo_cert_v2 in your Org. 

![Cert Image](/images/cert.png)

7. Now you need to sign up over at fhir,epic.com (http://epic.com/) for a sandbox account.   

8. Once you have your sand box account navigate to Build Apps. 

9. Create an App and select Backend Systems, name it, add all the APIS and select the PUBLICKEY from the steps above. 
![Build App](/images/createApp.png)

10. Save the app, then agree to terms and save and make available for production. 

11. Make sure you are in the new app or click into it snd you will now see the Client ID needed for the connection. (We use the Non-Production Client ID)
![ClientID Image](/images/clientID.png)

12. Deploy this source to your ORG (You can use this button)
<a href="https://githubsfdeploy.herokuapp.com">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>

13. Make sure you see a “Deployment Complete”

14. Open Setup→Custom Metadata Types