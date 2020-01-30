Create procedure Sp_Get_DandDSavedBatch_New @ID int, @Product_Code nVarchar(30), @DandDDate Datetime = Null
AS
BEGIN
Set DateFormat DMY
IF @DandDDate is Null
Select @DandDDate = GetDate()

Declare @CustomerID nvarchar(30)
Declare @TaxType int

Select Top 1 @CustomerID = CustomerID From Customer Where isnull(DnDFlag,0) = 1
Select @TaxType = dbo.FN_Get_GST_CustomerLocality (@CustomerID)

Select DD.Batch_Number, Sum(IsNull(DD.TotalQuantity,0)) as TotalQuantity, Rate = DD.PTS,
Case When @TaxType = 2 Then Tax.CST_Percentage Else Tax.Percentage End Tax,
--Tax = DD.TaxSuffered,
Sum(IsNull(DD.RFAQuantity, 0)) as RFAQuantity,
Sum(IsNull(DD.TaxAmount, 0)) as TaxAmount, Sum(IsNull(DD.TotalAmount,0)) as  TotalAmount,Sum(IsNull(DD.UOMTotalQty,0)) as UOMTotalQty,
Sum(IsNull(DD.UOMRFAQty, 0)) as UOMRFAQty,Sum(IsNull(DD.UOMTaxAmount, 0)) as UOMTaxAmount,max(isnull(UOMBatchTaxAmount,0)) as UOMBatchTaxAmount,
Max(isnull(UOMBatchTotalAmount,0)) as UOMBatchTotalAmount,Max(Isnull(BP.TOQ,0)) as TOQ,
TaxID = isnull(Tax.Tax_Code,0), TaxType = @TaxType

--isnull(BP.GRNTaxID,0) as TaxID,
--TaxType = Case When isnull(BP.TaxType,0) = 5 Then isnull(BP.GSTTaxType,0) Else isnull(BP.TaxType,0) End

From DandDDetail DD
Join Batch_Products BP ON DD.Batch_Code = BP.Batch_Code
--Join Items I ON BP.Product_Code = I.Product_Code

Join (Select Top 1 Product_Code, STaxCode as Sale_Tax From ItemsSTaxMap Where Product_Code = @Product_code and dbo.Striptimefromdate(@DandDDate)
Between dbo.Striptimefromdate(SEffectiveFrom) and dbo.Striptimefromdate(isnull(SEffectiveTo,GetDate()))
) I ON BP.Product_Code = I.Product_Code

Join Tax ON I.Sale_Tax = Tax.Tax_Code
Where
DD.ID = @ID
And DD.Product_Code = @Product_Code
Group By DD.Batch_Number, DD.PTS, Case When @TaxType = 2 Then Tax.CST_Percentage Else Tax.Percentage End, isnull(Tax.Tax_Code,0)
Order BY Min(DD.Batch_Code)

END
