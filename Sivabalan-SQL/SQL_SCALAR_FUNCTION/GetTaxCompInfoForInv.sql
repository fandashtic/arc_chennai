Create Function GetTaxCompInfoForInv (@InvNo Int, @ComType Int, @BrkType Int)        
Returns Decimal(18, 2)        
As        
Begin  

Declare @check int
Select @check = InvoiceType from InvoiceAbstract where InvoiceID = @InvNo

Declare @Result nvarchar(100)  
Declare @CompPercentage Decimal(18, 2)  
Declare @CompValue Decimal(18, 2)
Declare @TaxTot Decimal(18, 2)
Declare @TaxCom Decimal(18, 2)
Declare @ProductCode nVarchar(256)
Declare @ExistProductCode nVarchar(256)
Declare @CompPercentage1 nvarchar(6)  
Declare @CompValue1 nvarchar(10)
Declare @CountOfRecords Int

Set @ExistProductCode = ''
Set @Result = ' '
Set @CompPercentage = 0.00
Set @CompValue = 0.00
Set @CountOfRecords = 0
Set @TaxTot = 0.00
Set @TaxCom = 0.00

If @BrkType = 1
Begin
	Declare TaxCompData Cursor Keyset For  
      
	Select "SP_Per" = SP_Per, "TaxCompValue" = Sum(TaxCompValue), "ProductCode" = ProductCode From (
	Select Cast(ITC.SP_Percentage as Decimal(18,2)) SP_Per,

	IsNull((Case @check 
		When 4 then  (0 - Cast(((ID.STPayable * ITC.SP_Percentage) / 	Case When (Select Sum(tc.SP_Percentage) From TaxComponents  tc
			Where tc.Tax_Code = ITC.Tax_Code And LST_Flag = 1) = 0 Then 1 Else (Select Sum(tc.SP_Percentage) From TaxComponents  tc
			Where tc.Tax_Code = ITC.Tax_Code And LST_Flag = 1) End ) as Decimal(18,2)))

		When 5 then  (0 - Cast(((ID.STPayable * ITC.SP_Percentage) / 	Case When (Select Sum(tc.SP_Percentage) From TaxComponents  tc
			Where tc.Tax_Code = ITC.Tax_Code And LST_Flag = 1) = 0 Then 1 Else (Select Sum(tc.SP_Percentage) From TaxComponents  tc
			Where tc.Tax_Code = ITC.Tax_Code And LST_Flag = 1) End) as Decimal(18,2)))
		Else
		Cast(((ID.STPayable * ITC.SP_Percentage) / 	Case When (Select Sum(tc.SP_Percentage) From TaxComponents  tc
			Where tc.Tax_Code = ITC.Tax_Code And LST_Flag = 1) = 0 Then 1 Else (Select Sum(tc.SP_Percentage) From TaxComponents  tc
			Where tc.Tax_Code = ITC.Tax_Code And LST_Flag = 1) End) as Decimal(18,2)) end), 0) TaxCompValue,

		ID.Product_Code ProductCode
	from TaxComponents ITC,InvoiceDetail ID
	Where	ITC.Tax_Code = ID.TaxID 
	And ID.InvoiceID=@InvNo 
	And ID.Saleprice >=0 
	And ITC.LST_Flag = 1) Als
	Group by SP_Per, ProductCode
	Order by ProductCode, SP_Per Desc
	  
	Open TaxCompData        
	Fetch From TaxCompData into @CompPercentage,@CompValue, @ProductCode

	While @@Fetch_Status = 0        
	Begin        


	If @ExistProductCode = @ProductCode
	Begin
		Set @CountOfRecords = 2
	End
	Else
	Begin
		Set @CountOfRecords = 1
	End

	If @CountOfRecords = 1
	Begin
		Set @TaxTot = @TaxTot + @CompValue
	End
	Else If @CountOfRecords = 2
	Begin
		Set @TaxCom = @TaxCom + @CompValue 
		Set @CountOfRecords = 0
	End

	Set @ExistProductCode = @ProductCode

	Fetch Next From TaxCompData into @CompPercentage,@CompValue, @ProductCode
	End        
	  
	Close TaxCompData       

	Deallocate TaxCompData        

	Set @CompValue = 0

	Select @CompValue = Sum(Case @check When 4 Then (0 - IsNull(StPayable, 0))
									 When 5 Then (0 - IsNull(StPayable, 0)) 
									 Else IsNull(StPayable, 0) End)
	from InvoiceDetail where InvoiceID = @InvNo And 
	TaxID Not In (Select Tax_Code From TaxComponents TC, InvoiceDetail IDS 
					Where TC.Tax_Code = IDS.TaxID And TC.LST_Flag = 1 And IDS.InvoiceID = @InvNo)

	Set @TaxTot = @TaxTot + IsNull(@CompValue, 0)
End
Else
Begin
	Select @CompValue = Sum(Case @check When 4 Then (0 - IsNull(StPayable, 0))
									 When 5 Then (0 - IsNull(StPayable, 0)) 
									 Else IsNull(StPayable, 0) End)
	from InvoiceDetail where InvoiceID = @InvNo 

	Set @TaxTot = @TaxTot + IsNull(@CompValue, 0)
End

If @ComType = 1
	Set @Result = @TaxTot
Else
	Set @Result = @TaxCom


Return @Result        

End
