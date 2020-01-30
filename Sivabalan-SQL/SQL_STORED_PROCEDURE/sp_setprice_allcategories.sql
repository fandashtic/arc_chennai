

CREATE proc sp_setprice_allcategories
as
select categoryid, Product_Code, ProductName, Sale_Price from items order by categoryid

