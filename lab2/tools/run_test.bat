::========================================================================================
call clean.bat
::========================================================================================
call build.bat
::========================================================================================
cd ../sim
@REM vsim -gui -do run.do
vsim -gui -do "do run.do %1"
