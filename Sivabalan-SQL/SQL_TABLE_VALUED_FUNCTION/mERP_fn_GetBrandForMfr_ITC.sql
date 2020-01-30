Create Function mERP_fn_GetBrandForMfr_ITC(@Mfr nVarchar(4000))
Returns @BrandID Table (BrandID int)
As
Begin
Declare @Delimeter as Char(1)      
Set @Delimeter = Char(44)      

if @Mfr = '%%'
Insert InTo @BrandID Select BrandID from Brand
Else
Insert InTo @BrandID Select BrandID from Brand 
Where ManufacturerID in (Select ManufacturerID from Manufacturer 
Where Manufacturer_Name in (Select * from dbo.sp_SplitIn2Rows(@Mfr,@Delimeter)))

Return
End
