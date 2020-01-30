CREATE Procedure sp_acc_gj_inputserviceinvoice (@invoiceid INT,@BackDate DATETIME=Null)
AS
--Journal entry for Retail Invoice
Declare @Invoicedate datetime,
@NetValue float,
@TaxAmount float,
@BranchID nvarchar(25),
@AccountID int,
@TransactionID int,
@DocumentNumber int,
@PartyID int, --Vendor/Customer
@AccountType Int,
@count int ,
@Rowid int,
@GST_Payable int,
--@gst_payableoutput int,
@GSTaxComponent int ,
@nGSTaxAmt decimal(18,6),
@code  nvarchar(200),
@serviceFor	 int,
@TaxableValue decimal(18,6),
@InputTaxCr int

set dateformat dmy

Create Table #TempBackdatedAccounts(AccountID Int) --for backdated operation

create table #serdet  --for detail
(	id int identity(1,1),
invoiceid int,
Accountid int,
Taxablevalue decimal(18,6)
)

create table #gstaxcalc  --for gs tax calculation
(	id int identity(1,1),
invoiceid int,
tax_component_code int,
tax_value decimal(18,6)
)

Set @AccountType = 151 --Input Service Invoice

--Input Tax Credit Flag Checking
Select @InputTaxCr = IsNull(ITCEligible,0) from ServiceAbstract where InvoiceId = @invoiceid

Select @Invoicedate=TransactionDate, @NetValue=IsNull(totalNetamount,0),
@TaxAmount=IsNull(totalTaxAmount,0),@code = Code,@serviceFor = ServiceFor
from ServiceAbstract where InvoiceId =@invoiceid

insert into #serdet
(invoiceid , Accountid , Taxablevalue )
Select
srd.InvoiceId , styp.InputAccID , srd.TaxableValue
from ServiceDetails srd(Nolock)
Join ServiceTypeMaster  styp(Nolock)
On( srd.ServiceCode = styp.ServiceAccountCode
And srd.ServiceName = styp.ServiceName )
where srd.InvoiceId =@invoiceid

insert into #gstaxcalc
(invoiceid , tax_component_code , tax_value	 	)
select
invoiceid , taxcomponent , sum(taxsplitup)
from	ServiceInvoicesTaxSplitup	iv(nolock)
where invoiceid = @invoiceid
group by taxcomponent,invoiceid

if @serviceFor = 1
Select @PartyID = Accountid from Vendors where VendorID = @code
Else
Select @PartyID = Accountid from Customer where CustomerID = @code

-- Get the last TransactionID from the DocumentNumbers table
begin tran
update DocumentNumbers set DocumentID=DocumentID+1 where DocType=24
Select @TransactionID=DocumentID-1 from DocumentNumbers where DocType=24
Commit Tran
begin tran
update DocumentNumbers set DocumentID=DocumentID+1 where DocType=51
Select @DocumentNumber=DocumentID-1 from DocumentNumbers where DocType=51
Commit Tran

--Party Account
If @NetValue<>0
Begin
execute sp_acc_insertGJ @TransactionID,@PartyID,@Invoicedate,0,@NetValue,@invoiceid,@AccountType,"Input Service Invoice",@DocumentNumber
Insert Into #TempBackdatedAccounts(AccountID) Values(@PartyID)
End

--Entry for Sevice accounts
select @count = max(id) from #serdet
if (@count > 0)
begin
select @rowid = 1
while ( @rowid <= @count)
begin
select	@AccountID = Accountid,
@TaxableValue = Taxablevalue
from	#serdet
where	id = @rowid
If IsNull(@InputTaxCr,0) = 1
Begin
if (isnull(@TaxableValue,0)>0)
begin
execute sp_acc_insertGJ @TransactionID,@AccountID,@InvoiceDate,@TaxableValue,0,@InvoiceID,@AccountType,"Input Service Invoice",@DocumentNumber
Insert Into #TempBackdatedAccounts(AccountID) Values(@TaxableValue)
end
END
Else if IsNull(@InputTaxCr,0) = 0
Begin
if (isnull(@NetValue,0)>0)
begin
execute sp_acc_insertGJ @TransactionID,@AccountID,@InvoiceDate,@NetValue,0,@InvoiceID,@AccountType,"Input Service Invoice",@DocumentNumber
Insert Into #TempBackdatedAccounts(AccountID) Values(@TaxableValue)
end
End

select @rowid = @rowid+1
end
End

--Entry for GS Tax Accounts
IF IsNull(@InputTaxCr,0) = 1
Begin
set @count = 0
select @count = max(id) from #GSTaxCalc
if (@count > 0)
begin
select @rowid = 1
while ( @rowid <= @count)
begin
select	@GSTaxComponent = Tax_Component_Code,
@nGSTaxAmt		= Tax_Value
from	#GSTaxCalc
where	id = @rowid

if @nGSTaxAmt <> 0
begin
select  @gst_payable	  = InputAccID --, @gst_payableoutput = OutputAccID
from	TaxComponentDetail(nolock)
where	TaxComponent_Code = @GSTaxComponent
--If @Flag = 1
--Begin
if (isnull(@gst_payable,0)>0)
begin
execute sp_acc_insertGJ @TransactionID,@gst_payable,@InvoiceDate,@nGSTaxAmt,0,@InvoiceID,@AccountType,"Input Service Invoice",@DocumentNumber
Insert Into #TempBackdatedAccounts(AccountID) Values(@gst_payable)
end
--if (isnull(@gst_payableoutput,0)>0)
--begin
--	execute sp_acc_insertGJ @TransactionID,@gst_payableoutput,@InvoiceDate,0,@nGSTaxAmt,@InvoiceID,@AccountType,"Input Service Invoice",@DocumentNumber
--	Insert Into #TempBackdatedAccounts(AccountID) Values(@gst_payableoutput)
--end
--End
--ELSE If @Flag = 0
--Begin
--if (isnull(@gst_payableoutput,0)>0)
--begin
--	execute sp_acc_insertGJ @TransactionID,@gst_payableoutput,@InvoiceDate,0,@nGSTaxAmt,@InvoiceID,@AccountType,"Input Service Invoice",@DocumentNumber
--	Insert Into #TempBackdatedAccounts(AccountID) Values(@gst_payableoutput)
--end
--END
end
select @rowid = @rowid+1
end
End
End

/*Backdated Operation */

IF dbo.StripTimeFromDate(Cast(@Invoicedate as Datetime)) < dbo.StripTimeFromDate(Cast(GetDate() as Datetime))
Set @BackDate = @Invoicedate
If @BackDate Is Not Null
Begin
Declare @TempAccountID Int
DECLARE scantempbackdatedaccounts CURSOR KEYSET FOR
Select AccountID From #TempBackdatedAccounts
OPEN scantempbackdatedaccounts
FETCH FROM scantempbackdatedaccounts INTO @TempAccountID
WHILE @@FETCH_STATUS =0
Begin
Exec sp_acc_backdatedaccountopeningbalance @BackDate,@TempAccountID
FETCH NEXT FROM scantempbackdatedaccounts INTO @TempAccountID
End
CLOSE scantempbackdatedaccounts
DEALLOCATE scantempbackdatedaccounts
End
Drop Table #TempBackdatedAccounts
Drop Table #serdet
Drop Table #gstaxcalc
