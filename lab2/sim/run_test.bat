@REM ::========================================================================================
@REM call clean.bat
@REM ::========================================================================================
@REM call build.bat
@REM ::========================================================================================
@REM cd ../sim
@REM vsim -gui -do run.do
@REM vsim -gui -do "do run.do %1"

vsim -c -do "do run.do %1"



