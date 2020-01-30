
CREATE PROCEDURE [sp_put_PODocHeader]
	(
	@POReference 	[int],
	 @PODate 	[datetime],
	 @CustomerID 	[nvarchar](15),
	 @RequiredDate 	[datetime],
	 @Value 		Decimal(18,6),
	 @BillingAddress 	[nvarchar](255),
	 @ShippingAddress 	[nvarchar](255),
	 @DocumentID		int,
	 @POPrefix	[nvarchar] (50)
	)

AS 
DECLARE @Corrected_Code nvarchar(20)
DECLARE @OriginalID nvarchar(20)

select @OriginalID = CustomerID FROM Customer WHERE AlternateCode = @CustomerID
SET @Corrected_Code = ISNULL(@OriginalID, @CustomerID)
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
	 ForumCode
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
	 @CustomerID
	 )

SELECT  @@IDENTITY;

