@echo off
REM see https://www.virtualbox.org/manual/ch08.html#vboxmanage-import

if "%~1"=="" (
  echo 'name of image to import is not specified'
  exit /B 1
)

REM set variables
SET BOX_PROJECT_DIR=%cd%
SET BOX_IMAGE_NAME=%~1

SET BOX_IMAGE_PATH=%BOX_PROJECT_DIR%\\output\\%BOX_IMAGE_NAME%\\%BOX_IMAGE_NAME%.ovf
if NOT exist "%BOX_IMAGE_PATH%" (
  echo Image with name %BOX_IMAGE_NAME% not found in %BOX_IMAGE_PATH%
  exit /B 1
)

SET VM_NAME=test2-%BOX_IMAGE_NAME%

REM Call parent might come in handy
REM CALL :PARENT_PATH "%BIN_DIR%\.." OUTPUT_PATH

REM set import profile. change to empty string to see vbox suggestions
SET VM_IMPORT_PROFILE=--cpus 1 --memory 2048 --unit 6 --ignore --unit 7 --ignore --unit 8 --ignore
vboxmanage import "%BOX_IMAGE_PATH%" --vsys 0 %VM_IMPORT_PROFILE% --vmname "%VM_NAME%"
echo Instance named %VM_NAME% was imported

:PARENT_PATH
REM use temp variable to hold the path, so we can substring
SET __PATH=%~f1
REM strip the trailing slash, so we can call it again to get its parent
SET %2=%__PATH%
GOTO :EOF
