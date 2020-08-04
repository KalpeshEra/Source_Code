Declare @CoreCount int = 1,
		@i int = 1,
		@sql nvarchar(max),
		@sql_version varchar(4),
		@debug int = 1;

		Select @sql_version =  CASE SUBSTRING(CONVERT(VARCHAR(50), SERVERPROPERTY('productversion')), 1, 2)
								  WHEN '8.' THEN '2000'
								  WHEN '9.' THEN '2005'
								  WHEN '10' THEN '2008'
								  WHEN '11' THEN '2012'
								  When '12' Then '2014'
								  When '13' Then '2016'
								  When '14' Then '2017'
								  Else '' END

Select	@CoreCount = CASE WHEN hyperthread_ratio = cpu_count THEN cpu_count
        ELSE ([cpu_count] / [hyperthread_ratio]) * (([cpu_count] - [hyperthread_ratio]) / ([cpu_count] / [hyperthread_ratio]))
		End 
From	sys.dm_os_sys_info

While @i <= @CoreCount and @i <= 8 Begin
	Set @Sql = 'Alter database tempdb
	add file 
	  (Name=tempdev' + Cast(@i + 1 as varchar(2)) + '
	   , filename=''T:\MSSQL' + @sql_version + '\TEMP\tempdb' + Cast(@i + 1 as varchar(2)) + '.mdf''
	   , size=8mb
	   , maxsize=unlimited
	   , FILEGROWTH = 10%)
	Alter database tempdb
	add log file 
	  (Name=templog' + Cast(@i + 1 as varchar(2)) + '
	   , filename=''T:\MSSQL' + @sql_version + '\TEMPLOG\templog' + Cast(@i + 1 as varchar(2)) + '.ldf''
	   , size=1mb
	   , maxsize=unlimited
	   , FILEGROWTH = 10%)'

		If @Debug = 1 
			Print @sql
		Else 
			Exec (@sql)

	   Set @i = @i + 1
End
