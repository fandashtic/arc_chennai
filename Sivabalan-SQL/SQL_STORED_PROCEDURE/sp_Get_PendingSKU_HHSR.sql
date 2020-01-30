Create PROCEDURE sp_Get_PendingSKU_HHSR(@ReturnNo nvarchar(100), @ReturnType int, @ItemCode nvarchar(255) = N'')
AS

	Declare @UOMID int

	Create Table #tmpProd(RowID int, Product_Code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  
	IF @ItemCode='%'  
	   Insert Into #tmpProd Select 1, Product_Code From Items  
	Else  
	   Insert Into #tmpProd Select * From dbo.sp_SplitIn2Rows_WithID(@ItemCode,N',')  

	Select @UOMID = UOM From UOM Where Description = 'PAC'

	Select Items.Product_Code, Sum(isnull(PendingQty,0)) PendingQty, @UOMID as UOMID
	From Stock_Return SR Inner Join Items ON SR.Product_Code = Items.Product_Code
	Where ReturnNumber = @ReturnNo and isnull(PendingQty,0) > 0 and Processed = 3 and SR.ReturnType = @ReturnType
		and Items.Product_Code in(Select Product_Code From #tmpProd)
	Group By Items.Product_Code

