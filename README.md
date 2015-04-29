# SQ-TFS.Scripts
Automation scripts for installing SonarQube and integrating it with Team Foundation Server

Scripts based on the scenario described by the [SonarQube Installation Guide for Existing TFS Environment](https://vsarguidance.codeplex.com/downloads/get/1452516) from the Visual Studio ALM Rangers

## InstallSonarQube
### Prerequisites
You'll need to install and configure SQL Server as per the linked guide, and install the appropriate version of the JRE.

### Parameters
* DatabaseServer - Database Server name
* NamedInstance - Named Instance, optional
* DatabaseName - Name of the database used for SonarQube
* User - SQL Server user set for the SonarQube database
* Password - Password of the above user
* Port - Which port to run SonarQube
* BinaryStore - Root folder for SonarQube

## InstallSonarRunner
### Parameters
* BinaryStore - Root folder for SonarQube Runner
* SonarServer - Server name of the SonarQube Server
* SonarPort - Port of the SonarQube Server
* MSBuildv12 - Run on TFS 2013 (MSBuild 12.0), boolean
* MSBuildv14 - Run on TFS 2015 (MSBuild 14.0), boolean
