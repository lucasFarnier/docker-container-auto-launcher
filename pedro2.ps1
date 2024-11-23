Write-Output "Starting Docker container..."

#run/launch docker
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
	Write-Output "Waiting for 5 seconds to retry..."
   	Start-Sleep -Seconds 5
}


# Define the first script block for starting the Docker container
$dockerScript = {
    #Run the Docker container in the background
    Start-Process "docker" -ArgumentList "run", "-it", "--rm", "-p", "3390:3389", "-p", "2022:22", "--name=ntu-vm-comp20081", "-v", "docker_comp20081:/home/ntu-user/NetBeansProjects", "pedrombmachado/ntu_lubuntu:comp20081"

    Write-Output "Docker container started."
}

# Define the second script block for waiting and launching mstsc
$mstscScript = {
    Write-Output "Waiting for 10 seconds..."
    Start-Sleep -Seconds 10

    Write-Output "Launching mstsc..."
    Start-Process "mstsc" -ArgumentList "/v:localhost:3390", "/console"

    Write-Output "mstsc launched."
}


# Create a RunspacePool to manage multiple threads
$runspacePool = [runspacefactory]::CreateRunspacePool(1, [Environment]::ProcessorCount)
$runspacePool.Open()

# Create and configure the second runspace for Docker
$dockerRunspace = [powershell]::Create().AddScript($dockerScript)
$dockerRunspace.RunspacePool = $runspacePool

# Create and configure the third runspace for mstsc
$mstscRunspace = [powershell]::Create().AddScript($mstscScript)
$mstscRunspace.RunspacePool = $runspacePool

# Start the runspaces (threads)
$dockerStatus = $dockerRunspace.BeginInvoke()
$mstscStatus = $mstscRunspace.BeginInvoke()


# Wait for all runspaces to finish
$dockerRunspace.EndInvoke($dockerStatus)
$mstscRunspace.EndInvoke($mstscStatus)

# Clean up runspaces
$dockerRunspace.Dispose()
$mstscRunspace.Dispose()

$runspacePool.Close()
$runspacePool.Dispose()
