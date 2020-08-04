USE [msdb]
GO

if Not exists(select * From sysoperators Where sysoperators.name = 'SQL Server support') 
Begin
	-- Create operator
	EXEC msdb.dbo.sp_add_operator @name=N'SQL Server support', 
		@enabled=1, 
		--@weekday_pager_start_time=90000, 
		--@weekday_pager_end_time=180000, 
		--@saturday_pager_start_time=90000, 
		--@saturday_pager_end_time=180000, 
		--@sunday_pager_start_time=90000, 
		--@sunday_pager_end_time=180000, 
		--@pager_days=0, 
		@email_address=N'DBA.Group@evicore.com', 
		@category_name=N'[Uncategorized]'
End

--Enable Alert Mail profile for the Agent
USE [msdb]
GO
EXEC master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent', N'UseDatabaseMail', N'REG_DWORD', 1
GO
EXEC master.dbo.xp_instance_regwrite N'HKEY_LOCAL_MACHINE', N'SOFTWARE\Microsoft\MSSQLServer\SQLServerAgent', N'DatabaseMailProfile', N'REG_SZ', N'eviCoreDBA_Profile'
GO
EXEC msdb.dbo.sp_set_sqlagent_properties @email_save_in_sent_folder=1
GO

--Create the corruption alerts
USE [msdb]
GO
EXEC msdb.dbo.sp_add_alert @name=N'823 - IO Read Failure', 
		@message_id=823, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_alert @name=N'824 - IO Checksum Failure', 
		@message_id=824, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_alert @name=N'825 - Read Retry Error', 
		@message_id=825, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO
EXEC msdb.dbo.sp_add_alert @name=N'832 - In-Memory Checksum Failure', 
		@message_id=832, 
		@severity=0, 
		@enabled=1, 
		@delay_between_responses=60, 
		@include_event_description_in=1, 
		@category_name=N'[Uncategorized]', 
		@job_id=N'00000000-0000-0000-0000-000000000000'
GO
-- These will only work if the SQL Server support Operator exists
EXEC msdb.dbo.sp_add_notification @alert_name=N'823 - IO Read Failure', @operator_name=N'SQL Server support', @notification_method = 1
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'824 - IO Checksum Failure', @operator_name=N'SQL Server support', @notification_method = 1
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'825 - Read Retry Error', @operator_name=N'SQL Server support', @notification_method = 1
GO
EXEC msdb.dbo.sp_add_notification @alert_name=N'832 - In-Memory Checksum Failure', @operator_name=N'SQL Server support', @notification_method = 1
GO


