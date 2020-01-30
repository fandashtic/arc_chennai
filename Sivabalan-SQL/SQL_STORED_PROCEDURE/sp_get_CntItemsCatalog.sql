
CREATE PROCEDURE sp_get_CntItemsCatalog
AS
select Vendors.Vendor_Name, downloadeditems.CompanyID, Count(*)
from downloadeditems, Vendors where [id] in (
select max([id])
from downloadeditems, Vendors
where status = 0 
and downloadeditems.companyid = Vendors.AlternateCode
and DocumentType in ('CustomCatalog', 'OtherChange')
group by downloadeditems.companyid, product_id )
and downloadeditems.companyid = Vendors.AlternateCode
and Vendors.Active = 1
group by Vendors.Vendor_Name, downloadeditems.companyid

union

select Customer.Company_Name, downloadeditems.CompanyID, Count(*)
from downloadeditems, Customer where [id] in (
select max([id])
from downloadeditems, Customer
where status = 0 
and downloadeditems.companyid = Customer.AlternateCode
and DocumentType in ('CustomCatalog', 'OtherChange')
group by downloadeditems.companyid, product_id )
and downloadeditems.companyid = Customer.AlternateCode
AND Customer.CustomerID Not in (Select AlternateCode FROM Vendors)
and Customer.Active = 1
group by Customer.Company_Name, downloadeditems.companyid

