CREATE Procedure sp_Update_Customer_recForumCode (@ForumCode nvarchar(20),    
      @CustomerID nvarchar(20))    
As    
  
Update POAbstractReceived Set CustomerID = @CustomerID  
Where ForumCode = @ForumCode  
Update Schemes_Rec set CompanyID = @CustomerID  
Where ForumCode = @ForumCode    
Update ClaimsNoteReceived Set CustomerID = @CustomerID  
Where ForumCode = @ForumCode 
