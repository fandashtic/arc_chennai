
CREATE  proc sp_setprice_selectedcategory (@CATEGORYID INT )
as
select categoryid, Product_Code, ProductName, Purchase_Price from items 
where categoryid =  @CATEGORYID and Active = 1 order by categoryid



