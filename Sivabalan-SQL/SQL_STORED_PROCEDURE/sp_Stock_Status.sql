Create Procedure sp_Stock_Status (@GRNID Int)
As
If exists(Select * from Batch_Products Where GRN_ID = @GRNID And
Quantity <> QuantityReceived)
Begin
	Select 0
End
Else
Begin
	Select 1
End
