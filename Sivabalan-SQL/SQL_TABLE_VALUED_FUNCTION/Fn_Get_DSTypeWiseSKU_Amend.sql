Create Function Fn_Get_DSTypeWiseSKU_Amend(@DSTypeID Int, @InvID Int = 0, @Mode Int = 0)  
Returns @SKUList Table    
(    
 Product_Code  NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,    
 ProductName  NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS    
)    
As    
Begin
	Declare @TmpSKUList Table    
	(    
	Product_Code  NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,    
	ProductName  NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS    
	)  

	Declare @DSTypeSKU Table(System_SKU Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)	
	
	Insert Into @DSTypeSKU (System_SKU )
	Select  DSSku.System_SKU From DSTypeWiseSKU DSSku
	Where DSSku.DSTypeID = @DSTypeID 
	
	Declare @BP Table(Product_Code Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
		
	Insert Into @BP(Product_Code)
	Select Product_Code From Batch_Products BP 
	where IsNull(BP.Damage, 0) = 0  And IsNull(BP.Quantity, 0) > 0   
	Group by Product_Code
	Having IsNull(Sum(BP.Quantity),0) > 0
		
	Insert Into @TmpSKUList 
	Select I.Product_Code, I.ProductName 
	From @DSTypeSKU DSSku
	Join @BP STK On DSSku.System_SKU = STK.Product_Code
	Join Items I On DSSku.System_SKU = I.Product_Code
	
	Insert Into @SKUList Select Product_Code,ProductName From @TmpSKUList  
	
	If @Mode = 2 --Invoice Amendment
	Begin
		--Select Invoice items
		Insert Into @SKUList 
		Select Distinct(ID.Product_Code), IT.ProductName 
		From InvoiceDetail ID, Items IT
		Where ID.InvoiceID = @InvID
		And ID.Product_Code = IT.Product_Code
		And ID.Product_Code Not In(Select Product_Code From @TmpSKUList)	
	End
	
	If @Mode = 1  -- Dispatch Amendment
	Begin
		--Select Dispatch items
		Insert Into @SKUList 
		Select Distinct(DD.Product_Code), IT.ProductName 
		From DispatchDetail  DD, Items IT
		Where DD.DispatchID  = @InvID
		And DD.Product_Code = IT.Product_Code
		And DD.Product_Code Not In(Select Product_Code From @TmpSKUList)		
	End
	
Return
End  
