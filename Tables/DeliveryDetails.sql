IF EXISTS(SELECT Top 1 1 FROM sys.objects WHERE Name = N'DeliveryDetails')
BEGIN
	DROP TABLE DeliveryDetails
END
GO
Create Table DeliveryDetails
(
	Id Int Identity(1,2),
	Date DateTime,
	CustomerID Nvarchar(255),
	InvoiceId int,
	Person Nvarchar(255),
	TruckNo Nvarchar(255),
	Status Int Default 0
)
GO