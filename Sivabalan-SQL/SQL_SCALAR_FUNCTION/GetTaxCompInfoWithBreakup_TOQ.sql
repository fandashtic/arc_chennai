Create Function GetTaxCompInfoWithBreakup_TOQ (@InvNo int,@Product_Code nvarchar(255), @TaxID Int, @TaxAmount Decimal(18, 2)) 
Returns nvarchar(100) 
As 
Begin 

Declare @check int 
Select @check = InvoiceType from InvoiceAbstract where InvoiceID = @InvNo 
   
Declare @Result nvarchar(100) 
Declare @CompPercentage nvarchar(9) 
Declare @CompValue nvarchar(10) 
Declare @CompPercentage1 nvarchar(9) 
Declare @CompValue1 nvarchar(10) 
Declare @CountOfRecords Int 
Declare @TaxComboSum Decimal(18,6) 

Set @Result = ' ' 
Set @CompPercentage =' ' 
Set @CompValue=' ' 
Set @CompPercentage1 ='0.00' 
Set @CompValue1='0.00' 
Set @CountOfRecords=0 

Select @TaxComboSum = Sum(SP_Percentage) From TaxComponents 
Where Tax_Code = @TaxID And LST_Flag = 1 


Declare TaxCompData Cursor Keyset For 
Select Cast(ITC.tax_Percentage as Decimal(18,2)) SP_Per, 
 (Case @check 
  When 4 then  (0 - Cast(((@TaxAmount * ITC.SP_Percentage) / Case When @TaxComboSum = 0 Then 1 Else @TaxComboSum End) as Decimal(18,2)))
  When 5 then  (0 - Cast(((@TaxAmount * ITC.SP_Percentage) / Case When @TaxComboSum = 0 Then 1 Else @TaxComboSum End) as Decimal(18,2)))
  Else Cast(((@TaxAmount * ITC.SP_Percentage) / Case When @TaxComboSum = 0 Then 1 Else @TaxComboSum End) as Decimal(18,2)) end) TaxCompValue 
from TaxComponents ITC 
Where ITC.Tax_Code = @TaxID And ITC.LST_Flag = 1 
Group by ITC.tax_Percentage, ITC.TaxComponent_code, ITC.SP_Percentage 
Order by SP_Percentage Desc

   
Open TaxCompData 
Fetch From TaxCompData into @CompPercentage,@CompValue 

While @@Fetch_Status = 0 
Begin 

set @CountOfRecords=@CountOfRecords+1 

Set @Result = IsNull(@Result, N'') + ' ' + Space(9 -len(@CompPercentage)) + @CompPercentage + Space(10 -len(@CompValue)) + @CompValue 

Fetch Next From TaxCompData into @CompPercentage,@CompValue 
End 
   
If @CountOfRecords = 1 
Begin 
  Set @Result = IsNull(@Result, N'') + Space(6 -len(@CompPercentage1)) + @CompPercentage1 + Space(10 -len(@CompValue1)) + @CompValue1 
End 


if @CountOfRecords=0 
Begin 
  Select @CompPercentage=Cast(Max(TaxCode) as Decimal(18,2)), 
    @CompValue = Case @check When 4 Then (0 - Cast(@TaxAmount as Decimal(18,2))) 
    When 5 Then (0 - Cast(@TaxAmount as Decimal(18,2))) 
    Else Cast(@TaxAmount as Decimal(18,2)) End 
  from InvoiceDetail where InvoiceID=@InvNo and Product_Code= @Product_Code 
  Set @Result = IsNull(@Result, N'') + ' ' + Space(9 -len(@CompPercentage)) + @CompPercentage + Space(10 -len(@CompValue)) + @CompValue + Space(6 -len(@CompPercentage1)) + @CompPercentage1 + Space(10 -len(@CompValue1)) + @CompValue1 

End 

Set @Result = SubString(@Result, 3, Len(@Result) - 2) 

Close TaxCompData 

Deallocate TaxCompData 

Return @Result 

End 
