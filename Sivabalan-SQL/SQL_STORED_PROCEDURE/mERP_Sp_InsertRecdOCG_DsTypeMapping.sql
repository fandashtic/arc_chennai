Create Procedure mERP_Sp_InsertRecdOCG_DsTypeMapping(@RecdID Int,@DSTypeCode Nvarchar(25),@CategoryName Nvarchar(255),@Level int,@PortFolio Nvarchar(25))
As  
Begin  
	SET DATEFORMAT DMY
	Insert Into Recd_OCG_DSTypeCategoryMap (RecdID,DSTypeCode,CG_Name,Level,PortFolio,Status,CreationDate)
	Values(@RecdID,@DSTypeCode,@CategoryName,@Level,@PortFolio,0,Getdate())
End  
