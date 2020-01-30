
CREATE PROCEDURE [sp_put_SODocHeader]
	(
	@SONumber [int],
	@SODate 	[datetime],
	 @VendorID 	[nvarchar](15),
	 @DeliveryDate 	[datetime],
	 @Value 	Decimal(18,6),
	 @creditterm 	[int],
	 @POReference 	[nvarchar](50),
	 @DocumentID	nvarchar(50),
	 @BillingAddress nvarchar(255),
	 @ShippingAddress nvarchar(255)
	)

AS 
DECLARE @Corrected_Code nvarchar(20)
DECLARE @OriginalID nvarchar(20)

select @OriginalID = VendorID FROM Vendors WHERE AlternateCode = @VendorID
SET @Corrected_Code = ISNULL(@OriginalID, @VendorID)
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
	(@SONumber,
	@SODate,
	 @Corrected_Code,
	 @DeliveryDate,
	 @Value,
	 getdate(),
	 @creditterm,
	 @POReference,
	 @DocumentID,
	 @BillingAddress,
	 @ShippingAddress,
	 @VendorID
	)

SELECT @@Identity

