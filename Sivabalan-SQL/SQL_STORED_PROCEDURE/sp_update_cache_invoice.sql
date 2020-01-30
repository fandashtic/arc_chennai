CREATE PROCEDURE sp_update_cache_invoice (@InvoiceID int,
					  @GoodsValue Decimal(18, 6),
					  @ProductDiscount Decimal(18, 6),
					  @TaxApplicable Decimal(18, 6),
					  @TaxSuffered Decimal(18, 6),
					  @AdditionalDiscount Decimal(18, 6),
					  @AmountRecd Decimal(18,6)=NULL)
AS
--Calculating Total VatTaxAmount from InvoiceDetail table and updating in 
--InvoiceAbstract table. This updation is only for Vat Items.

Declare @CanUpdateAmountRecd integer
Declare @Paymode Integer
Declare @InvType Integer

Select @CanUpdateAmountRecd=0

--To Update AmountReceived Only For InvoiceAmendment Only and for PaymentMode other than Credit.
Select @Paymode=PaymentMode,@InvType=InvoiceType From InvoiceAbstract Where InvoiceID=@InvoiceID

Declare @DispatchID Integer
Declare @DispatchDocID Integer
Select @DispatchID=0
Select @DispatchDocID=0

--To Update the Reference of the Implicitly raised Dispatch in InvoiceAbstractTable.
Select @DispatchID=DispatchID,@DispatchDocID=Documentid From DispatchAbstract where Invoiceid=@invoiceid

If(@DispatchID<>0)
Begin
	Update InvoiceAbstract Set ReferenceNumber=@DispatchID,NewReference=dbo.getVoucherPrefix('DISPATCH') + Cast(@DispatchDocID as varchar(10)) Where InvoiceID=@InvoiceID And (IsNull(Status,0) & 1) =1
End

If ((@PayMode<>0) And (@InvType=3))
Begin
	Select @CanUpdateAmountRecd=1
End

Declare @TotalVatTaxAmount Decimal(18,6)
Set @TotalVatTaxAmount = 0
Select @TotalVatTaxAmount = IsNull(sum(CSTPayable),0) + IsNull(sum(STPayable),0) 
from InvoiceDetail Where InvoiceId=@InvoiceID and IsNull(Vat,0) = 1

--Select @TaxApplicable = isNull(Sum(TaxAmount),0) - isNull(Sum(STCredit),0) 
--from InvoiceDetail Where InvoiceId=@InvoiceID 



If(@CanUpdateAmountRecd=1)
Begin
		Update  InvoiceAbstract Set GoodsValue = @GoodsValue, AddlDiscountValue = @AdditionalDiscount,
		TotalTaxSuffered = @TaxSuffered, TotalTaxApplicable = @TaxApplicable,
		ProductDiscount = @ProductDiscount, VatTaxAmount=@TotalVatTaxAmount,
		AmountRecd=@AmountRecd
		Where	InvoiceID = @InvoiceID
End
Else
Begin
		Update  InvoiceAbstract Set GoodsValue = @GoodsValue, AddlDiscountValue = @AdditionalDiscount,
		TotalTaxSuffered = @TaxSuffered, TotalTaxApplicable = @TaxApplicable,
		ProductDiscount = @ProductDiscount, VatTaxAmount=@TotalVatTaxAmount
		Where	InvoiceID = @InvoiceID
End


/*Update DSTypeID for the salesman */
Update IA Set DSTypeID = isNull(Det.DstypeID,0)
From InvoiceAbstract IA ,DsType_Details Det
Where IA.InvoiceID = @InvoiceID
And IA.SalesmanID = Det.SalesmanID
And Det.DSTypeCtlPos = 1


