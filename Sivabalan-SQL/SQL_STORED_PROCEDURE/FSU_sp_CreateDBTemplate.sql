
Create Procedure dbo.[FSU_sp_CreateDBTemplate](
	@DBTemplatePath nvarchar(500)
)
As
Declare @strSQL nvarchar(4000)
iF Exists(Select * From Sysdatabases where Name = 'Minerva') 
Begin 
	set @strSQL = 'BACKUP DATABASE Minerva TO DISK = ''' + @DBTemplatePath +'DBTEMPLATE.DMP'''
	Execute(@strSQL)
End
