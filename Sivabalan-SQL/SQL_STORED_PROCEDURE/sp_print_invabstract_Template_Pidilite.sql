CREATE PROCEDURE [dbo].[sp_print_invabstract_Template_Pidilite](@INVNO INT)      
AS  
/*    
DECLARE @TotalTax Decimal(18,6)      
Declare @TotalQty Decimal(18,6)      
Declare @FirstSales Decimal(18, 6)      
Declare @SecondSales Decimal(18, 6)      
Declare @Savings Decimal(18,6)      
Declare @GoodsValue Decimal(18,6)      
Declare @ProductDiscountValue Decimal(18,6)      
Declare @AvgProductDiscountPercentage Decimal(18,6)      
Declare @TaxApplicable Decimal(18,6)      
Declare @TaxSuffered Decimal(18,6)      
Declare @ItemCount int      
Declare @AdjustedValue Decimal(18,6)      
Declare @SalesTaxwithcess Decimal(18, 6)    
Declare @salestaxwithoutCESS Decimal(18, 6)        
Declare @DispRef nvarchar(50)
Declare @SCRef nvarchar(50)
Declare @SCID nvarchar(50)
Declare @bRefSC Int
Declare @TotTaxableSaleVal Decimal(18, 6)
Declare @TotNonTaxableSaleVal Decimal(18, 6)
Declare @TotTaxableGV Decimal(18, 6)
Declare @TotNonTaxableGV Decimal(18, 6)
Declare @TotTaxSuffSaleVal Decimal(18, 6)
Declare @TotNonTaxSuffSaleVal Decimal(18, 6)
Declare @TotTaxSuffGV Decimal(18, 6)
Declare @TotNonTaxSuffGV Decimal(18, 6)
Declare @TotFirstSaleGV Decimal(18, 6)
Declare @TotSecondSaleGV Decimal(18, 6)
Declare @TotFirstSaleValue Decimal(18, 6)
Declare @TotSecondSaleValue Decimal(18, 6)
Declare @TotFirstSaleTaxApplicable Decimal(18, 6)
Declare @TotSecondSaleTaxApplicable Decimal(18, 6)
Declare @AddnDiscount Decimal(18, 6)
Declare @TradeDiscount Decimal(18, 6)
Declare @ChequeNo nvarchar(50)
Declare @ChequeDate Datetime
Declare @BankCode nvarchar(50)
Declare @BankName nvarchar(100)
Declare @BranchCode nvarchar(50)
Declare @BranchName nvarchar(100)
Declare @CollectionID Int
Declare @FreeQty Decimal(18,6)      


Select @AddnDiscount = AdditionalDiscount, @TradeDiscount = DiscountPercentage,
@CollectionID = Cast(PaymentDetails As Int) From InvoiceAbstract Where InvoiceID = @INVNO

Select @FreeQty = Sum(Quantity) From InvoiceDetail Where  InvoiceID = @INVNO And FlagWord = 1

select @TotalTax = SUM(ISNULL(STPayable, 0)), @TotalQty = ISNULL(SUM(Quantity), 0),      
@FirstSales = (Select IsNull(Sum(STPayable + CSTPayable), 0) From InvoiceDetail      
				Where InvoiceID = @InvNo And SaleID = 1),      
@SecondSales = (Select IsNull(Sum(STPayable + CSTPayable), 0) From InvoiceDetail      
				Where InvoiceID = @InvNo And SaleID = 2),      
@Savings = Sum(MRP * Quantity) - Sum(SalePrice * Quantity),      
@GoodsValue = SUM(Quantity * SalePrice),      
@ProductDiscountValue = Sum(DiscountValue),      
@AvgProductDiscountPercentage = Avg(DiscountPercentage),      
@TaxApplicable = Sum(IsNull(CSTPayable , 0) + IsNull(STPayable, 0)),
@TotTaxableSaleVal = Sum(Case When IsNull(CSTPayable, 0) = 0 And IsNull(STPayable, 0) = 0 Then
0
Else
Amount
End),
@TotNonTaxableSaleVal = 
Sum(Case 
When IsNull(CSTPayable, 0) = 0 And IsNull(STPayable, 0) = 0 Then
Amount
Else
0
End),
@TotTaxableGV = 
Sum(Case 
When IsNull(CSTPayable, 0) = 0 And IsNull(STPayable, 0) = 0 Then
0
Else
((Quantity * SalePrice) - DiscountValue + (Quantity * SalePrice * TaxSuffered /100))
End),
@TotNonTaxableGV = 
Sum(Case 
When IsNull(CSTPayable, 0) = 0 And IsNull(STPayable, 0) = 0 Then
((Quantity * SalePrice) - DiscountValue + (Quantity * SalePrice * TaxSuffered /100))
Else
0
End),
@TotTaxSuffSaleVal = 
Sum(Case 
When IsNull(TaxSuffered, 0) = 0 Then
0
Else
Amount
End),
@TotNonTaxSuffSaleVal = 
Sum(Case
When IsNull(TaxSuffered, 0) = 0 Then
Amount
Else
0
End),
@TotTaxSuffGV = 
Sum(Case
When IsNull(TaxSuffered, 0) = 0 Then
0
Else
((Quantity * SalePrice) - DiscountValue)
End),
@TotNonTaxSuffGV = 
Sum(Case
When IsNull(TaxSuffered, 0) = 0 Then
((Quantity * SalePrice) - DiscountValue)
Else
0
End),
@TotFirstSaleGV = 
Sum(Case SaleID
When 1 Then
((Quantity * SalePrice) - DiscountValue + (Quantity * SalePrice * TaxSuffered /100))
Else
0
End),
@TotSecondSaleGV = 
Sum(Case SaleID
When 1 Then
0
Else
((Quantity * SalePrice) - DiscountValue + (Quantity * SalePrice * TaxSuffered /100))
End),
@TotFirstSaleValue = 
Sum(Case SaleID
When 1 Then
Amount
Else
0
End),
@TotSecondSaleValue = 
Sum(Case SaleID
When 1 Then
0
Else
Amount
End),
@TotFirstSaleTaxApplicable = 
Sum(Case SaleID
When 1 Then
((IsNull(CSTPayable , 0) + IsNull(STPayable, 0)) - 
((IsNull(CSTPayable , 0) + IsNull(STPayable, 0)) * (@AddnDiscount + @TradeDiscount) / 100))
Else
0
End),
@TotSecondSaleTaxApplicable = 
Sum(Case SaleID
When 1 Then
0
Else
((IsNull(CSTPayable , 0) + IsNull(STPayable, 0)) -
((IsNull(CSTPayable , 0) + IsNull(STPayable, 0)) * (@AddnDiscount + @TradeDiscount) /100))
End)
from InvoiceDetail      
where InvoiceID = @INVNO      

create table #temp(taxsuffered Decimal(18, 6), ItemCount int)      
insert #temp      
Select (Case InvoiceAbstract.TaxOnMRP When 1 then
	IsNull(Sum(InvoiceDetail.Quantity * InvoiceDetail.MRP) * 
	dbo.fn_Get_TaxOnMRP(Max(InvoiceDetail.TaxSuffered)) / 100, 0) Else
	IsNull(Sum(InvoiceDetail.Quantity * InvoiceDetail.SalePrice) * 
	Max(InvoiceDetail.TaxSuffered) / 100, 0) End),1
From InvoiceDetail, Batch_Products,InvoiceAbstract
Where InvoiceDetail.InvoiceID = @INVNO
And InvoiceAbstract.InvoiceID=InvoiceDetail.InvoiceID And
InvoiceDetail.Batch_Code *= Batch_Products.Batch_Code      
Group By InvoiceDetail.Serial,InvoiceDetail.Product_Code, InvoiceDetail.Batch_Number,       
InvoiceDetail.SalePrice, CAST(DATEPART(mm, Batch_Products.Expiry) AS NVARCHAR) + '\'       
+ SubString(CAST(DATEPART(yy, Batch_Products.Expiry) AS NVARCHAR), 3, 2),      
InvoiceDetail.MRP, InvoiceDetail.SaleID,InvoiceAbstract.TaxOnMRP

Select @TaxSuffered = Sum(TaxSuffered),  @ItemCount = Sum(ItemCount) From #temp      
drop table #temp      
--Select @ItemCount = Count(Distinct Product_Code) From InvoiceDetail
--Where InvoiceID = @INVNO  
--Select @ItemCount = Count(*) From InvoiceDetail, Batch_Products      
--Where InvoiceID = @INVNO And      
--InvoiceDetail.Batch_Code *= Batch_Products.Batch_Code      
--Group By InvoiceDetail.Product_Code, InvoiceDetail.Batch_Number,       
--InvoiceDetail.SalePrice, CAST(DATEPART(mm, Batch_Products.Expiry) AS NVARCHAR) + '\'       
--+ SubString(CAST(DATEPART(yy, Batch_Products.Expiry) AS NVARCHAR), 3, 2),      
--InvoiceDetail.MRP, InvoiceDetail.SaleID      
      
Select @AdjustedValue = IsNull(Sum(CollectionDetail.AdjustedAmount), 0) From CollectionDetail, InvoiceAbstract      
Where CollectionID = Cast(PaymentDetails as int) And       
CollectionDetail.DocumentID <> @InvNo And      
InvoiceAbstract.InvoiceID = @InvNo      
    
Select @SalesTaxwithcess = Sum(STPayable) from InvoiceDetail Where InvoiceID = @INVNO and  Isnull(TaxCode, 0) >= 5.00     
Select @salestaxwithoutCESS = Sum(STPayable) from InvoiceDetail Where InvoiceID = @INVNO and  Isnull(TaxCode,0) < 5.00    

Select @SCID = RefNumber, @DispRef = NewRefNumber, @bRefSC = Case When (Status & 6 <> 0) Then 0 Else 1 End
From DispatchAbstract 
Where DispatchID = 
(Select case when PatIndex('%[^0-9]%', ReferenceNumber) = 0 then ReferenceNumber else null end From InvoiceAbstract Where InvoiceID = @INVNO And Status & 1 <> 0)

If @bRefSC = 1
	Select @SCRef = PODocReference From SOAbstract Where SONumber = @SCID
Else
Begin
	Select @SCRef = PODocReference From SOAbstract Where SONumber = 
	(Select case when PatIndex('%[^0-9]%', ReferenceNumber) = 0 then ReferenceNumber else null end From InvoiceAbstract Where InvoiceID = @INVNO And Status & 4 <> 0)
End

Select @ChequeNo = ChequeNumber, @ChequeDate = ChequeDate,
@BankCode = BankMaster.BankCode, @BankName = BankMaster.BankName,
@BranchCode = BranchMaster.BranchCode, @BranchName  = BranchMaster.BranchName
From Collections, BranchMaster, BankMaster 
Where DocumentID = @CollectionID And
Collections.BankCode = BankMaster.BankCode And
Collections.BranchCode = BranchMaster.BranchCode And
Collections.BankCode = BranchMaster.BankCode

SELECT "Invoice Date" = InvoiceDate, "Company Name" = Company_Name,       
"Billing Address" = InvoiceAbstract.BillingAddress, "Gross Value" = GrossValue, 
"Discount%" = DiscountPercentage, "Discount Value" = DiscountValue,     
"Net Value" = Case InvoiceAbstract.InvoiceType      
When 4 Then      
0 - NetValue      
Else      
NetValue      
End, "Shipping Address" = InvoiceAbstract.ShippingAddress,      
"Addn Discount%" = AdditionalDiscount, "Freight" = Freight,       
--"Invoice Type" = InvoiceType,       
"Invoice No" =       
CASE InvoiceType      
WHEN 1 THEN      
Inv.Prefix      
WHEN 3 THEN      
InvA.Prefix      
WHEN 4 THEN      
SR.Prefix      
WHEN 5 THEN      
SR.Prefix      
END +      
CAST(DocumentID AS NVARCHAR),      
"Serial No" = InvoiceID, "Payment Date" = PaymentDate, "CreditTerm" = CreditTerm.Description,      
"MemoLabel1" =  MemoLabel1, "MemoLabel2" = MemoLabel2,       
"MemoLabel3" = Memolabel3, "Memo1" = Memo1, "Memo2" = Memo2,       
"Memo3" = Memo3, "DLNumber20" = DLNumber, "TNGST" = TNGST, "CST" = CST,       
"DLNumber21" = DLNumber21,       
"Total Tax" = @TotalTax, "User Name" = UserName,       
"Adjustments" = dbo.GetAdjustments(cast(InvoiceAbstract.PaymentDetails as int), @INVNO),      
"Adjusted Value" = @AdjustedValue,      
"Salesman" = Salesman.Salesman_Name, "Sales Officer" = Salesman2.SalesmanName,       
"User Name" = InvoiceAbstract.UserName,       
"Total Qty" = @TotalQty,
"Total Free" = @FreeQty,
"First Sales Total" = @FirstSales, "Second Sales Total" = @SecondSales,       
"Balance" = Case InvoiceAbstract.PaymentMode      
When 0 Then      
 Case InvoiceAbstract.InvoiceType      
 When 4 Then      
 0 - ((NetValue + RoundOffAmount + AdjustmentValue) - @AdjustedValue)      
 Else      
 (NetValue + RoundOffAmount + AdjustmentValue) - @AdjustedValue      
 End      
Else      
InvoiceAbstract.Balance      
End, "Doc Ref" = InvoiceAbstract.DocReference,      
"Invoice Reference" = InvoiceAbstract.NewInvoiceReference,      
"Ref No" = InvoiceAbstract.NewReference,      
"Savings" = @Savings, "CustomerID" = InvoiceAbstract.CustomerID,      
"Goods Value" = @GoodsValue, "Product Discount Value" = @ProductDiscountValue,      
"Resale Tax" = @TaxApplicable,
"Gross Value (GoodsValue+ResaleTax+TaxSuffered)" = @GoodsValue + @TaxApplicable + @Taxsuffered,      
"Outstanding" = dbo.CustomerOutStanding(InvoiceAbstract.CustomerID),      
"OverAll Discount Value" = ((@GoodsValue - @ProductDiscountValue) * (AdditionalDiscount + DiscountPercentage) /100),      
"OverAll Discount%" = AdditionalDiscount + DiscountPercentage,      
"Item Count" = @ItemCount,      
"Invoice Type" = Case       
When (InvoiceAbstract.Status & 32) <> 0 And InvoiceAbstract.InvoiceType = 4 And (InvoiceAbstract.Status & 64) = 64 then      
'CANCELLED SALES RETURN DAMAGES'      
When (InvoiceAbstract.Status & 32) = 0 And InvoiceAbstract.InvoiceType = 4 And (InvoiceAbstract.Status & 64) = 64 then      
'CANCELLED SALES RETURN SALEABLE'      
When (InvoiceAbstract.Status & 32) <> 0 And InvoiceAbstract.InvoiceType = 4 And (InvoiceAbstract.Status & 64) = 0 then      
'SALES RETURN DAMAGES'      
When (InvoiceAbstract.Status & 32) = 0 And InvoiceAbstract.InvoiceType = 4 And (InvoiceAbstract.Status & 64) = 0 then      
'SALES RETURN SALEABLE'      
When (InvoiceAbstract.Status & 64) = 64 then      
'CANCELLED'      
When (InvoiceAbstract.Status & 128) = 128 then      
'AMENDED'      
When (InvoiceAbstract.Status & 16) = 16 then      
'INVOICE FROM VAN'      
Else      
'INVOICE'      
End, "Adjustment Value" = InvoiceAbstract.AdjustmentValue,      
"Rounded Net Value" = Case InvoiceAbstract.InvoiceType      
When 4 Then      
0 - (NetValue + RoundOffAmount)      
Else      
NetValue + RoundOffAmount      
End,      
"Average Product Discount Percentage" = @AvgProductDiscountPercentage,      
"Sales Tax" = (@TotalTax / 1.05),      
"Surcharge" = ((@TotalTax / 1.05) * 0.05),      
    
"Total Sales Tax minus CESS" = cast((Isnull(@SalesTaxwithcess,0)/1.15) + (Isnull(@SalesTaxwithoutcess,0)) as Decimal(18, 6)),    
"CESS" = cast(((Isnull(@SalesTaxwithcess,0) / 1.15) * 0.15)as Decimal(18, 6)),     
    
"Total Amount Before Tax" = Case InvoiceAbstract.InvoiceType      
When 4 Then      
0 - (NetValue - @TaxApplicable)      
Else      
NetValue - @TaxApplicable      
End,
"Rounded Off Amount Diff" = RoundOffAmount,
"Ref In Dispatch" = @DispRef,
"Ref In SC" = @SCRef,
"Total Taxable Sale Value" = @TotTaxableSaleVal,
"Total Non Taxable Sale Value" = @TotNonTaxableSaleVal,
"Total Taxable GV" = @TotTaxableGV,
"Total Non Taxable GV" = @TotNonTaxableGV,
"Total TaxSuff Sale Value" = @TotTaxSuffSaleVal,
"Total Non TaxSuff Sale Value" = @TotNonTaxSuffSaleVal,
"Total TaxSuff GV" = @TotTaxSuffGV,
"Total Non TaxSuff GV" = @TotNonTaxSuffGV,
"Total First Sale GV" = @TotFirstSaleGV,
"Total Second Sale GV" = @TotSecondSaleGV,
"Total First Sale Value" = @TotFirstSaleValue,
"Total Second Sale Value" = @TotSecondSaleValue,
"Total First Sale Tax Applicable" = @TotFirstSaleTaxApplicable,
"Total Second Sale Tax Applicable" = @TotSecondSaleTaxApplicable,
"Creation Date" = InvoiceAbstract.CreationTime,
"Payment Mode" = Case PaymentMode
When 0 Then 'Credit'
When 1 Then 'Cash'
When 2 Then 'Cheque'
When 3 Then 'DD' End,
"Cheque/DD Number" = @ChequeNo,
"Cheque/DD Date" = @ChequeDate,
"Bank Code" = @BankCode,
"Bank Name" = @BankName,
"Branch Code" = @BranchCode,
"Branch Name" = @BranchName,
"Amount Received" = AmountRecd,
"Addl Discount Value" = AddlDiscountValue,
"Beat Name" = Beat.Description,
"Total Weight" = (
		select sum(quantity*conversionfactor)
		from invoicedetail idt , invoiceabstract ia, items
		where idt.invoiceid = ia.invoiceid and ia.invoiceid = @INVNO
		and idt.product_code = items.product_code 
				),
"Total Tax Suffered" = IsNull(@Taxsuffered,0)
FROM InvoiceAbstract, Customer, VoucherPrefix Inv, VoucherPrefix InvA, Salesman2, Salesman, Beat,     
VoucherPrefix SR, CreditTerm      
WHERE InvoiceID = @INVNO       
AND InvoiceAbstract.CustomerID = Customer.CustomerID      
And InvoiceAbstract.BeatID *= Beat.BeatID 
AND SR.TranID = 'SALES RETURN'      
AND InvA.TranID = 'INVOICE AMENDMENT'      
AND Inv.TranID = 'INVOICE'      
AND InvoiceAbstract.CreditTerm *= CreditTerm.CreditID       
AND InvoiceAbstract.SalesmanID *= Salesman.SalesmanID      
AND InvoiceAbstract.Salesman2 *= Salesman2.SalesmanID 

*/

