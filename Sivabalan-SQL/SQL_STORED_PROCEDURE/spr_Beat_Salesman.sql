
create proc spr_Beat_Salesman(@FROMDATE DATETIME, @TODATE DATETIME)
as
select Product_Code ,  (quantity*saleprice) from dispatchdetail where dispatchid in
(select dispatchid from dispatchabstract where dispatchdate between 
@FROMDATE and @TODATE ) group by Product_Code,   (quantity*saleprice)



