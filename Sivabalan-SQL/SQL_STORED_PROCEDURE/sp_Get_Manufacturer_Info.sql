CREATE Procedure sp_Get_Manufacturer_Info (@ID Int)
As
Declare @MfrID Int
Declare @BrandID Int

Select @MfrID = ManufacturerID From Manufacturer
Where Manufacturer_Name = (Select ManufacturerName From ItemsReceivedDetail
Where ID = @ID)

Select @BrandID = BrandID From Brand
Where BrandName = (Select BrandName From ItemsReceivedDetail Where ID = @ID)

Select IsNull(@MfrID, 0), IsNull(@BrandID, 0), ManufacturerName, ManufacturerCode,
BrandName From ItemsReceivedDetail Where ID = @ID
