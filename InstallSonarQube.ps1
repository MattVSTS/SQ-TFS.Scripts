# InstallSonarQube.ps1 - script for automatically installing SonarQube 5.1
# It automates the scenario described in the SonarQube Installation Guide for Existing TFS Environment by the Visual Studio ALM Rangers
# https://vsarguidance.codeplex.com/downloads/get/1452516
#
# matteo.emili@live.com || http://mattvsts.blogspot.com || @MattVSTS 
# This script works on my machine and on my lab. I decline every responsibilities for problems you might have!

param (
$DatabaseServer = "DB",
$NamedInstance = "INSTANCE",
$DatabaseName = "SONAR",
$User = "SAMPLE",
$Password = "SAMPLE",
$Port = "9090",
$BinaryStore = "C:\SonarQube"
)

New-Item -Force -ItemType Directory -Path $BinaryStore

# Paths for SonarQube 5.1, C# Plugin 4.0
$SonarDLPath = "http://dist.sonar.codehaus.org/sonarqube-5.1.zip"
$CsPluginDLPath = "http://repository.codehaus.org/org/codehaus/sonar-plugins/dotnet/csharp/sonar-csharp-plugin/4.0/sonar-csharp-plugin-4.0.jar"

# Download SonarQube 5.1
$SonarZIP = "$BinaryStore\sonarqube-5.1.zip"
Invoke-WebRequest $SonarDLPath -OutFile $SonarZIP

# Unblock the downloaded file
Get-ChildItem $BinaryStore -Recurse | Unblock-File

# Extract SonarQube
Add-Type -Assembly "System.IO.Compression.FileSystem"
[IO.Compression.ZipFile]::ExtractToDirectory($SonarZIP, $BinaryStore)

# Delete the zip file
Remove-Item $SonarZIP

# Change User in sonar.properties
$SonarProperties = "$BinaryStore\sonarqube-5.1\conf\sonar.properties"
(Get-Content $SonarProperties) | Foreach-Object {
    $_ -replace '^#sonar.jdbc.username=sonar$', ("sonar.jdbc.username="+$User)
} | Set-Content $SonarProperties

# Change Password in sonar.properties
$SonarProperties = "$BinaryStore\sonarqube-5.1\conf\sonar.properties"
(Get-Content $SonarProperties) | Foreach-Object {
    $_ -replace '^#sonar.jdbc.password=sonar$', ("sonar.jdbc.password="+$Password)
} | Set-Content $SonarProperties

# Change Database in sonar.properties
$SonarProperties = "$BinaryStore\sonarqube-5.1\conf\sonar.properties"
if (![string]::IsNullOrEmpty($NamedInstance)) {
    $DatabaseInstance = "$DatabaseServer\$NamedInstance"
} 
else {
    $DatabaseInstance = $Database
}

(Get-Content $SonarProperties) | Foreach-Object {
    $_ -replace '^#sonar.jdbc.url=jdbc:jtds:sqlserver://localhost/sonar;SelectMethod=Cursor$', ("sonar.jdbc.url=jdbc:jtds:sqlserver://$DatabaseInstance/$DatabaseName;SelectMethod=Cursor")
} | Set-Content $SonarProperties

# Change Port in sonar.properties
$SonarProperties = "$BinaryStore\sonarqube-5.1\conf\sonar.properties"
(Get-Content $SonarProperties) | Foreach-Object {
    $_ -replace '^#sonar.web.port=9000$', ("sonar.web.port="+$Port)
} | Set-Content $SonarProperties

# Download the Sonar C# Plugin to the extensions\plugin folder
$CsPluginJAR = "$BinaryStore\sonarqube-5.1\extensions\plugins\sonar-csharp-plugin-4.0.jar"
Invoke-WebRequest $CsPluginDLPath -OutFile $CsPluginJAR

# Run SonarQube
Start-Process -FilePath $BinaryStore\sonarqube-5.1\bin\windows-x86-64\StartSonar.bat -Wait