this script automates launching and running docker and remote access to access the docker container 
------------------------------------------------------------------------------------------------------
before running the program you must set the execution policy to allow it to run the script

to do this:
-open windows powershell in administrator
-enter "Set-ExecutionPolicy unrestricted"

now the script is able to run

the docker container your trying to run should also be already added/pulled to the docker application
------------------------------------------------------------------------------------------------------
the docker container that you want to open can also be changed for example
to do this:
-go to line 6 of the script, can be open in notepad, PowerShell ISE  or most text based applications
-edit onwards from "-ArgumentList" to be the docker container you want to launch
-may also be a need to edit line 17 for the remote access of the docker container to be correct
------------------------------------------------------------------------------------------------------
to end
close the docker console page that appears
it will proceed to close docker and all related applications as well as this programs applications
------------------------------------------------------------------------------------------------------
issue
if docker doesnt lauch properly when first running, rerun the program
