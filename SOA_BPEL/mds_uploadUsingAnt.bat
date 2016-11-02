rem This script use Ant to deploy the SOA MDS to an environnment
rem replace variable with your installations

cd %MDS_FOLDER_TO_DEPLOY%

%MW_JDK_HOME%\bin\jar.exe cvf Custom.jar ./

%MW_HOME%\jdeveloper\ant\bin\ant -f %MW_HOME%\jdeveloper\bin\ant-sca-deploy.xml -DserverURL=http://%SERVER_URL%:%SERVER_PORT% -DsarLocation=Custom.jar -Doverwrite=true -Duser=%USER% -Dpassword=%PASSWORD% -DforceDefault=true -DfailOnError=true deploy

pause
