Create Procedure SP_get_DSType_MKTplanner @SalesmanID int
AS
BEGIN
	IF(select Top 1 Isnull(Flag,0) Flag from tbl_merp_Configabstract where screenCode = 'OCGDS')  = 0
	Begin
		Select DSTypeID, DSTypeValue From DSType_Master Where DsTypeID     
		In (Select DSTypeID From DSType_Details Where SalesmanID = @SalesmanID)    
		And Active = 1 and isnull(DSTypeCtlPos , 0) = 1
		And isnull(OCGType,0)=0
	End
	Else
	Begin
		Select DSTypeID, DSTypeValue From DSType_Master Where DsTypeID     
		In (Select DSTypeID From DSType_Details Where SalesmanID = @SalesmanID)    
		And Active = 1 and isnull(DSTypeCtlPos , 0) = 1
		And isnull(OCGType,0)=1
	End
END
