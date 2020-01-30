Create Function [dbo].[Fn_Get_SR_SKUWiseSerial](@InvoiceID int, @ItemCode nvarchar(2000))
Returns nvarchar(100)
As
Begin
	Declare @Result nvarchar(100)
	Declare @ProductCode nvarchar(15)
	Declare @RowID int

	Set @Result = ''
	Declare @tmpProdCode Table(RowID int, Product_Code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  
	IF @ItemCode='%'  
	   Insert Into @tmpProdCode Select 1, Product_Code From Items  
	Else  
	   Insert Into @tmpProdCode Select * From dbo.sp_SplitIn2Rows_WithID(@ItemCode,N',')  	
		
	Declare Cur Cursor For
	Select Distinct ID.Product_Code, T.RowID From InvoiceDetail ID Inner Join @tmpProdCode T ON ID.Product_Code = T.Product_Code 
		Where ID.InvoiceID = @InvoiceID and isnull(ID.PendingQty,0) > 0 and ID.Flagword = 0 and ID.UOMQty > 0 Order By T.RowID
	Open Cur
	Fetch Next From Cur Into @ProductCode, @RowID
    While @@Fetch_Status = 0
	Begin
		Set @Result = @Result + Cast(@RowID as nvarchar(10)) + ','		
		Fetch Next From Cur Into @ProductCode, @RowID
	End
	Close Cur
    Deallocate Cur

	IF @Result <> ''		
		Set @Result = Substring(@Result, 1, Len(@Result)-1)

	Return @Result
End 
