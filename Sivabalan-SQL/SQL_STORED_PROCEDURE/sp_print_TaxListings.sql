Create Procedure sp_print_TaxListings (@InvNo int)
As  
DECLARE @Flags int  
Declare @TotalDiscount Decimal(18,6)

Select @Flags = Flags, @TotalDiscount = IsNull(AddlDiscountValue,0)+IsNull(DiscountValue,0) From InvoiceAbstract Where InvoiceID = @InvNo  
create table #temp (TaxType Int, Product_Code varchar(15), TaxPercentage Decimal(18,6), GV Decimal(18,6), TA Decimal(18,6))  

Insert Into #temp
Select 1, Product_Code, Max(TaxCode), IsNull(Sum(Amount - (STPayable + CSTPayable)), 0),
-- IsNull(Sum(case @Flags   
-- When 1 Then   
-- SalePrice * Quantity + (SalePrice * Quantity * TaxSuffered / 100)   
-- Else   
-- (SalePrice * Quantity) - (SalePrice * Quantity * DiscountPercentage / 100) +   
-- (SalePrice * Quantity * TaxSuffered / 100) End), 0) - 
-- case @Flags
-- When 1 Then
-- 0
-- Else
-- @TotalDiscount
-- End,   
IsNull(Sum(STPayable + CSTPayable), 0)  
From InvoiceDetail  
Where InvoiceID = @InvNo  
Group By Product_code, Batch_Number, SalePrice  

Select "TaxCode" = Case IsNull(TaxPercentage, 0)
When 0 Then
Space(16-Len('No Tax'))+Cast('No Tax' as varchar(16))
Else
Space(16-Len(Cast(TaxPercentage As Varchar(16))))+Cast(TaxPercentage As Varchar(16))
End, 
"GV" = Space(16-Len(IsNull(Sum(GV), 0))) + cast(IsNull(Sum(GV), 0) as varchar(16)),  
"T.A" = Space(16-Len(IsNull(Sum(TA), 0))) + cast(IsNull(Sum(TA), 0) as varchar(16))
From #temp 
Where TaxType = 1
Group By TaxPercentage

insert into #temp  
Select 2, Product_Code, Max(TaxSuffered), Sum(SalePrice*Quantity), 0
From InvoiceDetail  
Where InvoiceID = @InvNo  
Group By Product_code, Batch_Number, SalePrice  
  
Select "TS" = Case IsNull(TaxPercentage, 0)  
When 0 then  
Space(16-Len('No Tax'))+cast('No Tax' as varchar(16)) 
Else  
Space(16-Len(Cast(TaxPercentage as Varchar(25))))+Cast(TaxPercentage as Varchar(16))  
End,   
"GVTS" = Space(16-Len(IsNull(Sum(GV), 0)))+ cast(IsNull(Sum(GV), 0)as varchar(16)),  
"TSA" = Space(16-Len(IsNull(Cast(Sum(GV * TaxPercentage / 100) As Decimal(18,6)),0))) + Cast(IsNull(Cast(Sum(GV * TaxPercentage / 100) As Decimal(18,6)),0) As Varchar(16)) 
From #temp  
Where TaxType = 2
Group By TaxPercentage
drop table #temp 

