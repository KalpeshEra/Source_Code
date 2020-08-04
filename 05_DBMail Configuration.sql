-- 01 Configure Database Mail
-- Declare Variables
Declare @MaxMemory int,
		@ServerMemory int,
		@profile_name sysname,
        @account_name sysname,
        @SMTP_servername sysname,
        @email_address NVARCHAR(128),
		@replyto_address NVARCHAR(128),
	    @display_name NVARCHAR(128),
		@sql_version varchar(4),
		--@sql_INTG_prod varchar(25),
		@CoreCount int = 1,
		@sql nvarchar(max),
		
		-- TODO: Update logic to honor debug flag, only currently implemented for TempDB script
		-- Print the tempdb query, don't execute
		@Debug int = 0;

		Select @sql_version =  CASE SUBSTRING(CONVERT(VARCHAR(50), SERVERPROPERTY('productversion')), 1, 2)
								  WHEN '8.' THEN '2000'
								  WHEN '9.' THEN '2005'
								  WHEN '10' THEN '2008'
								  WHEN '11' THEN '2012'
								  When '12' Then '2014'
								  When '13' Then '2016'
								  When '13' Then '2017'
								  Else '' END

		--select @sql_INTG_prod = Case Substring(@@servername,4,1)
		--						When 'D' Then 'Dev'
		--						When 'I' Then 'INTG'
		--						When 'S' Then 'STG'
		--						When 'P' Then 'Prod'
		--						Else '' End
		
		Select	@CoreCount = CASE When virtual_machine_type = 1 Then cpu_count -- virtual machine
				WHEN hyperthread_ratio = cpu_count THEN cpu_count
				ELSE ([cpu_count] / [hyperthread_ratio]) * (([cpu_count] - [hyperthread_ratio]) / ([cpu_count] / [hyperthread_ratio]))
				End
		From	sys.dm_os_sys_info

-- Profile name. Replace with the name for your profile
        SET @profile_name = 'eviCoreDBA_Profile';

-- Account information for mail profile. Replace with the information for your account.
		SET @account_name = 'eviCoreDBA';
		SET @SMTP_servername = 'smtp.carecorenational.com';
		SET @email_address = 'DBA.Group@evicore.com';
		SET @replyto_address = 'DBA.Group@evicore.com';
        SET @display_name = 'SQLServer' + @sql_version + ' ' + @@ServerName;


-- 01.1 DBMail Pre-Setup
USE [msdb]
If Not Exists (select * From sys.database_principals Where name = 'NYMINT\DBAMonitor')
	CREATE USER [NYMINT\DBA Team] FOR LOGIN [NYMINT\DBAMonitor]
--If Not Exists (select * From sys.database_principals Where  name = 'NYMINT\DBA.Group')
--	CREATE USER [NYMINT\DBA.Group] FOR LOGIN [NYMINT\DBA.Group]

-- 01.2 DBMail Setup

-- Verify the specified account and profile do not already exist.
IF EXISTS (SELECT * FROM msdb.dbo.sysmail_profile WHERE name = @profile_name)
BEGIN
  RAISERROR('The specified Database Mail profile (eviCoreDBA_Profile) already exists.', 16, 1);
  GOTO done;
END;

IF EXISTS (SELECT * FROM msdb.dbo.sysmail_account WHERE name = @account_name )
BEGIN
 RAISERROR('The specified Database Mail account (eviCoreDBA) already exists.', 16, 1) ;
 GOTO done;
END;

-- Start a transaction before adding the account and the profile
BEGIN TRANSACTION ;

DECLARE @rv INT;

-- Add the account
EXECUTE @rv=msdb.dbo.sysmail_add_account_sp
    @account_name = @account_name,
    @email_address = @email_address,
    @display_name = @display_name,
	@replyto_address = @replyto_address,
    @mailserver_name = @SMTP_servername;

IF @rv<>0
BEGIN
    RAISERROR('Failed to create the specified Database Mail account (eviCoreDBA_Profile).', 16, 1) ;
    GOTO done;
END

-- Add the profile
EXECUTE @rv=msdb.dbo.sysmail_add_profile_sp
    @profile_name = @profile_name ;

IF @rv<>0
BEGIN
    RAISERROR('Failed to create the specified Database Mail profile (eviCoreDBA).', 16, 1);
	ROLLBACK TRANSACTION;
    GOTO done;
END;

-- Associate the account with the profile.
EXECUTE @rv=msdb.dbo.sysmail_add_profileaccount_sp
    @profile_name = @profile_name,
    @account_name = @account_name,
    @sequence_number = 1 ;

IF @rv<>0
BEGIN
    RAISERROR('Failed to associate the speficied profile with the specified account (eviCoreDBA_Profile).', 16, 1) ;
	ROLLBACK TRANSACTION;
    GOTO done;
END;

COMMIT TRANSACTION;

done:

-- 01.3 Databae Mail Post-Setup
-- Grant access to the profile to the DBMailUsers role
EXECUTE msdb.dbo.sysmail_add_principalprofile_sp
    @profile_name = 'eviCoreDBA_Profile',
    @principal_name = 'NYMINT\DBAMonitor',
    @is_default = 1 ;
--EXECUTE msdb.dbo.sysmail_add_principalprofile_sp
--    @profile_name = 'eviCoreDBA_Profile',
--    @principal_name = 'NYMINT\DBA.Group',
--    @is_default = 1 ;