  
CREATE Function Fn_Get_Items_ITC_InvAmend(@GroupID nVarchar(1000), @InvoiceID Int)
Returns @Items Table  
	(  
	Product_Code  NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,  
	ProductName  NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS  
	)  
As  
Begin  
	Declare @TempItems Table  
	(  
	Product_Code   NVarChar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,  
	ProductName  NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS  
	)  

	Declare @BP Table(Product_Code Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
	insert into @BP(Product_Code)
	Select Product_Code
	From Batch_Products BP where IsNull(BP.Damage, 0) = 0  
	And IsNull(BP.Quantity, 0) > 0   
	Group by Product_Code
	Having IsNull(Sum(BP.Quantity),0) > 0
 
    Insert Into @TempItems
    Select ITv.Product_Code,ITv.ProductName 
    From v_mERP_ItemWithCG ITv, @BP BP 
    Where ITv.Product_Code = BP.Product_Code
    And ITv.GroupID In(Select * From dbo.sp_splitIn2Rows(@GroupID,','))

	Insert Into @Items Select Product_Code,ProductName From @TempItems  

	--Select Invoice items
	Insert Into @Items 
	Select Distinct(ID.Product_Code), IT.ProductName 
	From InvoiceDetail ID, Items IT
	Where ID.InvoiceID = @InvoiceID
	And ID.Product_Code = IT.Product_Code
	And ID.Product_Code Not In(Select Product_Code From @TempItems)

	Return  
End
