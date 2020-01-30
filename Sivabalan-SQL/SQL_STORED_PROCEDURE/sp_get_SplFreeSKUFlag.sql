CREATE Procedure sp_get_SplFreeSKUFlag(@ProductCode nVarchar(30),@InvoiceDate DateTime)
As
Begin

Set dateformat dmy
SELECT @InvoiceDate=dbo.stripdatefromtime(@InvoiceDate)

Declare @FreeSKU As int

SELECT @FreeSKU = Count(IsNull(FreeSKU, 0)) FROM SpecialSKUMaster WHERE FreeSKU  = @ProductCode
and dbo.stripdatefromtime(@InvoiceDate) Between Fromdate and Todate And Active = 1

If @FreeSKU > 0
Select 1
else
Select 0


End
