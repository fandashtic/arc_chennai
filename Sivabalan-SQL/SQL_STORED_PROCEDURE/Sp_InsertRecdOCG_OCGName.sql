Create Procedure Sp_InsertRecdOCG_OCGName(@RecdID Int,@OCGCode Nvarchar(15),@OCGName Nvarchar(50),@Active Int)
As  
Begin  
	SET DATEFORMAT DMY
	Insert Into Recd_OCGName (RecdID,OCGCode,OCGName,Active,Status,CreationDate)
	Values(@RecdID,@OCGCode,@OCGName,@Active,0,Getdate())
End  
