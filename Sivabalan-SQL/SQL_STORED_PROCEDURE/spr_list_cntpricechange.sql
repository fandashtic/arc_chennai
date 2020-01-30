CREATE PROCEDURE spr_list_cntpricechange(@FROMDATE DATETIME,
					  @TODATE DATETIME)
AS
select downloadeditems.CompanyID, "CompanyID" = downloadeditems.CompanyID, 
"Company" = Customer.Company_Name, "No. Of Items" = Count(*)
from downloadeditems, Customer where [id] in (
select max([id])
from downloadeditems, Customer 
where downloadeditems.companyid = Customer.CustomerID
AND downloadeditems.DocumentDate BETWEEN @FROMDATE AND @TODATE
and DocumentType in ('PriceChange')
group by product_id )
AND downloadeditems.companyid = Customer.CustomerID
AND downloadeditems.DocumentDate BETWEEN @FROMDATE AND @TODATE
group by downloadeditems.companyid, Customer.Company_Name
UNION 
select downloadeditems.CompanyID, downloadeditems.CompanyID, Vendors.Vendor_Name, 
Count(*)
from downloadeditems, Vendors where [id] in (
select max([id])
from downloadeditems, Vendors
where downloadeditems.companyid = Vendors.VendorID
AND downloadeditems.DocumentDate BETWEEN @FROMDATE AND @TODATE
and DocumentType in ('PriceChange')
group by product_id )
AND downloadeditems.companyid not in (select CustomerID from Customer)
AND downloadeditems.companyid = Vendors.VendorID
AND downloadeditems.DocumentDate BETWEEN @FROMDATE AND @TODATE
group by downloadeditems.companyid, Vendors.Vendor_Name
