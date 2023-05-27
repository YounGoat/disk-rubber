@ECHO OFF

SETLOCAL enableDelayedExpansion

SET CHAOS=chaos.txt
SET CHAOSEED=chaoseed.txt

IF EXIST %CHAOS% GOTO :FILL_INIT

:INIT
ECHO ... CHAOS ... > %CHAOSEED%
FOR /L %%i IN (1, 1, 100) DO (
	ECHO %%i:!RANDOM! >> %CHAOSEED%
)

MOVE /Y %CHAOSEED% %CHAOS% >NUL
FOR /L %%i IN (1, 1, 2) DO (
	MOVE %CHAOS% %CHAOSEED%
	FOR /L %%j IN (1, 1, 99) DO (
		MORE %CHAOSEED% >> %CHAOS%
	)
)
ECHO Chaos generated.

:FILL_INIT
dir /-c %CHAOS% > TMP
FOR /F "skip=6 tokens=3" %%i IN (TMP) DO (
	SET CHAOSIZE=%%i
	GOTO :FILL_INIT_BREAK
)
:FILL_INIT_BREAK
ECHO CHAOS SIZE: %CHAOSIZE%

MKDIR chaos\
SET /A INDEX=200
SET DIRNAME=

:ON_FILL
IF !INDEX! GTR 199 (
	FOR /F "tokens=1,2 DELIMS= " %%i IN ("%DATE%") DO (
		SET DATENAME=%%i
	)
	SET DATENAME=!DATENAME:/=.!
	SET TIMENAME=!TIME::=.!
	SET TIMENAME=!TIMENAME: =0!
	SET DIRNAME=!DATENAME!-!TIMENAME!
	ECHO !DIRNAME!
	SET DIRNAME=chaos\!DIRNAME!\
	MKDIR !DIRNAME!
	SET /A INDEX=1
)

FOR /F "tokens=3" %%i IN ('dir /-c') DO (
	SET FREESIZE=%%i
)
SET /A FREESIZE=%FREESIZE% 2>NUL && ECHO DO NOTHING >NUL || GOTO :DO_FILL
IF %FREESIZE% LSS %CHAOSIZE% GOTO :END

:DO_FILL
copy %CHAOS% %DIRNAME%%INDEX% >NUL
SET /A INDEX+=1
GOTO :ON_FILL

:END
ECHO The disk is ful-filled.