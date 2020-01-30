CREATE Function mERP_fn_Get_CalcPurchaseCess
(@BillID nvarchar(30), @TaxCode int = 0)  
Returns Decimal(18,6)  
AS  
BEGIN  
Declare @Cess Decimal(18,6)  
IF Exists(Select * From Taxcomponents Where Tax_Code = @TaxCode)  
Select @Cess = ((Tax_Percentage) * Sum(BillDetail.Amount) / 100) / 100 From BillDetail  
INNER JOIN TaxComponents ON TaxComponents.Tax_Code = BillDetail.TaxCode Where BillID = @BillID  
And ApplicableOn = 'Price' And LST_Flag=1 And BillDetail.TaxCode = @TaxCode
Group By Tax_Percentage
Else  
Select @Cess = ((Percentage * Sum(BillDetail.Amount) / 100) * 100/101) / 100 From BillDetail
INNER JOIN Tax ON Tax.Tax_Code = BillDetail.TaxCode Where BillID = @BillID
And BillDetail.TaxCode = @TaxCode Group By Percentage

Return Isnull(@Cess,0)  
END
