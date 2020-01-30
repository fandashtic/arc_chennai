CREATE PROCEDURE sp_ser_print_SITaskAbstract_SingleITEM(@INVNO INT)      
AS   
Declare @TotalRate decimal(18, 6)
Declare @TotalTaxPer decimal(18, 6)
Declare @TotalTaxValue decimal(18, 6)                                            
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

Select
@TotalRate  = IsNull(Sum(SDetail.Price), 0),
@TotalTaxPer = Isnull(Avg(SDetail.ServiceTax_Percentage), 0),
@TotalTaxValue = Isnull(Sum(SDetail.ServiceTax), 0)
from ServiceInvoiceDetail SDetail 
Where SDetail.ServiceInvoiceID = @INVNO 
	and SDetail.Type in (1,2) 
	and IsNull(SDetail.SpareCode, '') = ''
	and IsNull(SDetail.TaskID, '') <> ''
Group by SDetail.ServiceInvoiceID

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
"Colour" = Isnull(IInfo.Colour, ''),
"Open Time" = (Select Max(JDetail.TimeIn) from JobcardDetail JDetail 
		Where JDetail.JobCardID = Jabstract.JobCardID 
		and JDetail.Product_Code = IInfo.Product_Code 
		and JDetail.Product_Specification1 = IInfo.Product_Specification1 
		and JDetail.Type = 0), 
"Close Time" = SAbstract.CreationTime, 

"Total Rate" = @TotalRate,
"Total Task Amount" = Sdetail.Tasksum,
"Total Tax%" = @TotalTaxPer,
"Total Tax Value" = @TotalTaxValue, 
"Total Task Net" = Sdetail.TasksumNet,
"Freight" = ISnull(Freight,0),
"Total Spare Amount" = Sdetail.Sparesum,
"Total Spare Net" = Sdetail.SparesumNet,
"Collected Amount" = (Sabstract.Netvalue + roundoffamount - balance),
"CustomerServiceCharge" = Isnull(@CustomerServiceCharge, 0), 
"JobCardID" =  @Prefix1 + cast(Jabstract.DocumentID as nvarchar(15)),
"JobCard Date" = Jabstract.Jobcarddate,
"EstimationID" =  @Prefix2 + cast(Eabstract.DocumentID as nvarchar(15)),
"Estimation Date" = Eabstract.EstimationDate,
"Additional Discount%" = Isnull(AdditionalDiscountPercentage, 0), 
"Additional Discount Value" = Isnull(AdditionalDiscountValue, 0),   
"Trade Discount%" = Isnull(TradeDiscountPercentage, 0),
"Trade Discount Value" = Isnull(TradeDiscountValue, 0),
"Total Task Net Value" = Sdetail.TasksumNet, 
"Total Task Amount" = Sdetail.Tasksum,
"Total Spare Net Value" = Sdetail.SparesumNet, 
"Total Spare Amount" = Sdetail.Sparesum,
"Net Value with Service Charge" = (Sdetail.TasksumNet + Isnull(@CustomerServiceCharge, 0)),
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
Inner Join (SELECT SDet.ServiceinvoiceID,
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
	where SDet.ServiceinvoiceID = @INVNO group by SDet.ServiceinvoiceID) Sdetail 
On Sabstract.Serviceinvoiceid = Sdetail.Serviceinvoiceid 
where Sabstract.Serviceinvoiceid = @INVNO and 
1 = (Select Count(*) from ServiceInvoiceDetail SD Where SD.Type = 0 and SD.ServiceInvoiceID = @INVNO)


