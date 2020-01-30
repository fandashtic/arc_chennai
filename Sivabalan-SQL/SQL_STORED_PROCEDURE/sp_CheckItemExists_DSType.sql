Create Procedure sp_CheckItemExists_DSType(@DSTypeID Int, @ItemCode nvarchar(15), @InvID Int = 0, @Mode Int =0 )
As
		Declare @DSTypeExists int
		Set @DSTypeExists = 0
		
		Select @DSTypeExists = count(Product_Code) From dbo.Fn_Get_DSTypeWiseSKU(@DSTypeID,0) Where Product_Code = @ItemCode		
		
		Set @DSTypeExists = IsNull(@DSTypeExists,0)		
		
		If @Mode = 3 -- Van Invoice @InvID EQUVALENT TO VANID
		 Begin
			Declare @VanExists int
			Set @VanExists = 0
			If @InvID > 0
				Select @VanExists = Count(Product_Code) from VanstatementDetail where Product_Code = @ItemCode and Docserial = @InvID
			
			Set @VanExists = IsNull(@VanExists,0)
			
			If @InvID > 0 And @VanExists > 0 And @DSTypeExists > 0 
				Select 1
			Else
				Select 0					
		 
			Goto ExitProc
		 
		 End		 
		Else If @Mode = 2 --Invoice amendment
		 Begin			
			Select @DSTypeExists = count(Product_Code) From dbo.Fn_Get_DSTypeWiseSKU_Amend(@DSTypeID,@InvID,2) Where Product_Code = @ItemCode	
			Set @DSTypeExists = IsNull(@DSTypeExists,0)
			If @DSTypeExists > 0 
				Select 1
			Else
				Select 0	
			
			Goto ExitProc					
			
		 End
		Else
		 Begin
			--Select Count(Product_Code) From dbo.Fn_Get_DSTypeWiseSKU(@DSTypeID,0) Where Product_Code = @ItemCode
			If @DSTypeExists > 0 
				Select 1
			Else
				Select 0							
		 End			
			
ExitProc:
