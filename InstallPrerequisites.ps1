
# Download and install the appropriate Java Runtime Environment for your OS
$OSVersion = Get-WmiObject -ComputerName localhost Win32_OperatingSystem | select OSArchitecture
if ($OSVersion = "@{OSArchitecture=64-bit}"){
    $JRE = "$env:USERPROFILE\Downloads\JRE64.exe"
    Invoke-WebRequest http://javadl.sun.com/webapps/download/AutoDL?BundleId=106248 -OutFile $JRE
} else {
    $JRE = "$env:USERPROFILE\Downloads\JRE32.exe"
    Invoke-WebRequest http://javadl.sun.com/webapps/download/AutoDL?BundleId=106246 -OutFile $JRE
}
Start-Process -FilePath $JRE -ArgumentList "/s" -PassThru -Wait

