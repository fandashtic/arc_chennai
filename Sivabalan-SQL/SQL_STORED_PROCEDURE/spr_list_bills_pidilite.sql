CREATE PROCEDURE [dbo].[spr_list_bills_pidilite] (@VENDOR nvarchar(2550),
				@FROMDATE datetime, 
				@TODATE datetime)
AS

Declare @Delimeter as Char(1)  
Set @Delimeter=Char(15)  

create table #tmpVen(Vendor_Name nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
if @VENDOR=N'%'
   insert into #tmpVen select Vendor_Name from Vendors
else
   insert into #tmpVen select * from dbo.sp_SplitIn2Rows(@VENDOR,@Delimeter)

SELECT  BillID, "Bill ID" = CASE 
	WHEN DocumentReference IS NULL THEN
	BillPrefix.Prefix + CAST(DocumentID AS nVARCHAR)
	ELSE
	BillAPrefix.Prefix + CAST(DocumentID AS nVARCHAR)
	END,
	"Bill Date" = BillDate, 
	"Doc Reference" = DocIDReference,
	"CreditTerm"  = CreditTerm.Description, 
	"Payment Date" = PaymentDate, "InvoiceReference" = InvoiceReference,
	"Vendor" = Vendors.Vendor_Name, 
	"Gross Amount" = (Select Sum(Quantity * PurchasePrice) From BillDetail
	Where BillDetail.BillID = BillAbstract.BillID),
	"Tax Amount" = TaxAmount, 
	"Discount%" = Discount,
	"Discount Amount" = Cast((Select Sum(Quantity * PurchasePrice)  From BillDetail 
	Where BillDetail.BillID = BillAbstract.BillID) * Discount / 100 as Decimal(18,6)),
	"Adjustment Amount" = AdjustmentAmount, 
	"Adjusted Amount" = AdjustedAmount,
	"Net Amount" = Billabstract.Value + TaxAmount + AdjustmentAmount,
	"GRNID" = GRNPrefix.Prefix + CAST(NewGRNID AS nVARCHAR),
	"Status" = 
	CASE Status
	WHEN 0 THEN N'Open'	
	WHEN 128 THEN N'Amended'
	ELSE N'Cancelled'
	END,
	"Original Bill" = CASE DocumentReference
	WHEN NULL THEN N''
	ELSE BillPrefix.Prefix + CAST(DocumentReference AS nVARCHAR)
	END,
	"Branch" = ClientInformation.Description, "ST"  = TNGST, CST
FROM BillAbstract
Inner Join Vendors On 	BillAbstract.VendorID = Vendors.VendorID
Inner Join VoucherPrefix BillPrefix On BillPrefix.TranID = N'BILL'
Inner Join VoucherPrefix GRNPrefix On GRNPrefix.TranID = N'GOODS RECEIVED NOTE' 
Left Outer Join ClientInformation On BillAbstract.ClientID = ClientInformation.ClientID
Inner Join VoucherPrefix BillAPrefix On BillAPrefix.TranID = N'BILL AMENDMENT'
Left Outer Join CreditTerm On CreditTerm.CreditID = BillAbstract.CreditTerm
WHERE   BillDate BETWEEN @FROMDATE AND @TODATE AND
	Vendors.Vendor_Name in(select Vendor_Name COLLATE SQL_Latin1_General_CP1_CI_AS from #tmpVen) AND
	IsNull(BillAbstract.Status, 0) & 192 = 0 
ORDER BY BillAbstract.BillDate
drop table #tmpVen



