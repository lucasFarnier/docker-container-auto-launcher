# Define the first script block for starting the Docker container
$dockerScript = {
    Write-Output "Starting Docker container..."

    # Run the Docker container in the background
    Start-Process "docker" -ArgumentList "run", "-it", "--rm", "-p", "3390:3389", "-p", "2022:22", "--name=ntu-vm-comp20081", "-v", "docker_comp20081:/home/ntu-user/NetBeansProjects", "pedrombmachado/ntu_lubuntu:comp20081"

    Write-Output "Docker container started."
}

# Define the second script block for waiting and launching mstsc
$mstscScript = {
    Write-Output "Waiting for 20 seconds..."
    Start-Sleep -Seconds 11

    Write-Output "Launching mstsc..."
    Start-Process "mstsc" -ArgumentList "/v:localhost:3390", "/console"

    Write-Output "mstsc launched."
}

# Create a RunspacePool to manage multiple threads
$runspacePool = [runspacefactory]::CreateRunspacePool(1, [Environment]::ProcessorCount)
$runspacePool.Open()

# Create and configure the first runspace for Docker
$dockerRunspace = [powershell]::Create().AddScript($dockerScript)
$dockerRunspace.RunspacePool = $runspacePool

# Create and configure the second runspace for mstsc
$mstscRunspace = [powershell]::Create().AddScript($mstscScript)
$mstscRunspace.RunspacePool = $runspacePool

# Start the runspaces (threads)
$dockerStatus = $dockerRunspace.BeginInvoke()
$mstscStatus = $mstscRunspace.BeginInvoke()

# Wait for both runspaces to finish
$dockerRunspace.EndInvoke($dockerStatus)
$mstscRunspace.EndInvoke($mstscStatus)

# Clean up runspaces
$dockerRunspace.Dispose()
$mstscRunspace.Dispose()
$runspacePool.Close()
$runspacePool.Dispose()
