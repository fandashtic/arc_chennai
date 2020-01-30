
Create Proc spr_Total_Purchase (@FromDate datetime, @ToDate datetime)
as 
select 
	"Date"= cast(DATEPART(d, BillAbstract.BillDate)  as nvarchar) +  '/' + 
		cast(DATEPART(m, BillAbstract.BillDate)  as nvarchar) + '/'  +
		cast(DATEPART(yy, BillAbstract.BillDate) as nvarchar) ,

	"Total Purchase Value" = Sum(BillAbstract.Value + BillAbstract.TaxAmount + BillAbstract.AdjustmentAmount)  ,
	"Discount" = isnull(Sum((BillDetail.PurchasePrice * BillDetail.Quantity) - isnull(BillDetail.Amount, 0)), 0) , 
	"Tax" = isnull(Sum(BillAbstract.TaxAmount), 0), 
	"Number of Bills" = count(BillAbstract.BillId)
from 	
	BillAbstract, BillDetail
where 	
	BillAbstract.BillId = BillDetail.BillId AND
	Billabstract.BillDate between @FromDate and @ToDate AND
	(BillAbstract.Status & 128) <> 0
	
Group by 
		cast(DATEPART(d, BillAbstract.BillDate)  as nvarchar) +  '/' +
		cast(DATEPART(m, BillAbstract.BillDate)  as nvarchar) + '/' +
		cast(DATEPART(yy, BillAbstract.BillDate) as nvarchar) 

