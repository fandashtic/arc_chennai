CREATE Procedure sp_ser_print_ServiceInvoiceAbstract(@InvoiceID as int)
As              
                                            
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
	From ServiceInvoiceAbstract Where ServiceInvoiceID = @InvoiceID

Select @AdjustedValue = IsNull(Sum(CollectionDetail.AdjustedAmount), 0) 
From CollectionDetail, ServiceInvoiceAbstract      
Where CollectionID = Cast(PaymentDetails as int) 
	And CollectionDetail.DocumentID <> @InvoiceID
	And ServiceInvoiceID = @InvoiceID      
              
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
"ServiceInvoiceID" =  @Prefix + cast(Sabstract.DocumentID as nvarchar(15)), 
"ServiceInvoice Date" = serviceinvoiceDate,
"Doc Ref" = DocReference,
"CreditTerm" = Sabstract.CreditTerm,
"CustomerID" =  Sabstract.Customerid,
"Customer Name" =  company_Name,
"Billing Address" = SAbstract.BillingAddress, 
"Product Discount" = Isnull(Itemdiscount,0),
"Trade Discount(%)" = Tradediscountpercentage,
"Trade Discount"  = ISnull(Tradediscountvalue,0),
"Additional Discount(%)" = AdditionalDiscountPercentage,
"Additional Discount" = Isnull(AdditionalDiscountValue,0),
"Freight" = ISnull(Freight,0),
"Task Amount" = Sdetail.Tasksum,
"Spare Amount" = Sdetail.Sparesum,
"Task Net" = Sdetail.TasksumNet,
"Spare Net" = Sdetail.SparesumNet,
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
"Adjustments" = dbo.sp_ser_GetAdjustments(cast(SAbstract.PaymentDetails as int), @InvoiceID),
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
	where SDet.ServiceinvoiceID = @InvoiceID group by SDet.ServiceinvoiceID
) Sdetail On Sabstract.Serviceinvoiceid = Sdetail.Serviceinvoiceid 
where Sabstract.Serviceinvoiceid = @InvoiceID



