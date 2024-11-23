Write-Output "Starting Docker container..."

# Launch Docker Desktop
Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"
Write-Host "Launching Docker Desktop..."
#try catch with "docker ps", if runs docker is running and it continues script
$dockerStarted = $false
while($dockerStarted -eq $false)
{
	try {
		Write-Output "Trying to run Docker."
		$dockerStarted = docker ps
		if($dockerStarted -eq $true)
		{
			Write-Output "Docker is running."
			break
		}
	}
	catch {
		Write-Output "Docker not started, checking again."
	    	Write-Output "Waiting for 10 seconds to retry..."
	}
	Write-Output "Waiting for 10 seconds to retry..."
   	Start-Sleep -Seconds 10
}

# Create a runspace pool for multithreading (allowing 3 threads)
$runspacePool = [runspacefactory]::CreateRunspacePool(1, 3) 
$runspacePool.Open()

# Define the first script block for starting the Docker container
$dockerScript = {
    Start-Process "docker" -ArgumentList "run", "-it", "--rm", "-p", "3390:3389", "-p", "2022:22", "--name=ntu-vm-comp20081", "-v", "docker_comp20081:/home/ntu-user/NetBeansProjects", "pedrombmachado/ntu_lubuntu:comp20081"
    Write-Output "Docker container started."
}

# Define the second script block for launching mstsc
$mstscScript = {
    Write-Output "Waiting for 10 seconds..."
    Start-Sleep -Seconds 10
    Write-Output "Launching mstsc..."
    Start-Process "mstsc" -ArgumentList "/v:localhost:3390", "/console"
    Write-Output "mstsc launched."
}

# Define the third script block for monitoring the Docker container
$monitorDockerScript = {
    Start-Sleep -Seconds 10

    $checker = $false
    while ($checker -eq $false) {
	  # Get the container's running state using docker inspect
	  $runningState = docker container inspect -f '{{.State.Running}}' "ntu-vm-comp20081"

	  # Check if the container is running
	  if ($runningState -eq $true) {
    		  Write-Output "The container is running."
	  } 
	  else {
    	  	  Write-Output "The container is not running."
	  }

        # Sleep before checking again
        Start-Sleep -Seconds 10
    }
}


# Create runspaces for each script
$runspace1 = [powershell]::Create().AddScript($dockerScript)
$runspace1.RunspacePool = $runspacePool

$runspace2 = [powershell]::Create().AddScript($mstscScript)
$runspace2.RunspacePool = $runspacePool

$runspace3 = [powershell]::Create().AddScript($monitorDockerScript)
$runspace3.RunspacePool = $runspacePool
# Start the third script (Docker container monitoring) in a new PowerShell window
Start-Process powershell -ArgumentList "-NoExit", "-Command", $monitorDockerScript

# Start the threads
$handle1 = $runspace1.BeginInvoke()
$handle2 = $runspace2.BeginInvoke()
$handle3 = $runspace3.BeginInvoke()

Write-Host "Scripts are running in parallel threads. Press Ctrl+C to stop the original script."

# Keep the main script running to allow threads to execute
while ($true) {
    Start-Sleep -Seconds 1
}

# Clean up (optional in an infinite loop)
$runspace1.Stop()
$runspace2.Stop()
$runspace3.Stop()
$runspace1.Dispose()
$runspace2.Dispose()
$runspace3.Dispose()
$runspacePool.Close()
$runspacePool.Dispose()
