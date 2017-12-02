@ECHO OFF
ECHO Batch Example: FORFILES /P "D:\Arcade\Games\Sony Playstation 2" /M *.7z /C "cmd /c convert @path"
ECHO.

SETLOCAL EnableExtensions EnableDelayedExpansion

REM Should the created archive file be validated? (1=yes, 0=no)
SET Validate=0

REM Compression level: 1,3,5,7,9 (higher=slower but more compression)
SET CompressLevel=3

REM Delete source zip file on success? (1=yes, 0=no)
SET DeleteSourceOnSuccess=1


REM ---- Do not modify anything below this line ----

SET ArchiveFile=%1
SET DeepFile=%ArchiveFile:.7z=.gz%
SET tmpPath=D:\tmp\converting\%~nx1
SET tmpPathZip="%tmpPath%"
SET tmpPath="%tmpPath%"
SET tmpFile="%TEMP%tmpArchive.txt"

IF NOT EXIST %tmpPath% (
   MKDIR %tmpPath%
) ELSE (
   RMDIR /S /Q %tmpPath%
)

ECHO Extracting archive: %ArchiveFile%
7ZA x %ArchiveFile% -o%tmpPath%
ECHO.

ECHO Compressing archive: %DeepFile%
7ZA a -tGzip -mx%CompressLevel% %DeepFile% %tmpPathZip%\*
ECHO.

IF {%Validate%}=={1} (
   ECHO Validating archive: %DeepFile%
   7ZA t %DeepFile% | FIND /C "Everything is Ok" > %tmpFile%
   SET /P IsValid=< %tmpFile%
   IF !IsValid!==0 (
      ECHO Validation failed!
      DEL /F /Q %DeepFile%
      ECHO.
      GOTO Fail
   ) ELSE (
      ECHO Validation passed.
   )
   ECHO.
)
GOTO Success


:Success
IF {%DeleteSourceOnSuccess%}=={1} DEL /F /Q %ArchiveFile%
ECHO Success
GOTO End


:Fail
ECHO Failed
GOTO End


:End
IF EXIST %tmpFile% DEL /F /Q %tmpFile%
IF EXIST %tmpPath% RMDIR /S /Q %tmpPath%

ENDLOCAL
