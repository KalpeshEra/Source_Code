-- Change Advanced Options
Exec sp_configure 'show advanced options',1
Reconfigure
Exec sp_configure 'cost threshold for parallelism', 15; --Cost Threshold for Parallelism
EXEC sp_configure 'optimize for ad hoc workloads', 1 -- ad hoc workload
exec sp_configure 'xp_cmdshell',1 --cmdshell
exec sp_configure 'Database Mail XPs',1 -- DBMail
exec sp_configure 'remote admin connections', 1 --DOC
EXEC sys.sp_configure N'backup compression default', N'1' --Backup Compression
EXEC SP_CONFIGURE 'optimize for ad hoc workloads', 1 -- Enable Optimize For Ad Hoc Workloads

GO