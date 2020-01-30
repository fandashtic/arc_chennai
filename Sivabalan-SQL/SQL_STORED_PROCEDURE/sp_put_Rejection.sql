
CREATE PROCEDURE [sp_put_Rejection]
	(
	 @NotificationType 	[nvarchar](50),
	@DocumentType	[nvarchar](25),
	@DocumentNumber	[nvarchar](50),
	 @DocumentDate 	[datetime],
	@CompanyID	[nvarchar](25),
	 @information 	[nvarchar](255)
	)

AS INSERT INTO [CatalogNotification] 
	 (
	 [NotificationType],
	 [DocumentType],
	 [DocumentID],
	 [DocumentDate],
	[CompanyID],
	 [Information]
	) 
 VALUES 
	(
	 @NotificationType,
	 @DocumentType,
	 @DocumentNumber,
	 @DocumentDate ,
	 @CompanyID,
	 @information
	 )


