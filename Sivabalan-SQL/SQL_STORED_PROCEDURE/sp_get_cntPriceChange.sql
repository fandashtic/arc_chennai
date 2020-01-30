
CREATE PROCEDURE sp_get_cntPriceChange

AS

select Vendors.Vendor_Name, downloadeditems.CompanyID, Count(*) 
from downloadeditems, Vendors where [id] in (
select max([id])
from downloadeditems, Vendors where status = 0 
and downloadeditems.companyid = Vendors.AlternateCode
and DocumentType = 'PriceChange'
group by downloadeditems.companyid, product_id )
and downloadeditems.companyid = Vendors.AlternateCode
and Vendors.Active = 1
group by Vendors.Vendor_Name, downloadeditems.companyid 

union

select Customer.Company_Name, downloadeditems.CompanyID, Count(*) 
from downloadeditems, customer where [id] in (
select max([id])
from downloadeditems, Customer where status = 0 
and downloadeditems.companyid = customer.AlternateCode
and DocumentType = 'PriceChange'
group by downloadeditems.companyid, product_id )
and downloadeditems.companyid = customer.AlternateCode
and Customer.Active = 1
group by customer.company_Name, downloadeditems.companyid 

