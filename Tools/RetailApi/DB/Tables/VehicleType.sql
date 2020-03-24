IF EXISTS(SELECT Top 1 1 FROM sys.objects WHERE Name = N'VehicleType')
BEGIN
	DROP TABLE VehicleType
END
GO
Create Table VehicleType
(
	VehicleTypeId int Identity(1,1),
	VehicleType Nvarchar(255) not Null,
	IsActive int Default 1,
	CreatedOn DateTime Default Getdate(),
	CreatedBy int,
	ModifiedOn DateTime Default Getdate(),
	ModifiedBy int
)
GO
