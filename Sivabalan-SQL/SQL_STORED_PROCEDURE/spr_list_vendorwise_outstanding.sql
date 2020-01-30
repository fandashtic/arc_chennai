CREATE procedure spr_list_vendorwise_outstanding( @vendorname nvarchar(15),@fromdate datetime,
						@todate datetime)
as
create table #temp (vendorid nvarchar(15), doccount int null, value decimal(18,2)null)
insert #temp(vendorid, doccount, value)  	
select creditnote.VendorID, count(CreditID), sum(creditnote.Balance)
from creditnote, vendors
where vendors.VendorID = creditnote.VendorID and  
creditnote.Balance > 0  and
vendors.Vendor_Name like @vendorname and  
creditnote.DocumentDate between @FromDate and @ToDate 
group by creditnote.VendorID  

insert #temp(vendorid, doccount, value)  
select debitnote.VendorID, count(DebitId), 0 - sum(Debitnote.Balance)   
from debitnote, vendors  
where vendors.VendorID = Debitnote.VendorID and  
Debitnote.Balance > 0  and
vendors.Vendor_Name like @vendorname and  
debitnote.DocumentDate between @FromDate and @ToDate 
group by Debitnote.VendorID  

insert #temp(vendorid, doccount, value)
select billabstract.VendorID, count(BillID), sum(BillAbstract.Balance)
from billabstract, Vendors
where billabstract.VendorID = Vendors.VendorID And
Vendors.Vendor_Name like @vendorname And
BillAbstract.BillDate Between @FromDate And @ToDate And
BillAbstract.Balance > 0 And
BillAbstract.Status & 128 = 0
group By BillAbstract.VendorID

insert #temp(vendorid, doccount, value)
select AdjustmentReturnAbstract.VendorID, count(AdjustmentID), 
0 - sum(AdjustmentReturnAbstract.Balance) from AdjustmentReturnAbstract, Vendors
where AdjustmentReturnAbstract.VendorID = Vendors.VendorID And
Vendors.Vendor_Name like @vendorname And
AdjustmentReturnAbstract.AdjustmentDate Between @FromDate And @ToDate And
AdjustmentReturnAbstract.Balance > 0 and
AdjustmentReturnAbstract.Status & 192 = 0
group By AdjustmentReturnAbstract.VendorID

select #temp.vendorid, "VendorID" = #temp.vendorid, "Vendor" =  Vendors.Vendor_Name,
"No. Of Purchases" = sum(doccount), "OutStanding Value (Rs)" = sum(Value)
from #temp, Vendors
where #temp.VendorID = Vendors.VendorID
group By #temp.VendorID, Vendors.Vendor_Name
drop table #temp