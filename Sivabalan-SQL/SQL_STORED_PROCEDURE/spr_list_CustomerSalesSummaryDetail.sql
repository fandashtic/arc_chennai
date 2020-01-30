CREATE Procedure spr_list_CustomerSalesSummaryDetail(@DocumentNumber nvarchar(250))  
As  
Select CustomerForumCode,"Forum Code" =CustomerForumCode ,"Customer ID "= Customer.CustomerID,  
"Customer Name " = Customer.Company_Name,"No of Purchases " = NoPurchase,  
"Accumulated Points " = CustomerSalesSummaryDetail.AccumulatedPoints,  
"Redeemed Points " = CustomerSalesSummaryDetail.RedeemedPoints,  
"Purchase value " = PurchaseValue  
From CustomerSalesSummaryAbstract,CustomerSalesSummaryDetail,Customer  
Where CustomerSalesSummaryDetail.CustomerID=Customer.CustomerID  
And CustomerSalesSummaryAbstract.DocumentNumber=@DocumentNumber
And CustomerSalesSummaryAbstract.SerialNo=CustomerSalesSummaryDetail.SerialNo  
  



