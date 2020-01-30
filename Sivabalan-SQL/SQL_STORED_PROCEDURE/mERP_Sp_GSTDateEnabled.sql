Create Procedure mERP_Sp_GSTDateEnabled
As

Set DateFormat DMY
Declare @GSTDate Datetime
Declare @DayCloseDate Datetime
--Declare @CurrectDate Datetime
Declare @STaxCode Int
Declare @PTaxCode Int
Declare @NewSTaxCode Int
Declare @NewPTaxCode Int
Declare @Product_Code nVarChar(30)

Select @GSTDate = dbo.striptimefromdate(GSTDateEnabled) From Setup
Select @DayCloseDate = dbo.striptimefromdate(LastInventoryUpload) From Setup
--Select @CurrectDate = dbo.striptimefromdate(Getdate())

IF (Select isnull(Flag,0) From tbl_merp_ConfigAbstract Where ScreenName = 'GSTaxEnabled') = 0
Begin	
	IF Exists(Select 'x' From tbl_mERP_RecConfigAbstract Where MenuName = 'GSTaxEnabled' and Status = 3 and isnull(Flag,0) = 1)
	Begin
		--IF @CurrectDate >= @GSTDate		
		If @DayCloseDate > = dbo.striptimefromdate(DateAdd(d,-1,@GSTDate))
		Begin
			Update tbl_mERP_ConfigAbstract Set Flag = 1, ModifiedDate = GetDate()  Where ScreenName = 'GSTaxEnabled'
			Update tbl_mERP_RecConfigAbstract Set Status = 32 Where MenuName = 'GSTaxEnabled' and Status = 3
			Update tbl_merp_ConfigAbstract Set Flag = 1 Where ScreenCode = 'FreeToSaleable'
			Update tbl_merp_ConfigAbstract Set Flag = 1 Where ScreenCode = 'SaleableToFree'		

			Declare AllItem Cursor for Select Distinct Product_Code From Items 
			Open AllItem
			Fetch From AllItem Into @Product_Code
			While @@Fetch_status = 0
			Begin
				If Exists(Select 'x' From ItemsSTaxMap Where Product_Code = @Product_Code)
				Begin
					Select @STaxCode = Sale_Tax From Items Where Product_Code = @Product_Code
				
					IF Exists(Select 'x' From ItemsSTaxMap Where Product_Code = @Product_Code and dbo.Striptimefromdate(@GSTDate) 
								  Between dbo.Striptimefromdate(SEffectiveFrom) and dbo.Striptimefromdate(isnull(SEffectiveTo,GetDate()))
								 )		
					Begin
					
						Select Top 1 @NewSTaxCode = STaxCode From ItemsSTaxMap 
							Where Product_Code = @Product_Code and dbo.Striptimefromdate(@GSTDate) 
								Between dbo.Striptimefromdate(SEffectiveFrom) and dbo.Striptimefromdate(isnull(SEffectiveTo,GetDate()))

						If @STaxCode <> @NewSTaxCode
							Update Items Set Sale_Tax = @NewSTaxCode Where Product_Code = @Product_Code					
					
					End
					
				End			
				
				If Exists(Select 'x' From ItemsPTaxMap Where Product_Code = @Product_Code)
				Begin
					Select @PTaxCode = TaxSuffered From Items Where Product_Code = @Product_Code
				
					If Exists(Select 'x' From ItemsPTaxMap Where Product_Code = @Product_Code and dbo.Striptimefromdate(@GSTDate) 
								 Between dbo.Striptimefromdate(PEffectiveFrom) and dbo.Striptimefromdate(isnull(PEffectiveTo,GetDate()))
								)
					Begin
					
						Select Top 1 @NewPTaxCode = PTaxCode From ItemsPTaxMap 
							Where Product_Code = @Product_Code and dbo.Striptimefromdate(@GSTDate) 
								Between dbo.Striptimefromdate(PEffectiveFrom) and dbo.Striptimefromdate(isnull(PEffectiveTo,GetDate()))

						If @PTaxCode <> @NewPTaxCode
							Update Items Set TaxSuffered = @NewPTaxCode Where Product_Code = @Product_Code
					
					End
					
				End
				Fetch Next From AllItem Into @Product_Code
			End
			Close AllItem
			DeAllocate AllItem		
				
		End
	End
End 

