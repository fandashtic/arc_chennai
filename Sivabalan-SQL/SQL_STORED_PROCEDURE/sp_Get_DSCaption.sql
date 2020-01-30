CREATE Procedure sp_Get_DSCaption  
As  
Begin  
--	If (Select Count(Distinct DSTypeName) From DStype_Master) = 6
-- 		Select Distinct DSTypeName From DSType_Master 
--	Else
--		select * from dstype_master where 1 = 2 

	Select ControlPos ,LabelName From DSTypeLabel

End 
