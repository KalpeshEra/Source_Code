 Declare @MaxMemory int,
         @ServerMemory int
--Change Server Memory
-- Current OS Memory in GB
Select @ServerMemory = Floor(total_physical_memory_kb / 1024 / 1024)
From sys.dm_os_sys_memory

  -- 80% of OS Memory in MB will allocate to SQL Server
Set @MaxMemory = (@ServerMemory * .8) * 1024

EXEC sys.sp_configure N'min server memory (MB)', N'2048' --Adjust min memory as per requirement
EXEC sys.sp_configure N'max server memory (MB)', @MaxMemory

RECONFIGURE

--sp_configure 'Advanced Options', 1; Reconfigure with override

