# Pull EPIC data into your ORG using FHIR APIs

This is a working demo that leverages the fhir.epic.com API sandbox to demonstrate how easy it is to pull EPIC data into Health Cloud.

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
keytool -keystore FHIRDEMO_KEYSTORE_v2.jks -changealias -alias 1 -destalias FHIRDEMO_CERT_v2```

<a href="https://githubsfdeploy.herokuapp.com">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/deploy.png">
</a>
