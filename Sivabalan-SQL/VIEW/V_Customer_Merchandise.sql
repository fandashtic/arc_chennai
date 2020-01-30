CREATE VIEW   [V_Customer_Merchandise]
([CustomerID],[MerchandiseID],[Merchandise])
AS
SELECT Customer.CustomerID, mer.MerchandiseID,mer.Merchandise
FROM  merchandise mer 
inner join CustMerchandise Custmer on mer.MerchandiseID =Custmer.MerchandiseID 
inner join Customer  on Custmer.CustomerID =Customer.CustomerID  
where Customer.Active = 1 and mer.Active = 1
