Create Procedure SP_Precheck_FSU
AS
BEGIN
	update Setup set FSUinstallFlag=1
	Select distinct isnull(HostName,'') from Master.dbo.sysprocesses 
	Where dbid in (Select dbid from Master.dbo.sysdatabases Where name like 'Minerva_%')
	And isnull(HostName,'') <> host_name()
END
