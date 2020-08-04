USE [msdb]
GO

/****** Object:  Operator [SQL Server support]    Script Date: 2/18/2020 4:44:42 PM ******/
EXEC msdb.dbo.sp_add_operator @name=N'SQL Server support', 
		@enabled=1, 
		@weekday_pager_start_time=90000, 
		@weekday_pager_end_time=180000, 
		@saturday_pager_start_time=90000, 
		@saturday_pager_end_time=180000, 
		@sunday_pager_start_time=90000, 
		@sunday_pager_end_time=180000, 
		@pager_days=0, 
		@email_address=N'DBA.Group@evicore.com', 
		@category_name=N'[Uncategorized]'
GO


