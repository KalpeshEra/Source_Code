USE [msdb]
GO

/****** Object:  Job [DBA - Blocking Track]    Script Date: 3/8/2020 10:52:35 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 3/8/2020 10:52:35 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Blocking Track', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'This job will look at the current sessions in sysprocesses and log any lead blockers as well as blocked processes into a table in the DBA database named BlockedProcesses', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'SQL Server support', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [exec usp_TrackBlocking]    Script Date: 3/8/2020 10:52:35 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'exec usp_TrackBlocking', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec usp_TrackBlocking', 
		@database_name=N'DBA', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every Minute', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20190430, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'8d1bf798-7718-4f52-bc43-d9f32520b277'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [DBA - Check for Disk Latency]    Script Date: 3/8/2020 10:52:36 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 3/8/2020 10:52:36 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Check for Disk Latency', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'This monitors Disk Activity for a set period and returns the avg Disk Latency. If the avg Disk Latency is above a threshold 100ms then an email will be sent to the DBA Team', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'SQL Server support', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Execute Proc]    Script Date: 3/8/2020 10:52:36 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Execute Proc', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'Exec DBA.dbo.sp_IOTracking', 
		@database_name=N'DBA', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 minutes', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=15, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20180514, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'30bca1fd-5835-4f6f-85a9-991091cb4ae5'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [DBA - Check for new databases]    Script Date: 3/8/2020 10:52:36 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 3/8/2020 10:52:36 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Check for new databases', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'This is a daily check to see if any new databases have been created', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Run stored proc]    Script Date: 3/8/2020 10:52:37 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Run stored proc', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec DBA.dbo.usp_NewDatabasesAdded', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Daily at 7:30am', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20170413, 
		@active_end_date=99991231, 
		@active_start_time=73000, 
		@active_end_time=235959, 
		@schedule_uid=N'dad1ffe2-585d-411c-8691-b9ecd2cf6b15'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Daily at 7:30am', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20170413, 
		@active_end_date=99991231, 
		@active_start_time=73000, 
		@active_end_time=235959, 
		@schedule_uid=N'088fddb2-98f9-4e74-9726-f7c94c7c82ed'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [DBA - Load Current Connections]    Script Date: 3/8/2020 10:52:37 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 3/8/2020 10:52:37 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Load Current Connections', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'This process pulls a distinct list of all logins, host names, apps, and database name and loads it into a table. This information will provide us with insight into what connections are being made to SQL Server', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'SQL Server support', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Load Current Connections]    Script Date: 3/8/2020 10:52:37 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Load Current Connections', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'Exec DBA.dbo.sp_LoadCurrentConnections', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 3 minutes', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=3, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20170626, 
		@active_end_date=99991231, 
		@active_start_time=107, 
		@active_end_time=235959, 
		@schedule_uid=N'82fdcd38-cae3-48d4-89b4-878a3e47f934'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [DBA - Log SQL Permissions]    Script Date: 3/8/2020 10:52:38 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 3/8/2020 10:52:38 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Log SQL Permissions', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Log all Permissions Weekly', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Log SQL Permissions]    Script Date: 3/8/2020 10:52:38 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Log SQL Permissions', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC DBA.dbo.usp_logSQLPermissions', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Weekly @ 10 AM Sat', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=64, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20190904, 
		@active_end_date=99991231, 
		@active_start_time=100000, 
		@active_end_time=235959, 
		@schedule_uid=N'ff5766e1-67a0-43b1-8fcb-cc063908efa7'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [DBA - Long Running Query Alert]    Script Date: 3/8/2020 10:52:38 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[DBA - Monitoring]]    Script Date: 3/8/2020 10:52:38 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[DBA - Monitoring]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[DBA - Monitoring]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Long Running Query Alert', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Monitor Queries taking longest elapsed time if it''s above a threshold then an email will be sent to the DBA Team.', 
		@category_name=N'[DBA - Monitoring]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [longrunningquery]    Script Date: 3/8/2020 10:52:39 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'longrunningquery', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @xml NVARCHAR(max)
DECLARE @body NVARCHAR(max)
-- specify long running query duration threshold
DECLARE @longrunningthreshold int
SET @longrunningthreshold=120
-- step 1: collect long running query details.
;WITH cte
AS 
	(
	SELECT [Session_id]=spid,
	[Sessioin_start_time]=(SELECT start_time
	FROM sys.dm_exec_requests
	WHERE spid = session_id),
	[Session_status]=Ltrim(Rtrim([status])),
	[Session_Duration]=Datediff(mi, (SELECT start_time FROM sys.dm_exec_requests WHERE spid = session_id), Getdate()),
	[Session_query] = Substring (st.text, ( qs.stmt_start / 2 ) + 1,( ( CASE qs.stmt_end WHEN -1 THEN Datalength(st.text) ELSE qs.stmt_end END - qs.stmt_start ) / 2 ) + 1),
	[Session_User] = ltrim(rtrim(qs.loginame)),
	qs.[hostname]
	FROM sys.sysprocesses qs
	CROSS apply sys.Dm_exec_sql_text(sql_handle) st
	)
 -- step 2: generate html table 
SELECT @xml = Cast((SELECT session_id AS ''td'', '''',
session_duration AS ''td'', '''',
session_status AS ''td'', '''',
[session_query] AS ''td'', '''',
[session_user] AS ''td'', '''',
[hostname] as ''td'' , ''''  
FROM cte
WHERE session_duration >= @longrunningthreshold
and [session_user] not in ( ''XRAY\SQLService'' , ''XRAY\SQL-SSAS-P'',''XRAY\DBAMonitor'')
FOR xml path(''tr''), elements) AS NVARCHAR(max) )
 
-- step 3: do rest of html formatting
--Threshold '' + cast(@longrunningthreshold as varchar(5)) + '' Minutes

SET @body =
''<html><body><H2>Long Running Queries on NJCCNDB.carecorenational.com</H2> 
<H4>Need to take appropriate action</H4>
<table border = 1 BORDERCOLOR="Black"> 
<tr>
<th align="centre"> Session_id </th> 
<th> Session_Duration(Minute) </th> 
<th> Session_status </th> 
<th> Session_query </th>
<th> session_user </th>
<th> hostname </th> </tr>''

SET @body = @body + @xml + ''</table></body></html>''
 
-- step 4: send email if a long running query is found.
IF( @xml IS NOT NULL )
BEGIN
EXEC msdb.dbo.Sp_send_dbmail
@profile_name = ''eviCoreDBA_Profile'',
@body = @body,
@body_format =''html'',
@recipients = ''DBA.Group@Evicore.com'',
@subject = ''ALERT: Long Running Queries - NJCCNDB.carecorenational.com'';
END', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every2hours', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20160506, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'e23180ec-686b-470d-b90a-43223c1e1927'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [DBA - Top CPU/IO Queries]    Script Date: 3/8/2020 10:52:39 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Database Maintenance]    Script Date: 3/8/2020 10:52:39 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Maintenance' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Top CPU/IO Queries', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Email DBA Team Top CPU/IO Consuming Queries.', 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Email Top CPU/IO Consuming Queries]    Script Date: 3/8/2020 10:52:40 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Email Top CPU/IO Consuming Queries', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @tableHTML  NVARCHAR(MAX) ;
DECLARE @subj NVARCHAR(100);

SET @subj = ''Top CPU & IO Consuming Queries - '' + @@SERVERNAME

SET @tableHTML =
	N''<FONT SIZE=3 face=verdana>'' +
    N''<H3><Center>TOP 25 CPU Consuming Queries - '' + @@SERVERNAME + '' </Center></FONT></H3>'' +
    N''<table border="1">'' +
    N''<FONT SIZE=2 face=verdana>'' +
    N''<tr><th width=400>AVG CPU Time (s)</th>'' +
    N''<th width=200>Creation Time</th>'' +
    N''<th width=200>Last Execution Time</th>'' +
    N''<th width=300>Query Text</th>'' +
    N''<th width=100>Database</th></tr></Font>'' +  
    N''<FONT SIZE=1 face=verdana>'' +
    CAST ( ( SELECT TOP 25 
	    td = CONVERT(DECIMAL(6,2),(qs.total_worker_time/qs.execution_count)/1000000), '''',
                    td = CONVERT(CHAR(16),creation_time,120), '''',
                    td = CONVERT(CHAR(16),last_execution_time,120), '''',
                    td = SUBSTRING(qt.text,(qs.statement_start_offset/2) + 1,
								((case when qs.statement_end_offset = -1 then DATALENGTH(qt.text)
								else qs.statement_end_offset end -qs.statement_start_offset)/2)+1), '''',
                    td = db_name(qt.dbid), ''''
            FROM sys.dm_exec_query_stats qs
					cross apply sys.dm_exec_sql_text(qs.sql_handle) as qt
			WHERE 
					last_execution_time > DateADD(mi, -60, GETDATE())
			ORDER BY 1 DESC
            
            FOR XML PATH(''tr'')
    ) AS NVARCHAR(MAX) ) +
    N''</Font></table>'' ;

SET @tableHTML = @tableHTML +
	N''<FONT SIZE=3 face=verdana>'' +
    N''<H3><Center>TOP 25 IO Consuming Queries - '' + @@SERVERNAME + '' </Center></FONT></H3>'' +
    N''<table border="1">'' +
    N''<FONT SIZE=2 face=verdana>'' +
    N''<tr><th width=400>AVG IO Time (s)</th>'' +
    N''<th width=200>Creation Time</th>'' +
    N''<th width=200>Last Execution Time</th>'' +
    N''<th width=300>Query Text</th>'' +
    N''<th width=100>Database</th></tr></Font>'' +  
    N''<FONT SIZE=1 face=verdana>'' +
    CAST ( ( SELECT TOP 25 
	    td = CONVERT(DECIMAL(6,2),((qs.total_logical_reads + qs.total_logical_writes) /qs.execution_count)/1000000), '''',
                    td = CONVERT(CHAR(16),creation_time,120), '''',
                    td = CONVERT(CHAR(16),last_execution_time,120), '''',
                    td =  SUBSTRING(qt.text,(qs.statement_start_offset/2) + 1,
								((case when qs.statement_end_offset = -1 then DATALENGTH(qt.text)
								else qs.statement_end_offset end -qs.statement_start_offset)/2)+1), '''',
                    td = db_name(qt.dbid), ''''
            FROM sys.dm_exec_query_stats qs
					cross apply sys.dm_exec_sql_text(qs.sql_handle) as qt
			WHERE 
					last_execution_time > DateADD(mi, -60, GETDATE())
			ORDER BY 1 DESC
            
            FOR XML PATH(''tr'')
    ) AS NVARCHAR(MAX) ) +
    N''</Font></table>'' ;

SET @tableHTML = @tableHTML +
	N''<FONT SIZE=3 face=verdana>'' +
    N''<H3><Center>Current Executing Queries - '' + @@SERVERNAME + '' </FONT></H3>'' +
    N''<table border="1">'' +
    N''<FONT SIZE=2 face=verdana>'' +
    N''<tr><th width=200>Session ID</th>'' +
    N''<th width=200>Status</th>'' +
    N''<th width=300>Query Text</th>'' +
    N''<th width=100>Database</th>'' +  
    N''<th width=200>CPU Time (s)</th>'' +
    N''<th width=200>Total Elapsed Time (s)</th>'' +
    N''<th width=200>Reads</th>'' +
    N''<th width=200>Writes</th>'' +
    N''<th width=200>Logical Reads</th>'' +
    N''<th width=200>Scheduler ID</th></tr></Font>'' +
    N''<FONT SIZE=1 face=verdana>'' +
    CAST ( ( SELECT 
	    td = r.session_id, '''',
                    td = status, '''',                    
                    td = SUBSTRING(qt.text,(r.statement_start_offset/2) + 1,
								((case when r.statement_end_offset = -1 then DATALENGTH(qt.text)
								else r.statement_end_offset end -r.statement_start_offset)/2)+1), '''',
                    td = db_name(qt.dbid), '''',
                    td = CONVERT(DECIMAL(10,2),r.cpu_time/1000), '''',
                   td = CONVERT(DECIMAL(10,2),r.total_elapsed_time/1000), '''',
                    td = r.reads, '''',
                    td = r.writes, '''',
                    td = r.logical_reads, '''',
                    td = r.scheduler_id
            FROM sys.dm_exec_requests r
					cross apply sys.dm_exec_sql_text(sql_handle) as qt
			WHERE r.session_id > 50
			ORDER BY r.scheduler_id, r.status, r.session_id
            
            FOR XML PATH(''tr'')
    ) AS NVARCHAR(MAX) ) +
    N''</Center></Font></table>'' ;



EXEC msdb.dbo.sp_send_dbmail 
	@recipients=''DBA.Group@Evicore.com'',
	@subject = @subj,
	@body = @tableHTML,
	@body_format = ''HTML'' ;
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Bogus]    Script Date: 3/8/2020 10:52:40 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Bogus', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'select 1', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 30 Mins Week Days Work Hours', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=62, 
		@freq_subday_type=8, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20120202, 
		@active_end_date=99991231, 
		@active_start_time=80000, 
		@active_end_time=170000, 
		@schedule_uid=N'2b7230c7-267c-4ce4-88f9-1928699c9091'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [DBA - TransactionLogMonitoring]    Script Date: 3/8/2020 10:52:40 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 3/8/2020 10:52:40 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - TransactionLogMonitoring', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'T-SQL statements that are impacting the transaction log space.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Step1]    Script Date: 3/8/2020 10:52:40 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Step1', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N' INSERT INTO Queries_Impacting_Log
SELECT 
   GETDATE() AS [Current Time],
   [des].[login_name] AS [Login Name],
   DB_NAME ([dtdt].database_id) AS [Database Name],
   [dtdt].[database_transaction_begin_time] AS [Transaction Begin Time],
   [dtdt].[database_transaction_log_bytes_used] AS [Log Used Bytes],
   [dtdt].[database_transaction_log_bytes_reserved] AS [Log Reserved Bytes],
   SUBSTRING([dest].text, [der].statement_start_offset/2 + 1,(CASE WHEN [der].statement_end_offset = -1 THEN LEN(CONVERT(nvarchar(max),[dest].text)) * 2 ELSE [der].statement_end_offset END - [der].statement_start_offset)/2) as [Query Text]
FROM 
   sys.dm_tran_database_transactions [dtdt]
   INNER JOIN sys.dm_tran_session_transactions [dtst] ON  [dtst].[transaction_id] = [dtdt].[transaction_id]
   INNER JOIN sys.dm_exec_sessions [des] ON  [des].[session_id] = [dtst].[session_id]
   INNER JOIN sys.dm_exec_connections [dec] ON   [dec].[session_id] = [dtst].[session_id]
   LEFT OUTER JOIN sys.dm_exec_requests [der] ON [der].[session_id] = [dtst].[session_id]
   CROSS APPLY sys.dm_exec_sql_text ([dec].[most_recent_sql_handle]) AS [dest]
WHERE [des].[session_id] <> @@spid
AND ([dtdt].[database_transaction_begin_time] > 0 OR [dtdt].[database_transaction_log_bytes_reserved] > 0 )
GO', 
		@database_name=N'DBA', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Step2]    Script Date: 3/8/2020 10:52:40 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Step2', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE DBA
GO
DELETE TOP(1000)
FROM Queries_Impacting_Log
WHERE CaptureTime < DATEADD(DAY,-7,GETDATE())', 
		@database_name=N'DBA', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'My Schedule', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=2, 
		@freq_subday_interval=30, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20181223, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'1abe0f05-7238-4ad8-af37-a2b20d311bca'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [DBA - Update Statistics]    Script Date: 3/8/2020 10:52:41 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Database Maintenance]    Script Date: 3/8/2020 10:52:41 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Maintenance' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Update Statistics', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Update Statistics]    Script Date: 3/8/2020 10:52:41 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Update Statistics', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXECUTE DBA.dbo.IndexOptimize
@Databases = ''USER_DATABASES'',
@FragmentationLow = NULL,
@FragmentationMedium = NULL,
@FragmentationHigh = NULL,
@UpdateStatistics = ''ALL''
--@OnlyModifiedStatistics = ''Y''', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Schedule 1', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20100512, 
		@active_end_date=99991231, 
		@active_start_time=190000, 
		@active_end_time=235959, 
		@schedule_uid=N'77b3ec66-3278-47a7-87e4-d52d5c4f53f1'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [DBA - Update useage]    Script Date: 3/8/2020 10:52:41 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Database Maintenance]    Script Date: 3/8/2020 10:52:41 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Maintenance' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA - Update useage', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'DBCC UPDATEUSAGE corrects the rows, used, reserved, and datapages columns of the sysindexes table for tables and clustered indexes. Size information is not maintained for nonclustered indexes.so it should typically be used only when you suspect incorrect values returned by sp_spaceused.', 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [updateuseage]    Script Date: 3/8/2020 10:52:42 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'updateuseage', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE [master];

DECLARE @DatabaseName varchar(128);
DECLARE @Message varchar(200);
DECLARE @SqlCmd varchar(8000);
DECLARE @ErrorNum int;
DECLARE @FailFlag bit;

DECLARE DatabaseList CURSOR LOCAL FORWARD_ONLY DYNAMIC READ_ONLY FOR
	SELECT [name] 
	FROM sysdatabases 
	WHERE DATABASEPROPERTYEX( [name], ''Status'' ) = ''ONLINE''
		AND DATABASEPROPERTYEX( [name], ''IsInStandBy'') <> 1
		AND [name] <> ''tempdb''
	ORDER BY [name];
OPEN DatabaseList;

FETCH NEXT FROM DatabaseList INTO @DatabaseName;

SET @FailFlag = 0;

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @Message = ''Database '' + QUOTENAME(@DatabaseName);
	RAISERROR( @Message, 0, 1 ) WITH NOWAIT;

	SET @SqlCmd = ''DBCC UPDATEUSAGE ( ['' + @DatabaseName + ''] ) WITH NO_INFOMSGS'';
	EXEC (@SqlCmd);
	
	SET @ErrorNum = @@ERROR;
	IF @ErrorNum <> 0
	BEGIN
		SET @Message = ''    Error - '' + CONVERT(varchar(20), @ErrorNum);
		RAISERROR( @Message, 10, 1 ) WITH NOWAIT;
		SET @FailFlag = 1;
	END;
	
	FETCH NEXT FROM DatabaseList INTO @DatabaseName;
END;

CLOSE DatabaseList;
DEALLOCATE DatabaseList;

IF @FailFlag = 1
BEGIN
	RAISERROR( ''Errors encountered'', 16, 1 );
END;
', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'weekly', 
		@enabled=1, 
		@freq_type=8, 
		@freq_interval=64, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=1, 
		@active_start_date=20110326, 
		@active_end_date=99991231, 
		@active_start_time=200000, 
		@active_end_time=235959, 
		@schedule_uid=N'188f1598-cd9f-4edf-8f6c-59ad3f0fbed4'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

/****** Object:  Job [DBA_DB_Growth]    Script Date: 3/8/2020 10:52:42 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[DBA - Monitoring]]    Script Date: 3/8/2020 10:52:42 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[DBA - Monitoring]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[DBA - Monitoring]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'DBA_DB_Growth', 
		@enabled=0, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[DBA - Monitoring]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Database Growth]    Script Date: 3/8/2020 10:52:42 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Database Growth', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'Exec DBA.[dbo].[usp_dba_growth]
Exec DBA.[dbo].[usp_disk_growth]', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Table Growth]    Script Date: 3/8/2020 10:52:43 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Table Growth', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'Exec DBA.[dbo].[usp_table_growth]', 
		@database_name=N'DBA', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Daily', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20180216, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'c51b910f-883b-4874-8f18-b9a71edb9afe'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO


