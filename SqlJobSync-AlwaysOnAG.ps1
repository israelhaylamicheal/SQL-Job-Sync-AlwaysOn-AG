Clear-Host

Set-DbatoolsConfig -FullName sql.connection.trustcert -Value $true -Register
Set-DbatoolsConfig -FullName sql.connection.encrypt -Value $false -Register 

# Define the list of SQL Server AG Listeners
$SqlInstances = @(
    "Listener1",
    "Listener2",
    "Listener3"
)

# Query to get availability replicas and their roles
$SqlCmd = @"
SELECT DISTINCT 
    replica_server_name AS ReplicaServerName, 
    is_primary_replica AS IsPrimaryReplica
FROM 
    [master].[sys].[availability_replicas] t1
INNER JOIN 
    [master].[sys].[dm_hadr_database_replica_states] t2
ON 
    t1.group_id = t2.group_id 
    AND t1.replica_id = t2.replica_id
"@

# Iterate through each SQL Server instance
foreach ($SqlInstance in $SqlInstances) {
    try {
        # Get replica information
        $ReplicaInstances = Invoke-Sqlcmd -ServerInstance $SqlInstance -Database master -Query $SqlCmd -TrustServerCertificate -Verbose
        
        # Identify primary and secondary replicas
        $PrimaryReplica = ($ReplicaInstances | Where-Object { $_.IsPrimaryReplica -eq 1 }).ReplicaServerName
        $SecondaryReplicas = ($ReplicaInstances | Where-Object { $_.IsPrimaryReplica -eq 0 }).ReplicaServerName

        if (-not $PrimaryReplica) {
            Write-Warning "No primary replica found for instance: $($SqlInstance)"
            continue
        }

        if (-not $SecondaryReplicas) {
            Write-Warning "No secondary replicas found for instance: $($SqlInstance)"
            continue
        }

        # Get agent jobs from the primary replica
        $AgentJobs = Get-DbaAgentJob -SqlInstance $PrimaryReplica

        # Copy each job to the secondary replicas
        foreach ($SecondaryReplica in $SecondaryReplicas) {
            foreach ($Job in $AgentJobs) {
                try {
                    Write-Verbose "Copying job '$($Job.Name)' from $PrimaryReplica to $SecondaryReplica"
                    Copy-DbaAgentJob -Source $PrimaryReplica -Destination $SecondaryReplica -Job $Job.Name -ErrorAction Stop -Verbose
                } catch {
                    Write-Error "Failed to copy job '$($Job.Name)' to $($SecondaryReplica): $_"
                }
            }
        }
    } catch {
        Write-Error "An error occurred while processing instance $($SqlInstance): $_"
        throw;
    }
}
