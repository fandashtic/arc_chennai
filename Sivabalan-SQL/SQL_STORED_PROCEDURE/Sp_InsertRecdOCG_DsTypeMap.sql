Create Procedure Sp_InsertRecdOCG_DsTypeMap(@RecdID Int,@DSTypeCode Nvarchar(15),@OCGCode Nvarchar(15),@Active Int)
As  
Begin  
	SET DATEFORMAT DMY
	Insert Into Recd_OCG_DSType (RecdID,DSTypeCode,OCGCode,Active,Status,CreationDate)
	Values(@RecdID,@DSTypeCode,@OCGCode,@Active,0,Getdate())
End  
