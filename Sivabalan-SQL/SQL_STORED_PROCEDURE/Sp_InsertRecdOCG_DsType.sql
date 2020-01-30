Create Procedure Sp_InsertRecdOCG_DsType(@RecdID Int,@DSTypeCode Nvarchar(15),@DSType Nvarchar(50),@Active Int,@ReportFlag int,@Flag int)
As  
Begin  
	SET DATEFORMAT DMY
	Insert Into Recd_DSType (RecdID,DSTypeCode,DSType,Active,ReportFlag,Status,CreationDate,Flag)
	Values(@RecdID,@DSTypeCode,@DSType,@Active,@ReportFlag,0,Getdate(),@Flag)
End  
