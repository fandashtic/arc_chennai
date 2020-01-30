CREATE Function ColumnExists(@TableName nvarchar(300),@FieldName nvarchar(300))
Returns Int
As
Begin
Declare @ColumnExists Int
Declare @Object_ID Bigint
select @Object_ID = 
case
	when OBJECTPROPERTY(object_id(N'' + @TableName + ''), N'IsUserTable') = 1 then object_id(N'' + @TableName + '')
	else null
End
If Exists(select Name from Syscolumns where id = @Object_ID and Name = @FieldName)
Begin
	set @ColumnExists = 1	
End
Else
Begin
	set @ColumnExists = 0
End
Return 	@ColumnExists 
End


