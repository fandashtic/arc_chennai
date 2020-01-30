Create Procedure mERPFYCP_RollBack( @szDestDBName as nvarchar(100) ) as
Declare @Sql Varchar(2000)
if isnull( db_id( @szDestDBName ), 0 ) <> 0 
Begin
	exec mERPFYCP_RDBLock @szDestDBName
	Select @Sql = 'Drop Database ' + @szDestDBName 
	Exec (@Sql)
end
