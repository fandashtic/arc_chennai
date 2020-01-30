Create Procedure mERP_sp_Get_QPSPendingQty(@SchemeID Int,@PayoutID Int,@SlabID Int,@CustID nVarchar(50),@ProdCode nVarchar(255))
As
Begin
	Select isNull(Pending,0) From SchemeCustomerItems 
	Where CustomerID = @CustID And 
	SchemeID = @SchemeID And
	SlabID = @SlabID And
	PayoutID =  @PayoutID And
	Product_Code = @ProdCode
End
