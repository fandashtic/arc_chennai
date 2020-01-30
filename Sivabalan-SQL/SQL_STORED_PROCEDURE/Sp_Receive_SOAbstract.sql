CREATE Procedure Sp_Receive_SOAbstract(  
	@Soid Nvarchar(50),
	@CompId Nvarchar(15), -- gCompanyFromID
	@CustomerID Nvarchar(25),
	@BillToAddress Nvarchar(255),
	@ShipToAddress Nvarchar(255),
	@Amount Decimal(18,6),
	@SODate DateTime, 
	@RequiredDate DateTime, 
	@Custom2 Int, -- Creditterm
	@Custom4 Int,
	@Custom5 int, -- Branch Tag
	@Custom6 nVarchar(50), --Szreference
	@Custom15 Nvarchar(200)= null) -- Salesman Name
AS           
  
	if @Custom5 = 1   
		begin  
			DECLARE @Corrected_Code nvarchar(20)          
			DECLARE @OriginalID nvarchar(20)          
			DECLARE @POPrefix nvarchar(20)        
			DECLARE @SalesManID int        
          
			select @OriginalID = CustomerID FROM Customer WHERE AlternateCode = @CustomerID          
			SET @Corrected_Code = ISNULL(@OriginalID, @CustomerID)          
			select @POPrefix = isnull(prefix,'') from voucherprefix where TranID = 'purchase order'        
        
				if not isnull(@Custom15,'') = ''       
					begin        
						Select @SalesManID=SalesManID from SalesMan where SalesMan_Name = @Custom15        
							if isnull(@salesManId,0) = 0         
								begin        
									insert into salesman (Salesman_Name,CreationDate,Active) Values(@Custom15, getdate(),1)        
									set @SalesManID = @@IDENTITY        
							end        
				end        
	Else    
		begin    
			set @SalesManID = 0    
			set @Custom15 = ''    
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
  @Custom4,--@SOID,  --@Custom4,         
  @SODate,          
  @Corrected_Code,          
  @RequiredDate,          
  @Amount,          
  getdate(),          
  @BILLTOADDRESS,          
  @SHIPTOADDRESS,          
  @Custom4,--  @SOID,          
  @POPrefix,          
  @CustomerID ,         
  @CompId,        
  @Custom15,        
  @SalesManID         
  )          
          
SELECT  @@IDENTITY          
end  
  
else  
  
begin  
DECLARE @Corrected_Code1 nvarchar(20)    
DECLARE @OriginalID1 nvarchar(20)    
    
select @OriginalID1 = VendorID FROM Vendors WHERE AlternateCode = @CompId  
SET @Corrected_Code1 = ISNULL(@OriginalID1, @CompId)    
INSERT INTO [SOAbstractReceived]     
  ([RefNumber],    
  [SODate],    
  [VendorID],    
  [DeliveryDate],    
  [Value],    
  [CreationTime],    
  [creditterm],    
  [POReference],    
  [DocumentID],    
  [BillingAddress],    
  [ShippingAddress],    
  [ForumCode]    
 )     
VALUES     
 (@Custom4,--@SOID,    --@Custom4, -- szserialnumber  In VB  
  @SODate,    
  @Corrected_Code1,    
  @RequiredDate,  
  @Amount,    
  getdate(),    
  @Custom2,  -- Credit Term  
  @Custom6,  -- reference  
  @Custom4, --@SOID,    
  @BillToAddress,    
  @ShipToAddress,    
  @CompId  
 )    
    
SELECT @@Identity  
  
end  



