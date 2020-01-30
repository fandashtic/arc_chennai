CREATE PROCEDURE [sp_put_PODocHeader_Branch]      
 (      
 @POReference  [int],      
  @PODate  [datetime],      
  @CustomerID  [nvarchar](15),      
  @RequiredDate  [datetime],      
  @Value   Decimal(18,6),      
  @BillingAddress  [nvarchar](255),      
  @ShippingAddress  [nvarchar](255),      
  @DocumentID  int,    
  @BrForumCode [nvarchar](15),    
  @SalesManName [nvarchar](200) = Null    
 )      
      
AS       
DECLARE @Corrected_Code nvarchar(20)      
DECLARE @OriginalID nvarchar(20)      
DECLARE @POPrefix nvarchar(20)    
DECLARE @SalesManID int    
      
select @OriginalID = CustomerID FROM Customer WHERE AlternateCode = @CustomerID      
SET @Corrected_Code = ISNULL(@OriginalID, @CustomerID)      
select @POPrefix = isnull(prefix,N'') from voucherprefix where TranID = N'purchase order'    
    
if not isnull(@salesManName,N'') = N''   
begin    
	Select @SalesManID=SalesManID from SalesMan where SalesMan_Name = @SalesManname    
	if isnull(@salesManId,0) = 0     
	begin    
		insert into salesman (Salesman_Name,CreationDate,Active) Values(@salesmanname, getdate(),1)    
		set @SalesManID = @@IDENTITY    
	end    
end    
Else
begin
	set @SalesManID = 0
	set @SalesManname = N''
End
    
INSERT INTO [POAbstractReceived]       
  (        
 [POReference],      
 [PODate],      
  [CustomerID],      
  [RequiredDate],      
  [Value],      
  [CreationTime],      
  [BillingAddress],      
  [ShippingAddress],      
  [DocumentID],      
  [POPrefix],      
  ForumCode  ,    
  BranchForumCode,    
  SalesManName,    
  SalesManID    
  )       
VALUES       
 (       
 @POReference,      
 @PODate,      
  @Corrected_Code,      
  @RequiredDate,      
  @Value,      
   getdate(),      
  @BillingAddress,      
  @ShippingAddress,      
  @DocumentID,      
  @POPrefix,      
  @CustomerID ,     
  @BrForumCode,    
  @SalesManName,    
  @SalesManID     
  )      
      
SELECT  @@IDENTITY      


