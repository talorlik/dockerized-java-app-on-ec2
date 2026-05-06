@REM ---------------------------------------------------------------------------
@REM Apache Maven Wrapper, script-only mode (no jar checked in) - Windows.
@REM
@REM Resolves the Maven distribution declared in
@REM .mvn\wrapper\maven-wrapper.properties (distributionUrl +
@REM distributionSha256Sum), caches it under
@REM %MAVEN_USER_HOME%\wrapper\dists\<basename>\<urlhash>\, and runs the
@REM cached mvn with all forwarded arguments.
@REM ---------------------------------------------------------------------------

@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "PROJECT_BASEDIR=%~dp0"
if "%PROJECT_BASEDIR:~-1%"=="\" set "PROJECT_BASEDIR=%PROJECT_BASEDIR:~0,-1%"
set "MAVEN_PROJECTBASEDIR=%PROJECT_BASEDIR%"

set "WRAPPER_PROPS=%PROJECT_BASEDIR%\.mvn\wrapper\maven-wrapper.properties"
if not exist "%WRAPPER_PROPS%" (
  echo mvnw: missing %WRAPPER_PROPS% 1>&2
  exit /b 1
)

set "DIST_URL="
set "DIST_SHA="
for /f "usebackq tokens=1,* delims==" %%A in ("%WRAPPER_PROPS%") do (
  if /i "%%A"=="distributionUrl"        set "DIST_URL=%%B"
  if /i "%%A"=="distributionSha256Sum"  set "DIST_SHA=%%B"
)
if "%DIST_URL%"=="" (
  echo mvnw: distributionUrl is empty in %WRAPPER_PROPS% 1>&2
  exit /b 1
)

if not "%MVNW_REPOURL%"=="" (
  for /f "tokens=1,2,* delims=/" %%a in ("%DIST_URL%") do set "DIST_URL=%MVNW_REPOURL%/%%c"
)

for %%I in ("%DIST_URL%") do set "DIST_ARCHIVE=%%~nxI"
set "DIST_NAME=%DIST_ARCHIVE:-bin.zip=%"

set "MAVEN_USER_HOME_DIR=%MAVEN_USER_HOME%"
if "%MAVEN_USER_HOME_DIR%"=="" set "MAVEN_USER_HOME_DIR=%USERPROFILE%\.m2"

REM Per-URL hash so a re-pinned distribution gets a fresh cache directory.
for /f "delims=" %%H in ('powershell -NoProfile -Command "$sha=[System.Security.Cryptography.SHA256]::Create(); $h=$sha.ComputeHash([Text.Encoding]::UTF8.GetBytes('%DIST_URL%')); ($h | ForEach-Object { $_.ToString('x2') }) -join ''"') do set "DIST_URL_HASH=%%H"

set "WRAPPER_HOME=%MAVEN_USER_HOME_DIR%\wrapper\dists"
set "DIST_PARENT=%WRAPPER_HOME%\%DIST_NAME%\%DIST_URL_HASH%"
set "MVN_HOME=%DIST_PARENT%\%DIST_NAME%"

if not exist "%MVN_HOME%\bin\mvn.cmd" (
  if not exist "%DIST_PARENT%" mkdir "%DIST_PARENT%"
  set "ARCHIVE=%DIST_PARENT%\%DIST_ARCHIVE%"

  if not exist "!ARCHIVE!" (
    echo mvnw: downloading %DIST_URL% ... 1>&2
    powershell -NoProfile -Command "$ProgressPreference='SilentlyContinue'; Invoke-WebRequest -UseBasicParsing -Uri '%DIST_URL%' -OutFile '!ARCHIVE!.part'"
    if errorlevel 1 ( echo mvnw: download failed 1>&2 & exit /b 1 )
    move /y "!ARCHIVE!.part" "!ARCHIVE!" >nul
  )

  if not "%DIST_SHA%"=="" (
    for /f "delims=" %%S in ('powershell -NoProfile -Command "(Get-FileHash -Algorithm SHA256 -Path '!ARCHIVE!').Hash.ToLower()"') do set "ACTUAL_SHA=%%S"
    if /i not "!ACTUAL_SHA!"=="%DIST_SHA%" (
      del /q "!ARCHIVE!" >nul 2>&1
      echo mvnw: checksum mismatch (expected %DIST_SHA% got !ACTUAL_SHA!) 1>&2
      exit /b 1
    )
  )

  powershell -NoProfile -Command "Expand-Archive -Force -LiteralPath '!ARCHIVE!' -DestinationPath '%DIST_PARENT%'"
  if errorlevel 1 ( echo mvnw: extraction failed 1>&2 & exit /b 1 )
  del /q "!ARCHIVE!" >nul 2>&1
)

if not exist "%MVN_HOME%\bin\mvn.cmd" (
  echo mvnw: Maven not found at %MVN_HOME%\bin\mvn.cmd after extraction 1>&2
  exit /b 1
)

call "%MVN_HOME%\bin\mvn.cmd" %*
exit /b %ERRORLEVEL%
