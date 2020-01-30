CREATE VIEW [dbo].[V_Customer_Schemes_bak]  
([SchemeID],[CustomerID],[AllotedAmount])  
AS  
SELECT SchemeID, CustomerID,AllotedAmount  
FROM SchemeCustomers  
