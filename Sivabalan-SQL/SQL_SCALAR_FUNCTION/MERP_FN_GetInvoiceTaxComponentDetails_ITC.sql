CREATE Function MERP_FN_GetInvoiceTaxComponentDetails_ITC(@InvoiceID Int)
Returns nVarchar(4000)
As
Begin
Declare @MaxCount as int
Declare @NCounter as Int
Declare @TaxInfo as nVarchar(4000)
Declare @TaxPercentage as nVarchar(100)
Declare @TaxableSales as nVarchar(100)
Declare @TaxAmount as nVarchar(100)
Declare @TaxID As Int
Declare @InvTaxTotal Decimal(18, 2)
Declare @GrandTotal Decimal(18, 2)
Declare @InvTaxAmt Decimal(18, 2)
Declare @PreTaxID Int

DECLARE @TmpTaxDetails Table([ID] Int Identity(1,1), InvoiceID Int, TaxID Int,
	[TotalTax%] Decimal(18, 3),[Tax%] Decimal(18, 3), TaxableSales Decimal(18, 2), TaxAmount Decimal(18, 2))

Insert InTo @TmpTaxDetails 
Select InvoiceID,  "TaxID" = isnull(Tax_Code,0),
    "TotalTax" = Cast(Isnull((Select Percentage from Tax Where Tax.Tax_Code=InvoiceTaxComponents.Tax_Code),0) as Decimal(18,2)),
    "TaxPercentage" = Cast(IsNull(SP_Percentage, 0) as Decimal(18,2)), 
	"TaxableSales" = Cast((100.000 * Sum(IsNull(Tax_Value, 0))) / 
	 (Case IsNull(SP_Percentage, 0) When 0 Then 1 Else IsNull(SP_Percentage, 0) End) as Decimal(18,2)),
	"TaxValue" = Cast(Sum(IsNull(Tax_Value, 0))  as Decimal(18,2))  
From InvoiceTaxComponents
where invoiceid = @InvoiceID
Group By InvoiceID, Tax_Code, SP_Percentage

Union

Select InvoiceID, TaxID, "TotalTax" = Cast(IsNull(TaxCode, 0)  as Decimal(18,2)),
"TaxPercentage" = Cast(IsNull(TaxCode, 0)  as Decimal(18,2)), 
"TaxableSales" = Cast(Sum(IsNull(Amount, 0))  as Decimal(18,2)),
"TaxValue" = Cast(Sum(IsNull(STPayable, 0) + IsNull(CSTPayable, 0))  as Decimal(18,2))
From InvoiceDetail
Where InvoiceID = @InvoiceID And IsNull(TaxCode, 0) = 0 And 
 TaxID Not In (Select Tax_Code From InvoiceTaxComponents Where 
 InvoiceID = @InvoiceID)
Group By InvoiceID, TaxID, TaxCode
Order By TaxID Asc,TotalTax Asc, TaxPercentage Desc 

Select @MaxCount = @@Identity
Set @NCounter = 1
Set @TaxInfo =   '|' + space(8) + 'Tax Details' + space(8)  + '|' +  Char(13) + Char(10)
Set @TaxInfo = @TaxInfo + '|' + 'Tax%' + Space(5 - Len('Tax%')) + '|' + 
							'Tax Sales' + Space(10 - Len('Tax Sales')) + 
						  '|' + 'Tax Amt' + Space(10 - Len('Tax Amt')) + '|' + Char(13) + Char(10)
--Set @TaxInfo = @TaxInfo + '|' + Replicate('-', 5) + '|' +  Replicate('-', 11) + '|' + +  Replicate('-', 11) + '|' +  Char(13) + Char(10)
Set @TaxInfo = @TaxInfo + '|' + Replicate('-', 27) + '|' + Char(13) + Char(10)
Set @PreTaxID = 0 
Set @InvTaxTotal = -1
Set @GrandTotal = 0


While @NCounter <= @MaxCount
Begin
	
	Select @TaxPercentage = Cast([Tax%] As nVarchar) + Space(5 - Len(Cast([Tax%] As nVarchar))), 
	@TaxableSales = Space(10 - Len(Cast(TaxableSales As nVarchar))) + Cast(TaxableSales As nVarchar), 
	@TaxAmount = Space(10 - Len(Cast(TaxAmount As nVarchar))) + Cast(TaxAmount As nVarchar), 
	@TaxID = TaxID, @InvTaxAmt = TaxAmount
	From @TmpTaxDetails 
	Where ID = @NCounter
	
	Set @TaxInfo = @TaxInfo + '|' + Cast(Cast(isnull(@TaxPercentage,0) as decimal(18,2)) as nvarchar(5)) + '|' 
							+ Cast(Cast(isnull(@TaxableSales,0) as Decimal(18,2)) as nvarchar(10)) + '|' 
							+ Cast(Cast(isnull(@TaxAmount,0) as Decimal(18,2)) as nvarchar(10))  + '|' + Char(13) + Char(10)
--	Set @TaxInfo = @TaxInfo + '|' + Replicate('-', 11) + '|' +  Replicate('-', 11) + '|' + +  Replicate('-', 11) + '|' +  Char(13) + Char(10)
	Set @GrandTotal = isnull(@GrandTotal,0) + isnull(@InvTaxAmt,0)
	Set @NCounter = @NCounter + 1
End

Set @TaxInfo = @TaxInfo + '|' + 'Total' + Space(5 - Len('Total')) + '|' + Space(10) + 
	'|' + Space(10 - Len(Cast(@GrandTotal As nVarchar))) + Cast(@GrandTotal As nVarchar)  + '|' + Char(13) + Char(10)
--Set @TaxInfo = @TaxInfo + '|' + Replicate('-', 11) + '|' +  Replicate('-', 11) + '|' + +  Replicate('-', 11) + '|' +  Char(13) + Char(10)
Set @TaxInfo = @TaxInfo + '|' + Replicate('-', 27) + '|' + Char(13) + Char(10)

Return Isnull(@TaxInfo,'Not Available') + cast(@Maxcount as nvarchar(10))

End
