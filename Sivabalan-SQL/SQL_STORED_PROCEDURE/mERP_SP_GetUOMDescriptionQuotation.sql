Create Procedure mERP_SP_GetUOMDescriptionQuotation(@ItemCode nvarchar(100),@UOMID int)
As
Begin
	if @UOMID=1 
		select UOM.Description from Items,UOM where Product_Code=@ItemCode and UOM.UOM=Items.UOM2 and UOM.Active=1
	Else
		select UOM.Description from Items,UOM where Product_Code=@ItemCode and UOM.UOM=Items.UOM  and UOM.Active=1
End
