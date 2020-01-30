Create Procedure Sp_InsertRecdOCG_ProductMap(@RecdID Int,@OCGCode Nvarchar(15),@ProductCategoryName Nvarchar(255),@Level Int,@Exclusion Int)
As  
Begin  
	SET DATEFORMAT DMY
	Insert Into Recd_OCG_Product (RecdID,OCGCode,ProductCategoryName,Level,Exclusion,Status,CreationDate)
	Values(@RecdID,@OCGCode,@ProductCategoryName,@Level,@Exclusion,0,Getdate())
End  
