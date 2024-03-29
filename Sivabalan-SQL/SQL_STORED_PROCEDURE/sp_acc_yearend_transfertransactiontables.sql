



CREATE Procedure sp_acc_yearend_transfertransactiontables(@SourceDatabase nvarchar(50),@DestinationDatabase nvarchar(50),@SrcTable nvarchar(50),@DesTable nvarchar(50),@Criteria nvarchar(1000),@IdentityExists Int)
As
Declare @TransactionSql as nvarchar(4000),@InsertSql nvarchar(2500),@SelectSql nvarchar(2500),@FieldName nvarchar(50)

If @IdentityExists=1
Begin	
	Set @InsertSql=N'SET IDENTITY_INSERT ' + @DestinationDatabase + N'..' + @DesTable + N' ON '  + char(13) + char(10) + N'Insert into ' + @DestinationDatabase + N'..' + @DesTable + N' ('
	Set @SelectSql=N'Select '
	Declare scanmastertable Cursor Static For
	Select Name from SysColumns Where ID=(Select ID from SysObjects where Name = @SrcTable)
	Open scanmastertable
	Fetch From scanmastertable Into @FieldName
	While @@Fetch_Status=0
	Begin
		Set @InsertSql=@InsertSql+ @FieldName + N','
		Set @SelectSql=@SelectSql+ @SourceDatabase + N'..' + @SrcTable + N'.' + @FieldName + N','
		Fetch Next From scanmastertable Into @FieldName
	End
	Close scanmastertable
	Deallocate scanmastertable
	Set @InsertSql=substring(@InsertSql,1,len(@InsertSql)-1)
	Set @SelectSql=substring(@SelectSql,1,len(@SelectSql)-1)
	Set @InsertSql=@InsertSql+ N') '
	Set @SelectSql=@SelectSql+ N' from ' + @SourceDatabase + N'..' + @SrcTable + N' Where ' + @Criteria + char(13) + char(10) + N'SET IDENTITY_INSERT ' + @DestinationDatabase + N'..' + @DesTable + N' OFF ' 
	Set @TransactionSql=@InsertSql + @SelectSql
End
Else
Begin
	Set @TransactionSql=N'Insert into ' + @DestinationDatabase + N'..' + @DesTable + N' Select * from ' + @SourceDatabase + N'..' + @SrcTable + N' where ' + @Criteria
				
End
Exec sp_ExecuteSql @TransactionSql






