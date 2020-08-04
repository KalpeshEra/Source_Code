--The default configuration settings in a new MSSQL database may not be adequate to ensure optimum performance during imports of large amounts of data.
--Better to set filegrowth to 100mb.

USE [master]
GO
ALTER DATABASE [model] MODIFY FILE ( NAME = N'modeldev', FILEGROWTH = 102400KB )
GO
