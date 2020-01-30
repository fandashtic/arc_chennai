Create Procedure mERP_sp_get_ARUDBList(@DBName nVarChar(100),@Login nVarChar(100),@Programe nVarChar(100),@HostName nVarChar(100))
As

Select TOP 1 D.Name,P.Loginame,P.Program_Name,P.HostName 
From Master.dbo.sysprocesses P,Master.dbo.SysDatabases D 
Where P.DBID = D.DBID And D.Name Like @DBName
And P.Loginame = @Login
AND P.Program_Name = @Programe
And P.HostName = @HostName 
Order By D.Name Desc

