CREATE procedure [dbo].[sp_print_RetInvAbstract](@INVNO INT)              
AS              
DECLARE @TotalTax Decimal(18,6)              
DECLARE @TotalQty Decimal(18,6)              
DECLARE @Savings Decimal(18,6)              
DECLARE @TotalSavings Decimal(18,6)              
Declare @GoodsValue Decimal(18,6)              
Declare @ProductDiscountValue Decimal(18,6)              
Declare @AvgProductDiscountPercentage Decimal(18,6)              
Declare @TaxApplicable Decimal(18,6)              
Declare @TaxSuffered Decimal(18,6)              
Declare @ItemCount int              
Declare @SalesTaxwithcess Decimal(18, 6)                  
Declare @salestaxwithoutCESS Decimal(18, 6)                  
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
Declare @TradeDiscount Decimal(18, 6)              
              
Select @TradeDiscount = DiscountPercentage              
From InvoiceAbstract Where InvoiceID = @INVNO              
              
SELECT @TotalTax = sum(ISNULL(STPayable, 0)), @TotalQty = ISNULL(SUM(Quantity), 0),              
@Savings = Sum(Case When ItemCategories.Price_Option = 1 Then
(InvoiceDetail.MRP * Quantity) - (SalePrice * Quantity)              
When ItemCategories.Price_Option = 0 Then
(Items.MRP * InvoiceDetail.Quantity) - (SalePrice * InvoiceDetail.Quantity)              
End),
@TotalSavings = Sum(Case When ItemCategories.Price_Option = 1 Then
(InvoiceDetail.MRP * Quantity) - ((SalePrice * Quantity) - ((SalePrice * Quantity) * (InvoiceDetail.DiscountPercentage / 100)))              
When ItemCategories.Price_Option = 0 Then
(Items.MRP * InvoiceDetail.Quantity) - (SalePrice * InvoiceDetail.Quantity) - ((SalePrice * Quantity) * (InvoiceDetail.DiscountPercentage / 100))                           
End),
@GoodsValue = SUM(Quantity * SalePrice),              
@ProductDiscountValue = Sum(InvoiceDetail.DiscountValue),              
@AvgProductDiscountPercentage = Avg(InvoiceDetail.DiscountPercentage),              
@TaxApplicable = Sum(IsNull(CSTPayable , 0) + IsNull(STPayable, 0)),              
@TotTaxableSaleVal =               
Sum(Case               
When IsNull(CSTPayable, 0) = 0 And IsNull(STPayable, 0) = 0 Then              
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
case TaxOnMRP 
when 1 then
	((Quantity * SalePrice) - InvoiceDetail.DiscountValue + (Quantity * InvoiceDetail.MRP * dbo.fn_Get_TaxOnMRP(invoicedetail.TaxSuffered) /100))
else
	((Quantity * SalePrice) - InvoiceDetail.DiscountValue + (Quantity * SalePrice * invoicedetail.TaxSuffered /100))
end
End),              
@TotNonTaxableGV =               
Sum(Case               
When IsNull(CSTPayable, 0) = 0 And IsNull(STPayable, 0) = 0 Then              
case TaxOnMRP
when 1 then 
	((Quantity * SalePrice) - InvoiceDetail.DiscountValue + (Quantity * InvoiceDetail.MRP * dbo.fn_Get_TaxOnMRP(invoicedetail.TaxSuffered) /100))
else
	((Quantity * SalePrice) - InvoiceDetail.DiscountValue + (Quantity * SalePrice * invoicedetail.TaxSuffered /100))
end
Else              
0              
End),              
@TotTaxSuffSaleVal =               
Sum(Case               
When IsNull(invoicedetail.TaxSuffered, 0) = 0 Then              
0              
Else              
Amount              
End),              
@TotNonTaxSuffSaleVal =               
Sum(Case              
When IsNull(invoicedetail.TaxSuffered, 0) = 0 Then              
Amount              
Else              
0              
End),              
@TotTaxSuffGV =               
Sum(Case              
When IsNull(invoicedetail.TaxSuffered, 0) = 0 Then              
0              
Else              
((Quantity * SalePrice) - InvoiceDetail.DiscountValue)              
End),              
@TotNonTaxSuffGV =               
Sum(Case              
When IsNull(invoicedetail.TaxSuffered, 0) = 0 Then              
((Quantity * SalePrice) - InvoiceDetail.DiscountValue)              
Else              
0              
End),              
@TotFirstSaleGV =               
Sum(Case InvoiceDetail.SaleID  
When 1 Then              
case TaxOnMRP 
when 1 then
	((Quantity * SalePrice) - InvoiceDetail.DiscountValue + (Quantity * InvoiceDetail.MRP * dbo.fn_get_TaxOnMRP(invoicedetail.TaxSuffered) /100))
else
	((Quantity * SalePrice) - InvoiceDetail.DiscountValue + (Quantity * SalePrice * invoicedetail.TaxSuffered /100))
end
Else              
0              
End),              
@TotSecondSaleGV =           
Sum(Case InvoiceDetail.SaleID              
When 1 Then              
0              
Else           
case TaxOnMRP 
when 1 then    
	((Quantity * SalePrice) - InvoiceDetail.DiscountValue + (Quantity * InvoiceDetail.MRP * dbo.fn_get_TaxOnMRP(invoicedetail.TaxSuffered) /100))
else
	((Quantity * SalePrice) - InvoiceDetail.DiscountValue + (Quantity * SalePrice * invoicedetail.TaxSuffered /100))
end
End),              
@TotFirstSaleValue =               
Sum(Case InvoiceDetail.SaleID              
When 1 Then              
Amount              
Else              
0              
End),              
@TotSecondSaleValue =               
Sum(Case InvoiceDetail.SaleID              
When 1 Then       
0              
Else              
Amount              
End),              
@TotFirstSaleTaxApplicable =               
Sum(Case InvoiceDetail.SaleID              
When 1 Then              
((IsNull(CSTPayable , 0) + IsNull(STPayable, 0)) -               
((IsNull(CSTPayable , 0) + IsNull(STPayable, 0)) * @TradeDiscount / 100))              
Else              
0              
End),              
@TotSecondSaleTaxApplicable =               
Sum(Case InvoiceDetail.SaleID              
When 1 Then              
0              
Else              
((IsNull(CSTPayable , 0) + IsNull(STPayable, 0)) -               
((IsNull(CSTPayable , 0) + IsNull(STPayable, 0)) * @TradeDiscount / 100))              
End)              
FROM InvoiceAbstract, InvoiceDetail , Items, ItemCategories              
WHERE InvoiceAbstract.InvoiceID = @INVNO and
InvoiceDetail.InvoiceID = @INVNO and
Items.CategoryID = ItemCategories.CategoryID and
Items.Product_Code = InvoiceDetail.Product_Code

              
create table #temp(taxsuffered Decimal(18, 6), ItemCount int)              
insert #temp              
Select IsNull(Sum(InvoiceDetail.Quantity * InvoiceDetail.SalePrice) * Max(InvoiceDetail.TaxSuffered) / 100, 0),              
Count(*)              
From InvoiceDetail, Batch_Products              
Where InvoiceID = @INVNO And              
InvoiceDetail.Batch_Code *= Batch_Products.Batch_Code              
Group By InvoiceDetail.Product_Code, InvoiceDetail.Batch_Number,               
InvoiceDetail.SalePrice, Batch_Products.Expiry, InvoiceDetail.TaxSuffered  
     
Select @TaxSuffered = Sum(TaxSuffered), @ItemCount = Sum(ItemCount) From #temp              
drop table #temp              
Select @ItemCount = Count(Distinct Product_Code) From InvoiceDetail Where InvoiceID = @INVNO                  
Select @SalesTaxwithcess = Sum(STPayable) from InvoiceDetail Where InvoiceID = @INVNO and  Isnull(TaxCode, 0) >= 5.00                   
Select @salestaxwithoutCESS = Sum(STPayable) from InvoiceDetail Where InvoiceID = @INVNO and  Isnull(TaxCode,0) < 5.00                  
              
SELECT "Invoice Date" = InvoiceDate, "Customer" = Company_Name,               
"Billing Address" = InvoiceAbstract.BillingAddress,               
"Gross Value" = GrossValue, "Discount%" = DiscountPercentage,               
"Discount Value" = DiscountValue,               
"Net Value" = NetValue, Customer.BillingAddress,               
"Invoice No" = Inv.Prefix + CAST(DocumentID AS nvarchar),               
"Total Tax" = @TotalTax, UserName, "Total Qty" = @TotalQty,               
"Referred_By" = Doctor.Name, 
"Amount Received" = (Select Sum(IsNull(AmountReceived,0)) From RetailPaymentDetails Where RetailInvoiceID = @INVNO),                                 
"Balance" = IsNull(dbo.fn_RetailPaymentDetail(@INVNO,3),0),              
"Total Service Charge" =  dbo.fn_RetailPaymentDetail(@INVNO,4), 
"Net value with service charge" = cast(dbo.fn_RetailPaymentDetail(@INVNO,4) as Decimal(18,6)) + invoiceabstract.netvalue + IsNull(RoundOffAmount, 0) ,
"Total Savings" = @Savings,              
"Total Savings - Incl Discount" = @TotalSavings,               
"Goods Value" = @GoodsValue, "Product Discount Value" = @ProductDiscountValue,              
"Resale Tax" = @TaxApplicable,               
"Gross Value (GoodsValue+ResaleTax+TaxSuffered)" = @GoodsValue + @TaxApplicable + @Taxsuffered,              
"OverAll Discount Value" = ((@GoodsValue - isnull(@ProductDiscountValue,0)) * (isnull(AdditionalDiscount,0) + isnull(DiscountPercentage,0)) /100),              
"OverAll Discount%" = isnull(AdditionalDiscount,0) + isnull(DiscountPercentage,0),              
"Item Count" = @ItemCount,              
"Contact Person" = IsNull(Customer.ContactPerson, N''),              
"Telephone" = IsNull(Customer.Phone, N''),              
"Payment Details" = Replace(Replace(dbo.fn_RetailPaymentDetail(@INVNO,1), N';', CHAR(13) + CHAR(10)), N':', CHAR(9)),              
"Memo" = InvoiceAbstract.ShippingAddress,              
"Total Tax Suffered" = IsNull(@TaxSuffered, 0),              
"SalesStaff" = IsNull(Salesman.Salesman_Name, N''),              
"Rounded Net Value" = IsNull(NetValue, 0) + IsNull(RoundOffAmount, 0),              
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
"Document Number" = InvoiceAbstract.DocReference,              
"Creation Date" = InvoiceAbstract.CreationTime,
"Doc Type" = DocSerialType,"LT_30%_Total_Value" = dbo.GetInvoiceTaxComponentTotalValue(@INVNO, 1 , 1),
"Cash Amount Returned" = (Select AmountReturned From RetailPaymentDetails Where RetailInvoiceID = @INVNO and PaymentMode=1)                                 
FROM InvoiceAbstract, Customer, VoucherPrefix Inv, Doctor, Salesman
WHERE InvoiceID = @INVNO               
AND InvoiceAbstract.CustomerID *= Customer.CustomerID              
AND Inv.TranID = N'RETAIL INVOICE'              
AND InvoiceAbstract.ReferredBy *= Doctor.ID              
AND InvoiceAbstract.SalesmanID *= Salesman.SalesmanID
