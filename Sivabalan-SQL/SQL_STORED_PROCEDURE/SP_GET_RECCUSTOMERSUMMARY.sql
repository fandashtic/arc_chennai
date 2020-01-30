CREATE PROCEDURE SP_GET_RECCUSTOMERSUMMARY  
AS  
SELECT "Document Number"= DocumentNumber,DocumentDate,Null,Customer.Company_Name,Customer.CustomerID,  
PurchaseValue,CustomerSalesSummaryAbstract.CreationDate,CustomerSalesSummaryDetail.SerialNo,Null  
FROM CustomerSalesSummaryAbstract,CustomerSalesSummaryDetail,Customer  
WHERE Status  = 0 And  
CustomerSalesSummaryAbstract.SerialNo=CustomerSalesSummaryDetail.SerialNo And  
CustomerSalesSummaryDetail.CustomerForumCode = Customer.AlternateCode  
ORDER BY Customer.Company_Name  


