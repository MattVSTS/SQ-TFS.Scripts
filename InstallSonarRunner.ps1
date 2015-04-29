# InstallSonarQube.ps1 - script for automatically installing SonarQube Runner 2.4 and Sonar MSBuild Runner 0.9
# It automates the scenario described in the SonarQube Installation Guide for Existing TFS Environment by the Visual Studio ALM Rangers
# https://vsarguidance.codeplex.com/downloads/get/1452516
#
# matteo.emili@live.com || http://mattvsts.blogspot.com || @MattVSTS 
# This script works on my machine and on my lab. I decline every responsibilities for problems you might have!

param (
$BinaryStore = "C:\SonarQube",
$SonarServer = "SAMPLE",
$SonarPort = 9090,
[bool]$MSBuildv12 = $true,
[bool]$MSBuildv14 = $false
)

New-Item -Force -ItemType Directory -Path $BinaryStore

$RunnerDLPath = "http://repo1.maven.org/maven2/org/codehaus/sonar/runner/sonar-runner-dist/2.4/sonar-runner-dist-2.4.zip"
$MSBuildRunnerDLPath = "http://dist.sonarsource.com/csharp/download/SonarQube.MSBuild.Runner-0.9.zip"

$RunnerZIP = "$BinaryStore\sonar-runner-dist-2.4.zip"
$MSBuildRunnerZIP = "$BinaryStore\SonarQube.MSBuild.Runner-0.9.zip"

Invoke-WebRequest $RunnerDLPath -OutFile $RunnerZIP

# Unblock the downloaded file
Get-ChildItem $BinaryStore -Recurse | Unblock-File

# Extract Sonar Runner
Add-Type -Assembly "System.IO.Compression.FileSystem"
[IO.Compression.ZipFile]::ExtractToDirectory($RunnerZIP, $BinaryStore)

# Change URL in sonar-runner.properties
$SonarRunnerProperties = "$BinaryStore\sonar-runner-2.4\conf\sonar-runner.properties"
(Get-Content $SonarRunnerProperties) | Foreach-Object {
    $_ -replace '^#sonar.host.url=http://localhost:9000$', ("sonar.host.url=http://$SonarServer"+":$SonarPort")
} | Set-Content $SonarRunnerProperties

# Change the PATH Environment Variable by adding the Sonar Runner bin path
$path = ";$BinaryStore\sonar-runner-2.4\bin"
[Environment]::SetEnvironmentVariable("PATH", $env:PATH+$path, "Machine" )

# Create the SONAR_RUNNER_HOME Environment Variable
[Environment]::SetEnvironmentVariable("SONAR_RUNNER_HOME", "$BinaryStore\sonar-runner-2.4", "Machine")

# Create the SONAR_RUNNER_OPTS Environment Variable
[Environment]::SetEnvironmentVariable("SONAR_RUNNER_OPTS", "-Xmx512m -XX:MaxPermSize=128m", "Machine")

# Download the MSBuild Sonar Runner
Invoke-WebRequest $MSBuildRunnerDLPath -OutFile $MSBuildRunnerZIP

# Extract Sonar Runner
Add-Type -Assembly "System.IO.Compression.FileSystem"
[IO.Compression.ZipFile]::ExtractToDirectory($MSBuildRunnerZIP, "$BinaryStore\bin")

# Copy the TARGETS file to the relevant MSBuild version

if ($MSBuildv12){
    $PathMSBv12 = ${env:ProgramFiles(x86)}+ "\MSBuild\12.0\Microsoft.Common.Targets\ImportBefore"
      
    if(!(Test-Path -Path $PathMSBv12)){
        New-Item -ItemType directory -Path $PathMSBv12
    }
    Copy-Item $BinaryStore\bin\SonarQube.Integration.ImportBefore.targets $PathMSBv12
    Restart-Service TFSBuildServiceHost.2013
}

if ($MSBuildv14){
    $PathMSBv14 = ${env:ProgramFiles(x86)}+ "\MSBuild\14.0\Microsoft.Common.Targets\ImportBefore"
      
    if(!(Test-Path -Path $PathMSBv14)){
        New-Item -ItemType directory -Path $PathMSBv14
    }
    Copy-Item $BinaryStore\bin\SonarQube.Integration.ImportBefore.targets $PathMSBv14
    Restart-Service TFSBuildServiceHost.2013
}








