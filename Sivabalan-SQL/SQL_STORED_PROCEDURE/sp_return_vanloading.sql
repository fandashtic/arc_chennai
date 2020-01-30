
CREATE procedure sp_return_vanloading(@DocSerial int)
as
Declare @Batch_Code int
Declare @ItemCode nvarchar(15)
Declare @Pending Decimal(18,6)

Update VanStatementAbstract Set Status = Status | 192 Where DocSerial = @DocSerial
Declare ReleaseStock Cursor KeySet For
Select Product_Code, Batch_Code, Pending From VanStatementDetail
Where DocSerial = @DocSerial And Pending > 0
Open ReleaseStock
Fetch From ReleaseStock into @ItemCode, @Batch_Code, @Pending
While @@Fetch_Status = 0
Begin
	Update Batch_Products Set Quantity = Quantity + @Pending Where
	Product_Code = @ItemCode And Batch_Code = @Batch_Code	
	Fetch Next From ReleaseStock into @ItemCode, @Batch_Code, @Pending
End
Close ReleaseStock
Deallocate ReleaseStock
Update VanStatementDetail Set Pending = 0 Where DocSerial = @DocSerial And
Pending > 0

