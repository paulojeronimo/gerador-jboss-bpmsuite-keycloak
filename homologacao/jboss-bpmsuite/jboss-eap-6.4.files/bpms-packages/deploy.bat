@echo off

if "%OS%" == "Windows_NT" (
  set "DIRNAME=%~dp0%"
) else (
  set DIRNAME=.\
)

pushd "%DIRNAME%.."
set "JBOSS_HOME=%CD%"
popd

%JBOSS_HOME%\bin\jboss-cli.bat --file=%JBOSS_HOME%\bpms-packages\deploy.cli