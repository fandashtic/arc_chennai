Create Proc sp_Scheme_Item_Log(@SchemeID_ItemCode Nvarchar(15),@Type Nvarchar(5),@SubType Nvarchar(3) = 'N')
AS
Begin
	If @Type = 'SCH'
	Begin 
		Insert into SchemeProducts_log (Act_ProductCode,[Type]) Values (@SchemeID_ItemCode,1)
    	End  
    	Else
	Begin
		if @SubType = 'N' 
			Insert into SchemeProducts_log (Act_ProductCode,[Type],[IsNewItem]) Values  							(@SchemeID_ItemCode,2,1)
		Else
			Insert into SchemeProducts_log (Act_ProductCode,[Type],[IsNewItem]) Values  							(@SchemeID_ItemCode,2,0)
    	End 
	Select 1,'Done' 	
End 
