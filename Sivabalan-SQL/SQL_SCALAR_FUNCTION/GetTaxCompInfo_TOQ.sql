Create  Function GetTaxCompInfo_TOQ (@InvNo int,@Product_Code nvarchar(255) , @TaxID Int, @TaxAmount Decimal(18, 2))        
Returns nvarchar(100)        
As        
Begin  

Declare @check int
Select @check = InvoiceType from InvoiceAbstract where InvoiceID = @InvNo
  
Declare @Result nvarchar(100)  
Declare @CompPercentage nvarchar(10)  
Declare @CompValue nvarchar(10)
Declare @CompPercentage1 nvarchar(10)  
Declare @CompValue1 nvarchar(10)
Declare @CountOfRecords Int

Set @Result = ' '
Set @CompPercentage =' '
Set @CompValue=' '
Set @CompPercentage1 ='0.00'
Set @CompValue1='0.00'
Set @CountOfRecords=0

--Declare TaxCompData Cursor Keyset For        
--Select Cast(ITC.tax_Percentage as Decimal(18,3)) SP_Per,
--
-- (Case @check 
--	When 4 then  (0 - Cast(Max(ITC.Tax_Value) as Decimal(18,2)))
--	When 5 then  (0 - Cast(Max(ITC.Tax_Value) as Decimal(18,2)))
--	Else
--	Cast(Max(ITC.Tax_Value) as Decimal(18,2)) end) TaxCompValue
--from InvoiceTaxComponents ITC,InvoiceDetail ID
--Where	ITC.InvoiceID=ID.InvoiceID 
--and		ITC.Product_Code=ID.Product_Code 
--and		ITC.InvoiceID=@InvNo 
--and		ITC.Product_Code= @Product_Code
--and ID.Saleprice >0 and ID.Flagword = 0
--Group by ITC.tax_Percentage,ID.SalePrice,ITC.Tax_component_code
--Order by SP_Per Desc
--  
--Open TaxCompData        
--Fetch From TaxCompData into @CompPercentage,@CompValue
--
--While @@Fetch_Status = 0        
--Begin        
--
--set @CountOfRecords=@CountOfRecords+1
--
--Set @Result =  IsNull(@Result, N'') + ' ' +  Space(6 -len(@CompPercentage)) + @CompPercentage +  Space(10 -len(@CompValue)) + @CompValue 
--
--Fetch Next From TaxCompData into @CompPercentage,@CompValue
--End        
  

if @CountOfRecords=0
Begin
	Select @CompPercentage=Cast(Max(TaxCode) as Decimal(18,3)),
		@CompValue = Case @check When 4 Then (0 - Cast(@TaxAmount as Decimal(18,2)))
								 When 5 Then (0 - Cast(@TaxAmount as Decimal(18,2))) 
								 Else Cast(@TaxAmount as Decimal(18,2)) End
	from InvoiceDetail where InvoiceID=@InvNo and Product_Code= @Product_Code
	if substring(cast((cast(@CompPercentage as decimal(18,3)) - cast(cast(@CompPercentage as decimal(18,3))  as int)) as varchar),5,1) = '0'
		set @CompPercentage = substring (@CompPercentage,1,len(@CompPercentage) - 1)
	Set @Result =  IsNull(@Result, N'') + ' ' +  Space(10 -len(@CompPercentage)) + @CompPercentage +  Space(10 -len(@CompValue)) + @CompValue  --+  Space(7 -len(@CompPercentage1)) + @CompPercentage1 +  Space(8 -len(@CompValue1)) + @CompValue1

End  

Set @Result = SubString(@Result, 3, Len(@Result) - 2)  

--Close TaxCompData       
--
--Deallocate TaxCompData        

Return @Result        

End
