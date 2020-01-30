CREATE Procedure sp_get_RecItemMfrBrand_Info_ITC
(@ID Int,@Permission int)
As  
Declare @MfrID Int
Declare @BrandID Int
Declare @OrgMfrID int
declare @Mfr_Name nVarchar(255)
Declare @MfrCode nVarChar(255)
Declare @BrandName nVarChar(255)
Declare @ChkBrand int

Select @MfrID = ManufacturerID From Manufacturer  
Where Manufacturer_Name = (Select ManufacturerName From ItemsReceivedDetail  
Where ID = @ID)

Select @BrandID = BrandID,@OrgMfrID = ManufacturerID From Brand  
Where BrandName = (Select BrandName From ItemsReceivedDetail Where ID = @ID)

Select @Mfr_Name= ManufacturerName, @MfrCode = ManufacturerCode, @BrandName = BrandName
from ItemsReceivedDetail Where ID = @ID

IF @Permission =1
Begin
	If isNull(@MfrID,0) = 0 
	Begin  
		INSERT INTO [Manufacturer]([Manufacturer_Name], manufacturercode)
		VALUES (@Mfr_Name,@MfrCode)
		Select @MfrID=@@identity
	End
	If isNull(@OrgMfrID,0) <> isNull(@mfrID,0)
	Begin
		Set @ChkBrand = 0
		if isNull(@BrandID,0) > 0
		Begin
			Select @ChkBrand = BrandID From Brand Where BrandName = @Mfr_Name + '-' + @BrandName
			if isNull(@ChkBrand,0) > 0
			Begin
				Set @BrandID = isNull(@ChkBrand,0)
			End
			Else
			Begin	
				Set @BrandName = @Mfr_Name + '-' + @BrandName
				INSERT INTO [Brand]([BrandName],[ManufacturerID])   
				VALUES(@BrandName,@MfrID)
				SELECT @BrandID = @@IDENTITY
			End
		End
		Else
		Begin
			INSERT INTO [Brand]([BrandName],[ManufacturerID])   
			VALUES(@BrandName,@MfrID)
			SELECT @BrandID = @@IDENTITY
		End		
	End
End
Select IsNull(@MfrID, 0), IsNull(@BrandID, 0)
