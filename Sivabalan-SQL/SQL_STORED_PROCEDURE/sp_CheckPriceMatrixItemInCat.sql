CREATE Procedure sp_CheckPriceMatrixItemInCat(@categoryID Int=0,@ManuFacturerID INT=0)  
As  
Begin  
	if @categoryID <> 0  
	Begin  
		if @CategoryID In (Select CategoryID From Items I,PricingAbstract P   
		Where I.Product_Code=P.ItemCode)  
			select 1  
		else  
			select 0  
	End  
	if @ManuFacturerID <> 0  
	Begin  
		if @ManuFacturerID In(Select ManufacturerID From Items I,PricingAbstract P Where   
		I.Product_Code=P.ItemCode)  
			Select 1  
		else  
			Select 0  
	End  
End  

