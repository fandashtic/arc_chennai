CREATE Procedure sp_Print_SOTaxList (@SONo Int)
As
Create Table #temp (Product_Code nvarchar(15), TaxSuffered Decimal(18,6), GV Decimal(18,6))
Select Case (IsNull(SaleTax, 0) + IsNull(TaxCode2, 0))
When 0 Then
'No Tax'
Else
Cast((IsNull(SaleTax, 0) + IsNull(TaxCode2, 0)) As nvarchar)
End,
"GV" = Sum((SalePrice * Quantity) - 
(SalePrice * Quantity * Discount / 100)
+ (SalePrice * Quantity * TaxSuffered / 100)),
"TA" = Sum(((SalePrice * Quantity) + (SalePrice * Quantity * TaxSuffered / 100)) 
* (IsNull(SaleTax, 0) + IsNull(TaxCode2, 0)) / 100)
From SODetail
Where SONumber = @SONo
Group By SaleTax, TaxCode2

Insert Into #temp
Select Product_Code, Max(TaxSuffered), Sum(SalePrice * Quantity)
From SODetail
Where SONumber = @SONo
Group By Product_Code, Batch_Number, SalePrice

Select "TS" = Case IsNull(TaxSuffered, 0)
When 0 Then
'No Tax'
Else
Cast(TaxSuffered As nvarchar)
End,
"GVTS" = IsNull(Sum(GV), 0),
"TSA" = IsNull(Cast(Sum(GV * TaxSuffered / 100) As Decimal(18,6)), 0)
From #temp
Group By TaxSuffered
Drop Table #temp
