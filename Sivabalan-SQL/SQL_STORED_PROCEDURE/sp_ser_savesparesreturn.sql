CREATE procedure sp_ser_savesparesreturn(@nJobCardID as int, @IssueID int, @IssuedDate datetime, 
@Product_Code as nvarchar(15), @Product_Specification1 as nvarchar(50), 
@SerialNo as int, @SpareCode as nvarchar(15), @Batch_Code as int, @UOMCode as int, 
@UOMQty as decimal(18,6), @ReturnQty as decimal(18,6), 
@FreeRow as int, @UserName as nvarchar(50), @Saleable int, @BackDated int = 0, @TranID int = 0)
as

Declare @SalePrice  decimal (18,6)
Declare @BalanceQty as decimal(18,6)
Declare @RetVal as int 
Declare @NewBatchCode as int 
Declare @ReferenceID as int 
/*@Salable = 1 for saleable else 2 for damage return*/

Set @RetVal = 0
Select @BalanceQty = (IssuedQty - (ReturnedQty + @ReturnQty)),
	@ReferenceID = ReferenceID from IssueDetail
Where SerialNo = @SerialNo
If (@BalanceQty < 0) begin goto ReturnValue end 

/*Updating Issuedetail*/
Update IssueDetail Set ReturnedQty = IsNull(ReturnedQty,0) + @ReturnQty 
where SerialNo = @SerialNo
Set @RETVAL = @@ROWCOUNT

/* Reversing JobCardSpares */
if @Saleable = 2
begin
	Update J Set J.PendingQty = IsNUll(J.PendingQty,0) + @UOMQty, J.SpareStatus = 0 
	from JobCardSpares J 
	Where J.SerialNo = @ReferenceID 
	Set @RETVAL = @@ROWCOUNT
end

	/*(Select Top 1 JC.SerialNo from JobCardSpares JC 
	Where 
	JC.Product_Code = @Product_Code and JC.SpareCode = @SpareCode and 
	JC.Product_Specification1 = @Product_Specification1 and JC.JobcardID = @nJobCardID and
	JC.UOM = @UOMCode and JC.SpareStatus <> 3  
	Order by JC.SpareStatus) */
If (@Saleable = 1 and @Batch_Code > 0)
begin
	Update Batch_Products 
	Set Batch_Products.Quantity = Batch_Products.Quantity + @ReturnQty,  
	@SalePrice = SalePrice 
	From Batch_Products Where Batch_Products.Batch_Code  = @Batch_Code
	Set @RETVAL = @@ROWCOUNT
end
else if (@Saleable = 2 and @Batch_Code > 0)
begin
	/* Procedure */ 
	Exec sp_ser_batchdamageinsert  @Batch_Code, @NewBatchCode OUTPUT
	If IsNull(@NewBatchCode,0) <> 0  
	Begin 
		Update Batch_products 
		Set Damage = 2, DamagesReason = 1, UOMQty = @UOMQty, CreationDate = getdate(), 
		Quantity = @ReturnQty Where Batch_Code = @NewBatchCode
		
		Set @Batch_Code = @NewBatchCode
		Set @RETVAL = @Batch_Code	
	end 
	Else Begin Set @RETVAL = 0 Goto ReturnValue end	
end 

If (IsNull(@TranID,0) = 0) 
begin 
	begin tran 
	Update DocumentNumbers Set @TranID = DocumentID , DocumentID = DocumentID + 1 
	Where DocType = 104
	commit tran
end 
/* Insert into ReturnInfo and Reversing Batch Product*/
Insert into SparesReturnInfo (SerialNo, UOM, UOMQty, Qty, UserName, Batch_Code, ReturnType, TransactionID) 
Values (@SerialNo, @UOMCode, @UOMQty, @ReturnQty, @UserName, @Batch_code, @Saleable, @TranID) 

/* Back dated transaction */
If (@BackDated = 1 and @Batch_Code > 0)
Begin	
	if @saleable = 1 set @Saleable = 0 
	else if @saleable = 2 set @saleable = 1 
	
	exec sp_ser_update_opening_stock 
	@SpareCode, @IssuedDate, @ReturnQty, @FreeRow, @SalePrice, @Saleable
End

ReturnValue:
select @RETVAL, @TranID
/* 
10.05.05 -- TransactionID  stored to identify return transaction --used in FA
@Batch_Code > 0 for Items with Track inventory true, 
for other items, batch_product table has no effect 
JobCardSpares pending quantity is stored as UOM quantity (28.03.05)
*/

