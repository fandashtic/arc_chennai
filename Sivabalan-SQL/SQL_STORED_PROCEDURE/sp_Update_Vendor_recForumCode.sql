CREATE Procedure sp_Update_Vendor_recForumCode (@VendorID nvarchar(20), @ForumCode nvarchar(20))    
As    
  
Update SOAbstractReceived Set VendorID = @VendorID  
Where ForumCode = @ForumCode  
Update InvoiceAbstractReceived Set VendorID = @VendorID  
Where ForumCode = @ForumCode  
Update Schemes_Rec set CompanyID = @VendorID  
Where ForumCode = @ForumCode 
