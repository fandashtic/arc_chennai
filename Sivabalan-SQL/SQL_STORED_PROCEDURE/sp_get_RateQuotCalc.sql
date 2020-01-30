CREATE Procedure sp_get_RateQuotCalc(@ItemCode nvarchar(30), @InvoiceDate Datetime, @TaxType int, @RateQuote Decimal(18,6), @RegisterStatus int = 0)
As
Begin
Declare @TaxCode int
Set DateFormat DMY

Select Top 1 @TaxCode = STaxCode From ItemsSTaxMap
Where Product_Code = @ItemCode and dbo.Striptimefromdate(@InvoiceDate)
Between dbo.Striptimefromdate(SEffectiveFrom) and dbo.Striptimefromdate(isnull(SEffectiveTo,GetDate()))

IF @TaxCode > 0
Begin
Select 	"RateQuote" = (@RateQuote - isnull(dbo.Fn_Quotation_TaxCompCalc(@ItemCode,@TaxCode,@TaxType,1,@RegisterStatus),0))
/ (1 + (isnull(dbo.Fn_Quotation_TaxCompCalc(@ItemCode,@TaxCode,@TaxType,0,@RegisterStatus),0) /100))
End
Else
Select "RateQuote" = @RateQuote

End
