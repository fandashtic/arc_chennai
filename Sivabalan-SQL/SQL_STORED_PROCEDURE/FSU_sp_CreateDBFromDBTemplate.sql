
Create Procedure dbo.[FSU_sp_CreateDBFromDBTemplate](
	@DBname nvarchar(50),
	@DBTemplatePath nvarchar(500)
)	
As
Declare @strSQL nvarchar(4000)
iF Exists(Select * From Sysdatabases where Name = @DBname) 
Begin 
	set @strSQL	= 'DROP DATABASE '+ @DBname 
	Execute(@strSQL)
End
set @strSQL = 'RESTORE DATABASE '+ @DBname + ' FROM DISK ='''+ @DBTemplatePath + 'DBTEMPLATE.DMP'' With Move ''Minerva_Dat'' TO ''' + @DBTemplatePath + @DBname +'.mdf '', Move ''Minerva_Log'' TO  '''+  @DBTemplatePath +  @DBname + '.ldf'''
Execute(@strSQL)
