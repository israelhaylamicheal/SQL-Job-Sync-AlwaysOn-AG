# SqlJobSync-AlwaysOn-AG
This PowerShell script syncs SQL Server Agent jobs in Always On Availability Groups (AG). It identifies primary and secondary replicas for specified AG Listeners, retrieves agent jobs from the primary replica, and copies them to secondary replicas, ensuring consistent job execution across the AG environment.
