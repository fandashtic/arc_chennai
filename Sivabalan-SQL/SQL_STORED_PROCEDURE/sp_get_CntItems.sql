
CREATE PROCEDURE sp_get_CntItems

AS

select Customer.Company_Name, downloadeditems.CompanyID, Count(*) 
from downloadeditems, customer where [id] in (
select max([id])
from downloadeditems, Customer where status = 0 
and downloadeditems.companyid = customer.customerid
group by product_id )
and downloadeditems.companyid = customer.customerid
group by customer.company_Name, downloadeditems.companyid 


