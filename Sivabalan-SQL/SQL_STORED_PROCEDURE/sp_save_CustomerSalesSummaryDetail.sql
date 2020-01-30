CREATE Procedure sp_save_CustomerSalesSummaryDetail(@SerialNo Int,  
     @CustomerForumCode nvarchar(20),@NoPurchase Int,  
     @AccumulatedPoints Int,@RedeemedPoints Int,@PurchaseValue Decimal(18,6))      
As    
Declare @CustomerID nvarchar(30)  
  
IF @SerialNo>0 
Begin

Select @CustomerID=CustomerID From Customer Where AlternateCode=@CustomerForumCode  
  
Insert into CustomerSalesSummaryDetail(SerialNo,CustomerID,CustomerForumCode,    
            NoPurchase,AccumulatedPoints,    
            RedeemedPoints,PurchaseValue)        
            Values(@SerialNo,@CustomerID,@CustomerForumCode,    
            @NoPurchase,@AccumulatedPoints,    
            @RedeemedPoints,@PurchaseValue)       

End

