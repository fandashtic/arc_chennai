Create Procedure mERP_SP_getHOSTNAME @DBName nvarchar(150)
AS
BEGIN
Select HostName from Master.dbo.sysprocesses Where dbid = (Select dbid from Master.dbo.sysdatabases Where name = @DBName)
And Program_name <>'AccountOpeningBalance'
END
