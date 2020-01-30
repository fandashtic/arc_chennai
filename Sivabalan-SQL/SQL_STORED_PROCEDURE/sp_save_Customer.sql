CREATE PROCEDURE sp_save_Customer(@CUSTOMERID NVARCHAR(15),  
      @BILLING NVARCHAR(255),  
      @SHIPPING NVARCHAR(255))  
AS     
Begin
    
	UPDATE Customer SET BillingAddress = @BILLING, ShippingAddress = @SHIPPING  
	WHERE CustomerID = @CUSTOMERID and isnull(PreDefFlag,0) = 0    

End
