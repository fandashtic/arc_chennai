Create Function Fn_Get_DSTypeWiseSKU(@DSTypeID Int,@STKSKU Int = 0)  
Returns @SKUList Table    
(    
 Product_Code  NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,    
 ProductName  NVarChar(510) COLLATE SQL_Latin1_General_CP1_CI_AS    
)    
As    
Begin
	Declare @DSTypeSKU Table(System_SKU Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)	

	Insert Into @DSTypeSKU (System_SKU )
	Select  DSSku.System_SKU From DSTypeWiseSKU DSSku
	Where DSSku.DSTypeID = @DSTypeID 
	
	If @STKSKU = 1
	 Begin
		Declare @BP Table(Product_Code Nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
		
		Insert Into @BP(Product_Code)
		Select Product_Code From Batch_Products BP 
		where IsNull(BP.Damage, 0) = 0  And IsNull(BP.Quantity, 0) > 0   
		Group by Product_Code
		Having IsNull(Sum(BP.Quantity),0) > 0
		
		Insert Into @SKUList 
		Select I.Product_Code, I.ProductName 
		From @DSTypeSKU DSSku
		Join @BP STK On DSSku.System_SKU = STK.Product_Code
		Join Items I On DSSku.System_SKU = I.Product_Code
	 End
	Else
	 Begin
		Insert Into @SKUList 
		Select I.Product_Code, I.ProductName 
		From @DSTypeSKU DSSku		
		Join Items I On DSSku.System_SKU = I.Product_Code And IsNull(I.Active,0) = 1
	 End
	
Return
End  
