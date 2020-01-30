Create Procedure mERP_sp_Check_PendingItems
(@DocSerial Int,
@ProdCode nVarchar(255),
@BatchNumber nVarchar(255),
@PendingQty Decimal(18,6),
@TransferID Int,
@TransferSerail Int)
As
Begin
	Declare @Qty as Decimal(18,6)
--	Select @Qty = Sum(VanStatementDetail.Pending)  /  IsNull(( Select Case VanStatementDetail.UOM 
--	When Items.UOM then 1         
--	When Items.UOM1 Then Case IsNull(UOM1_Conversion, 1) When 0 then 1 Else IsNull(UOM1_Conversion, 1) End   
--	When Items.UOM2 Then Case IsNull(UOM2_Conversion, 1) When 0 Then 1 Else IsNull(UOM2_Conversion, 1) End 
--	End  From Items Where Product_Code = VanStatementDetail.Product_Code), 1)
	Select @Qty = Sum(VanStatementDetail.Pending)
	From VanStatementDetail Where DocSerial = @DocSerial and Product_Code = @ProdCode -- and isNull(Batch_Number,'') = @BatchNumber
	and VanTransferID = @TransferID and  TransferItemSerial  = @TransferSerail
	Group By Product_Code,UOM ,Batch_Number
	
	if @Qty = @PendingQty
		Select 1
	Else
		Select 0
End

