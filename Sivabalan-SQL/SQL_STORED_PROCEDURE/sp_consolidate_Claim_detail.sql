CREATE PROCEDURE sp_consolidate_Claim_detail(@ClaimID INT, 
			  		     @AlternateCode nvarchar(15),
			  		     @Quantity Decimal(18,6), 
			  		     @Rate Decimal(18,6),
					     @Remarks nvarchar(255),
					     @BatchNumber nvarchar(128),
			  		     @Expiry datetime,
			  		     @PurchasePrice Decimal(18,6),
					     @SchemeType int)
AS 
Declare @ItemCode nvarchar(20)

Select @ItemCode = Product_Code From Items Where Alias = @AlternateCode
INSERT INTO ClaimsDetail (ClaimID, 
		Product_Code, 
		Quantity, 
		Rate,
		Remarks,
		Batch,
		Expiry,
		PurchasePrice,
		SchemeType)
VALUES		
		(@ClaimID,
		@ItemCode, 
		@Quantity, 
		@Rate, 
		@Remarks,
		@BatchNumber,
		@Expiry,
		@PurchasePrice,
		@SchemeType)
