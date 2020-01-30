CREATE PROCEDURE [sp_save_RedemptionAbstract]
	(@RedemptionType int,	 @DocumentID nvarchar(120),
	 @DocumentDate datetime,	 @CustomerID nvarchar(250),
	 @RedeemedPoints int,	 @RedeemedAmount decimal(18,6))
AS 

Begin Tran
	Update DocumentNumbers Set DocumentID =  DocumentID + 1 Where DocType = 35
	Select @DocumentID = DocumentID - 1 From DocumentNumbers Where DocType = 35
Commit Tran

INSERT INTO [RedemptionAbstract] 
	 ([RedemptionType],	 [DocumentID],	 [DocumentDate],	 [CustomerID],
	 [RedeemedPoints],	 [RedeemedAmount]) 
VALUES 
	( @RedemptionType, 	 @DocumentID,	 @DocumentDate,	  @CustomerID,
	 @RedeemedPoints,	 @RedeemedAmount)
select @@Identity,@DocumentID


