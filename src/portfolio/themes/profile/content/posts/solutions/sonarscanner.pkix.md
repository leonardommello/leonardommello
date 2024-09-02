SONAR SCANNER
Error: PKIX path building failed: sun.security.provider.certpath.SunCertPathBuilderException: unable to find valid certification path to requested target

Solution:
```bash
keytool -import -trustcacerts -keystore $SONAR_SCANNER_HOME/**/jre/lib/security/cacerts -storepass changeit -noprompt -alias ALIAS -file CERT-FILE-TO-IMPORT
```
