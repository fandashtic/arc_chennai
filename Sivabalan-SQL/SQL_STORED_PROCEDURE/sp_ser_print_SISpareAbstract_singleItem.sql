CREATE PROCEDURE sp_ser_print_SISpareAbstract_singleItem(@INVNO INT)      
AS      
--- Based on Erp Procedure sp_print_invabstract (Copy taken on 26.12.05)
Declare @Prefix nvarchar(15)                      
Declare @Prefix1 nvarchar(15)                      
Declare @Prefix2 nvarchar(15)                      
Declare @CollectionID int
Declare @ChequeNo Varchar(50)
Declare @ChequeDate Datetime
Declare @BankCode Varchar(50)
Declare @BankName Varchar(100)
Declare @BranchCode Varchar(50)
Declare @BranchName Varchar(100)
Declare @AdjustedValue decimal(18, 6)
Declare @CustomerServiceCharge decimal(18, 6)

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

select @Prefix = Prefix from VoucherPrefix where TranID = 'SERVICEINVOICE'                                      
select @Prefix1 = Prefix from VoucherPrefix where TranID = 'JOBCARD'                                      
select @Prefix2 = Prefix from VoucherPrefix where TranID = 'JOBESTIMATION'                                      

Select @CollectionID = Cast(PaymentDetails As Int)
	From ServiceInvoiceAbstract Where ServiceInvoiceID = @INVNO

Select @AdjustedValue = IsNull(Sum(CollectionDetail.AdjustedAmount), 0) 
From CollectionDetail, ServiceInvoiceAbstract      
Where CollectionID = Cast(PaymentDetails as int) 
	And CollectionDetail.DocumentID <> @INVNO
	And ServiceInvoiceID = @INVNO      
              
Select @ChequeNo = ChequeNumber, @ChequeDate = ChequeDate,
@BankCode = BankMaster.BankCode, @BankName = BankMaster.BankName,
@BranchCode = BranchMaster.BranchCode, @BranchName  = BranchMaster.BranchName,
@CustomerServiceCharge = CustomerServiceCharge
From Collections, BranchMaster, BankMaster 
Where DocumentID = @CollectionID And
Collections.BankCode = BankMaster.BankCode And
Collections.BranchCode = BranchMaster.BranchCode And
Collections.BankCode = BranchMaster.BankCode
/* Detail */


Select @AddnDiscount = AdditionalDiscountPercentage, @TradeDiscount = TradeDiscountPercentage,
	@CollectionID = Cast(PaymentDetails As Int)
	From ServiceInvoiceAbstract Where ServiceInvoiceAbstract.ServiceInvoiceID = @INVNO
Select @TotalTax = SUM(ISNULL(LSTPayable, 0) + Isnull(CstPayable, 0)), 
@TotalQty = ISNULL(SUM(Quantity), 0),      
@FirstSales = (Select IsNull(Sum(LSTPayable + CSTPayable), 0)      
		From ServiceInvoiceDetail      
		Where ServiceInvoiceDetail.ServiceInvoiceID = @InvNo And SaleID = 1),      
@SecondSales = (Select IsNull(Sum(LSTPayable + CSTPayable), 0) From ServiceInvoiceDetail      
		Where ServiceInvoiceDetail.ServiceInvoiceID = @InvNo And SaleID = 2),      
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
where ServiceInvoiceDetail.ServiceInvoiceID = @INVNO and Isnull(SpareCode, '') <> '' 
/* Detail end*/

Select 
"ServiceInvoiceID" =  @Prefix + cast(Sabstract.DocumentID as nvarchar(15)), 
"ServiceInvoice Date" = serviceinvoiceDate,
"Doc Ref" = DocReference,
"CreditTerm" = Sabstract.CreditTerm,
"CustomerID" =  Sabstract.Customerid,
"Customer Name" =  company_Name,
"Billing Address" = SAbstract.BillingAddress, 
"Item Code" = IInfo.Product_Code, 
"Item name" = IInfo.ProductName, 
"Item Spec1" = IsNull(IInfo.Product_Specification1, ''), 
"Item Spec2" = IsNull(IInfo.Product_Specification2, ''), 
"Item Spec3" = IsNull(IInfo.Product_Specification3, ''), 
"Item Spec4" = IsNull(IInfo.Product_Specification4, ''), 
"Item Spec5" = IsNull(IInfo.Product_Specification5, ''), 
"JobCardID" =  @Prefix1 + cast(Jabstract.DocumentID as nvarchar(15)),
"JobCard Date" = Jabstract.Jobcarddate,
"EstimationID" =  @Prefix2 + cast(Eabstract.DocumentID as nvarchar(15)),
"Estimation Date" = Eabstract.EstimationDate,
"Open Time" = (Select Max(JDetail.TimeIn) from JobcardDetail JDetail 
		Where JDetail.JobCardID = Jabstract.JobCardID 
		and JDetail.Product_Code = IInfo.Product_Code 
		and JDetail.Product_Specification1 = IInfo.Product_Specification1 
		and JDetail.Type = 0), 
"Close Time" = SAbstract.CreationTime, 
"Colour" = IInfo.Colour,
"Freight" = ISnull(Freight,0),
"Task Amount" = Sdetail.Tasksum,
"Spare Amount" = Sdetail.Sparesum,
"Task Net" = Sdetail.TasksumNet,
"Spare Net" = Sdetail.SparesumNet,
"Collected Amount" = (Sabstract.Netvalue + roundoffamount - balance),
"CustomerServiceCharge" = Isnull(@CustomerServiceCharge, 0), 
"Net Value" = NetValue, 
"Net Value with Service Charge" = NetValue + Isnull(@CustomerServiceCharge, 0),
"Invoice Type" = Case       
	When (SAbstract.Status & 64) = 64 then      
	'CANCELLED'      
	When (SAbstract.Status & 128) = 128 then      
	'AMENDED'      
	Else      
	'INVOICE'      
	End, 
"Remark" = SAbstract.Remarks,
-- MemoLabel1 =  MemoLabel1, 
-- MemoLabel2 = MemoLabel2,       
-- MemoLabel3 = Memolabel3, 
-- Memo1 = Memo1, 
-- Memo2 = Memo2,       
-- Memo3 = Memo3, 
"Payment Mode" = Case PaymentMode
	When 0 Then 'Credit'
	When 1 Then 'Cash'
	When 2 Then 'Cheque'
	When 3 Then 'DD' 
	When 4 Then 'Credit card' 
	When 5 Then 'Coupon' End,
"Cheque/DD Number" = @ChequeNo,
"Cheque/DD Date" = @ChequeDate,
"Bank Code" = @BankCode,
"Bank Name" = @BankName,
"Branch Code" = @BranchCode,
"Branch Name" = @BranchName,
"Payment Date" = PaymentDate, 
"CreditTerm" = CreditTerm.Description, 
"Adjustments" = dbo.sp_ser_GetAdjustments(cast(SAbstract.PaymentDetails as int), @INVNO),
"Adjustment Value" = @AdjustedValue,
"Outstanding" = dbo.sp_ser_CustomerOutStanding(SAbstract.CustomerID),      
"Balance" = Case SAbstract.PaymentMode      
	When 0 Then ((NetValue + RoundOffAmount + AdjustmentValue) - @AdjustedValue)      
	Else     
	SAbstract.Balance      
	End, 
"Gross Value" = @GoodsValue, 
"Net Value" = @NetValue, "Shipping Address" = SAbstract.ShippingAddress,      

"Trade Discount(%)" = Tradediscountpercentage,
"Trade Discount Value" = TradeDiscountValue_Spare, 
"Additional Discount(%)" = AdditionalDiscountPercentage,
"Additional Discount Value" = AdditionalDiscountValue_Spare, 
"Freight" = Freight,       
"Serial No" = SAbstract.ServiceInvoiceID, 
"Total Tax" = @TotalTax, 
"Total Qty" = @TotalQty,      
"First Sales Total" = @FirstSales, "Second Sales Total" = @SecondSales,            
"Goods Value" = @GoodsValue, 
"Resale Tax" = @TaxApplicable,
"Gross Value (GoodsValue+ResaleTax+TaxSuffered)" = @GoodsValue + @TaxApplicable + @Taxsuffered,      
"OverAll Discount Value" = ((@GoodsValue - @ProductDiscountValue) * (AdditionalDiscountPercentage + TradeDiscountPercentage) /100),      
"OverAll Discount%" = AdditionalDiscountPercentage + TradeDiscountPercentage,      
"Item Count" = @ItemCount,      
"Adjustment Value" = SAbstract.AdjustmentValue,      
"Rounded Net Value" = 0 - (NetValue + RoundOffAmount),      
"Product Discount Value" = @ProductDiscountValue,      
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
"Total Weight" = (
		select sum(Isnull(quantity, 0) * conversionfactor)
		from Serviceinvoicedetail idt , Serviceinvoiceabstract ia, items
		where idt.Serviceinvoiceid = ia.Serviceinvoiceid and ia.Serviceinvoiceid = @INVNO
		and idt.product_code = items.product_code 
				),
"Total Tax Suffered" = IsNull(@Taxsuffered,0), 

"DLNumber20" = DLNumber, "TNGST" = TNGST, "CST" = CST,       
"DLNumber21" = DLNumber21,       
"User Name" = SAbstract.UserName        
FROM serviceinvoiceabstract Sabstract
Inner Join Jobcardabstract Jabstract On Sabstract.Jobcardid = Jabstract.Jobcardid
Inner Join Estimationabstract Eabstract On Jabstract.Estimationid = Eabstract.EstimationID
Inner Join Customer On Sabstract.customerID = Customer.customerID
Left Outer Join (Select si.ServiceInvoiceID, si.Product_Code, Items.ProductName, 
	si.Product_Specification1, i.Product_Specification2, i.Product_Specification3, 
	i.Product_Specification4, i.Product_Specification5, G.[Description] Colour, 
	i.DateofSale, i.SoldBy
	from ServiceInvoiceDetail si 
	Inner Join Items On Items.Product_Code = si.Product_Code 
	Left Outer Join ItemInformation_Transactions i On 
		i.DocumentID = si.SerialNo and i.DocumentType = 3
	Left Join GeneralMaster G On G.Code = i.Color and IsNull(G.Type,0) = 1 
	where si.ServiceInvoiceID = @INVNO and si.Type = 0) IInfo 
On IInfo.ServiceInvoiceID = SAbstract.ServiceInvoiceID 
Left Outer Join CreditTerm On SAbstract.CreditTerm = CreditTerm.CreditID
Inner Join (
	SELECT SDet.ServiceinvoiceID,
		'Tasksum' = Sum(SDet.TaskAmt),
		'Sparesum' = Sum(SDet.SpareAmt),
		'TasksumNet' = Sum(SDet.TaskNet),
		'SparesumNet'  = Sum(SDet.SpareNet)
	from 
	(Select d.ServiceinvoiceID, 
		'TaskAmt' = case when Isnull(d.Taskid,'') <> '' and Isnull(d.sparecode,'') = '' then d.Amount else 0 end,
		'SpareAmt' = case when Isnull(d.sparecode,'') <> '' then d.Amount else 0 end,
		'TaskNet'= case when Isnull(d.Taskid,'') <> '' and Isnull(d.sparecode,'') = '' then d.Netvalue else 0 end,
		'SpareNet' = case when Isnull(sparecode,'') <> ''  then d.Netvalue else 0 end 
		from serviceinvoicedetail d) SDet 
	where SDet.ServiceinvoiceID = @INVNO group by SDet.ServiceinvoiceID
) Sdetail On Sabstract.Serviceinvoiceid = Sdetail.Serviceinvoiceid 
WHERE SAbstract.ServiceInvoiceID = @INVNO and 1 = 
(Select Count(*) from ServiceInvoiceDetail SD Where SD.Type = 0 and SD.ServiceInvoiceID = @INVNO)




