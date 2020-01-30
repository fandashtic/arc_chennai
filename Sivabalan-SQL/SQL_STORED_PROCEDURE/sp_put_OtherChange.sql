
CREATE PROCEDURE [sp_put_OtherChange]
	(
	@NotificationType 	[nvarchar](25),
	 @DocumentDate 	[datetime],
	@CompanyID 	[nvarchar](15),	 
	@Information	[nvarchar](255)
	)

AS INSERT INTO [CatalogNotification] 
	 ( 
	 [NotificationType],
	 [DocumentDate],
	[CompanyID],
	 [Information]
	) 
 
VALUES 
	(
	@NotificationType, 
	@DocumentDate,
	  @CompanyID,	
	@information
	)





