CREATE procedure [dbo].[spc_brands]
AS
select BrandName, Manufacturer_Name, Brand.Active
FROM Brand, Manufacturer
WHERE Brand.ManufacturerID *= Manufacturer.ManufacturerID
