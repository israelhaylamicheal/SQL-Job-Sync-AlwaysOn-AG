# SqlJobSync-AlwaysOn-AG
This PowerShell script automates the synchronization of SQL Server Agent jobs across Availability Groups (AG) in a SQL Server Always On environment. The script identifies the primary and secondary replicas of each specified AG Listener, retrieves the agent jobs from the primary replica, and ensures these jobs are copied to the secondary replicas for consistent job execution across the AG setup.

Requirements:
dbatools Module: Ensure the dbatools PowerShell module is installed for using Get-DbaAgentJob and Copy-DbaAgentJob.
Sql Server Module: Ensure the Sql Server PowerShell module is installed for using Invoke-SqlCmd Command.
SQL Server Permissions: Sufficient permissions on the SQL Server instances to retrieve job details and perform the job copy operation.
SQL Server Instances: Ensure the provided AG Listeners are accessible and configured with proper permissions.
