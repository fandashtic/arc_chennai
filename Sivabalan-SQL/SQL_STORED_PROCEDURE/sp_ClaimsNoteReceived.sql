CREATE PROCEDURE sp_ClaimsNoteReceived        
(@ClaimID nvarchar(20), @ClaimDate datetime, @ClaimType nvarchar(50), @VendorID nvarchar(50),        
@DocReference nvarchar(100), @ClaimValue Decimal(18,6),@ForumCode as nvarchar(20))        
AS        
DECLARE @RECCUSID AS nvarchar(20)  
SELECT @RECCUSID = ISNULL(customerid,N'') FROM CUSTOMER WHERE ALTERNATECODE = @ForumCode  
INSERT INTO ClaimsNoteReceived        
(ClaimID , ClaimDate , ClaimType , CustomerID         
,DocReference ,ClaimValue,ForumCode)        
VALUES        
(@ClaimID , @ClaimDate , @ClaimType ,@RECCUSID         
,@DocReference ,@ClaimValue,@ForumCode)        
    
    
  
  


