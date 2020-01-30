CREATE PROCEDURE sp_ser_print_ServiceInvoiceSpareAbstract(@INVNO INT)      
AS      
--- Based on Erp Procedure sp_print_invabstract (Copy taken on 26.12.05)

Declare @TotalTax Decimal(18,6)      
Declare @TotalQty Decimal(18,6)      
Declare @FirstSales Decimal(18, 6)      
Declare @SecondSales Decimal(18, 6)      
Declare @Savings Decimal(18,6)      
Declare @GoodsValue Decimal(18,6)      
Declare @ProductDiscountValue Decimal(18,6)      
Declare @NetValue Decimal(18,6)      
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
Declare @AddnDiscount Decimal(18, 6)
Declare @TradeDiscount Decimal(18, 6)
Declare @CollectionID Int

Select @AddnDiscount = AdditionalDiscountPercentage, @TradeDiscount = TradeDiscountPercentage,
	@CollectionID = Cast(PaymentDetails As Int)
	From ServiceInvoiceAbstract Where ServiceInvoiceID = @INVNO
Select @TotalTax = SUM(ISNULL(LSTPayable, 0) + Isnull(CstPayable, 0)), 
@TotalQty = ISNULL(SUM(Quantity), 0),      
@FirstSales = (Select IsNull(Sum(LSTPayable + CSTPayable), 0)      
		From ServiceInvoiceDetail      
		Where ServiceInvoiceID = @InvNo And SaleID = 1),      
@SecondSales = (Select IsNull(Sum(LSTPayable + CSTPayable), 0) From ServiceInvoiceDetail      
		Where ServiceInvoiceID = @InvNo And SaleID = 2),      
-- @Savings = Sum(MRP * IsNull(Quantity, 0)) - Sum(Price * Isnull(Quantity, 0)),      
@GoodsValue = SUM(IsNull(Quantity, 0) * Price),      
@ProductDiscountValue = Sum(ItemDiscountValue),      
@NetValue = Sum(NetValue),
@AvgProductDiscountPercentage = Avg(ItemDiscountPercentage),
@TaxApplicable = Sum(IsNull(CSTPayable , 0) + IsNull(LSTPayable, 0)),
@TotTaxableSaleVal = 
	Sum(Case 
	When IsNull(CSTPayable, 0) = 0 And IsNull(LSTPayable, 0) = 0 Then
	0
	Else
	Amount
	End),
@TotNonTaxableSaleVal = 
	Sum(Case 
	When IsNull(CSTPayable, 0) = 0 And IsNull(LSTPayable, 0) = 0 Then
	Amount
	Else
	0
	End),
@TotTaxableGV = 
	Sum(Case 
	When IsNull(CSTPayable, 0) = 0 And IsNull(LSTPayable, 0) = 0 Then
	0
	Else
	((isnull(Quantity, 0) * Price) - ItemDiscountValue + 
		(Isnull(Quantity, 0) * Price * TaxSuffered /100))
	End),
@TotNonTaxableGV = 
	Sum(Case 
	When IsNull(CSTPayable, 0) = 0 And IsNull(LSTPayable, 0) = 0 Then
	((Quantity * Price) - ItemDiscountValue + (isnull(Quantity, 0) * Price * TaxSuffered /100))
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
	((Quantity * Price) - ItemDiscountValue)
	End),
@TotNonTaxSuffGV = 
	Sum(Case
	When IsNull(TaxSuffered, 0) = 0 Then
	((Quantity * Price) - ItemDiscountValue)
	Else
	0
	End),
@TotFirstSaleGV = 
	Sum(Case SaleID
	When 1 Then
	((Isnull(Quantity, 0) * Price) - isnull(ItemDiscountValue, 0) + 
		(IsNull(Quantity, 0) * Price * Isnull(TaxSuffered, 0) /100))
	Else
	0
	End),
@TotSecondSaleGV = 
	Sum(Case SaleID
	When 1 Then
	0
	Else
	((Isnull(Quantity, 0) * Price) - Isnull(ItemDiscountValue, 0) + 
		(IsNull(Quantity, 0) * Price * Isnull(TaxSuffered, 0) /100))
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
	((IsNull(CSTPayable , 0) + IsNull(LSTPayable, 0)) - 
	((IsNull(CSTPayable , 0) + IsNull(LSTPayable, 0)) * (@AddnDiscount + @TradeDiscount) / 100))
	Else
	0
	End),
@TotSecondSaleTaxApplicable = 
	Sum(Case SaleID
	When 1 Then
	0
	Else
	((IsNull(CSTPayable , 0) + IsNull(LSTPayable, 0)) -
	((IsNull(CSTPayable , 0) + IsNull(LSTPayable, 0)) * (@AddnDiscount + @TradeDiscount) /100))
	End), 
@TaxSuffered = Sum(TaxSuffered),  @ItemCount = Count(*)
from ServiceInvoiceDetail      
where ServiceInvoiceID = @INVNO and Isnull(SpareCode, '') <> '' 

SELECT 
"Gross Value" = @GoodsValue, 
"Discount%" = @AvgProductDiscountPercentage, "Discount Value" = ItemDiscount,     
"Net Value" = @NetValue, "Shipping Address" = SAbstract.ShippingAddress,      
"Addn Discount%" = AdditionalDiscountPercentage, "Freight" = Freight,       
"Serial No" = ServiceInvoiceID, 
"Total Tax" = @TotalTax, 
"Total Qty" = @TotalQty,      
"First Sales Total" = @FirstSales, "Second Sales Total" = @SecondSales,            
"Goods Value" = @GoodsValue, "Product Discount Value" = @ProductDiscountValue,      
"Resale Tax" = @TaxApplicable,
"Gross Value (GoodsValue+ResaleTax+TaxSuffered)" = @GoodsValue + @TaxApplicable + @Taxsuffered,      
"OverAll Discount Value" = ((@GoodsValue - @ProductDiscountValue) * (AdditionalDiscountPercentage + TradeDiscountPercentage) /100),      
"OverAll Discount%" = AdditionalDiscountPercentage + TradeDiscountPercentage,      
"Item Count" = @ItemCount,      
"Adjustment Value" = SAbstract.AdjustmentValue,      
"Rounded Net Value" = 0 - (NetValue + RoundOffAmount),      
"Average Product Discount Percentage" = @AvgProductDiscountPercentage,      
"Sales Tax" = (@TotalTax / 1.05),      
"Surcharge" = ((@TotalTax / 1.05) * 0.05),      
"Total Sales Tax minus CESS" = cast((Isnull(@SalesTaxwithcess,0)/1.15) + (Isnull(@SalesTaxwithoutcess,0)) as Decimal(18, 6)),    
"CESS" = cast(((Isnull(@SalesTaxwithcess,0) / 1.15) * 0.15)as Decimal(18, 6)),     
"Total Amount Before Tax" = NetValue - @TaxApplicable,
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
"Creation Date" = SAbstract.CreationTime,
"Addl Discount Value" = AdditionalDiscountValue_Spare,
"Total Weight" = (
		select sum(Isnull(quantity, 0) * conversionfactor)
		from Serviceinvoicedetail idt , Serviceinvoiceabstract ia, items
		where idt.Serviceinvoiceid = ia.Serviceinvoiceid and ia.Serviceinvoiceid = @INVNO
		and idt.product_code = items.product_code 
				),
"Total Tax Suffered" = IsNull(@Taxsuffered,0)
FROM ServiceInvoiceAbstract SAbstract
Inner Join Customer On SAbstract.CustomerID = Customer.CustomerID
WHERE ServiceInvoiceID = @INVNO


