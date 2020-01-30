CREATE procedure sp_ser_batchdamageinsert (@BatchCode as int, @NewBatchCode as int = 0  OutPut) as 
Declare @BatchStr as nvarchar(4000)
Declare @ColName as nvarchar(100)
Set @BatchStr = ''
Declare BatchCol Cursor for 
Select b.Name from sysobjects a 
Inner Join syscolumns b On a.Id = b.Id Where a.Name = 'Batch_Products' Order by b.ColId
Open BatchCol 

Fetch next from BatchCol Into @ColName /*Skip BatchCode*/
Fetch next from BatchCol Into @ColName 
While @@Fetch_Status = 0 
Begin
	Set @BatchStr = @BatchStr + ',' + @ColName	
	Fetch next from BatchCol Into @ColName 
End 
Close BatchCol
Deallocate BatchCol
Set @BatchStr = Substring(@BatchStr, 2, Len(@BatchStr))
/* Select @BatchStr */
Set  @BatchStr = 'Insert into Batch_Products (' + @BatchStr  + ') 
	Select ' +  @BatchStr + ' From Batch_Products Where Batch_code = ' 
	+ Cast(@BatchCode as nvarchar(11)) 
/* Select @BatchStr */
Exec (@BatchStr) 
Set @NewBatchCode = @@Identity



