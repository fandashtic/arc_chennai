CREATE Procedure Sp_Receive_SOAbstract_MUOM_Pidilite(  
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
	@Custom6 nVarchar(50) --Szreference
)
AS           
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
 (@Custom4,
  @SODate,    
  @Corrected_Code1,    
  @RequiredDate,  
  @Amount,    
  getdate(),    
  @Custom2,
  @Custom6,
  @Custom4,
  @BillToAddress,    
  @ShipToAddress,    
  @CompId  
 )    
    
SELECT @@Identity  
