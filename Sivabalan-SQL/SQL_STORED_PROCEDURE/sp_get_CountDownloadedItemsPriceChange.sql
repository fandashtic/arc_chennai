
CREATE PROCEDURE sp_get_CountDownloadedItemsPriceChange

AS

select Vendors.Vendor_Name, downloadeditems.CompanyID, Count(*) 
from downloadeditems, Vendors where [id] in (
select max([id])
from downloadeditems, Vendors where status = 0 
and downloadeditems.companyid = Vendors.VendorID
and DocumentType = 'PriceChange'
group by product_id )
and downloadeditems.companyid = Vendors.VendorID
group by Vendors.Vendor_Name, downloadeditems.companyid 
union
select Customer.Company_Name, downloadeditems.CompanyID, Count(*) 
from downloadeditems, customer where [id] in (
select max([id])
from downloadeditems, Customer where status = 0 
and downloadeditems.companyid = customer.customerid
and DocumentType = 'PriceChange'
group by product_id )
and downloadeditems.companyid = customer.customerid
group by customer.company_Name, downloadeditems.companyid 

