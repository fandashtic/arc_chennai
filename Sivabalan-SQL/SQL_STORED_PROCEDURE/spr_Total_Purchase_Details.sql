
Create Proc spr_Total_Purchase_Details (@FromDate datetime)
as 
Declare @ToDate datetime
set @ToDate = Dateadd(d,1,@FromDate)
select 
	"Date"= cast(DATEPART(d, BillAbstract.BillDate)  as nvarchar) +  '/' + 
		cast(DATEPART(m, BillAbstract.BillDate)  as nvarchar) + '/'  +
		cast(DATEPART(yy, BillAbstract.BillDate) as nvarchar) ,
	"Bill ID" = BillAbstract.BillId,
	"VendorId" = BillAbstract.VendorId, 
	"Vendor Name" = Vendors.Vendor_Name,
	"Purchase Value" = Sum(BillAbstract.Value + BillAbstract.TaxAmount + BillAbstract.AdjustmentAmount)  ,
	"Discount" = isnull(Sum((BillDetail.PurchasePrice * BillDetail.Quantity) - isnull(BillDetail.Amount, 0)), 0) , 
	"Tax" = isnull(Sum(BillAbstract.TaxAmount), 0)

from 	
	BillAbstract, BillDetail, Vendors
where 	
	BillAbstract.BillId = BillDetail.BillId AND
	Billabstract.BillDate between @FromDate and @ToDate AND
	(BillAbstract.Status & 128) <> 0 AND
	Vendors.VendorId = Billabstract.VendorId
Group by 
	cast(DATEPART(d, BillAbstract.BillDate)  as nvarchar) +  '/' +
	cast(DATEPART(m, BillAbstract.BillDate)  as nvarchar) + '/' +
	cast(DATEPART(yy, BillAbstract.BillDate) as nvarchar) , 
	BillAbstract.BillId,
	BillAbstract.VendorId, 
	Vendors.Vendor_Name

