Create Procedure mERP_SP_LoadDivision_HeatMap @DSTypeID int
AS
BEGIN
	/* For NON OCG*/
	If (select isnull(OCGType,0) from dstype_master where DSTypeID=@DSTypeID)=0
	Begin
		SELECT CategoryID,Category_Name FROM ItemCategories 
		WHERE 1 = 1  
		AND ACTIVE = 1 
		And Level = 2 
		And Category_Name In 
		(Select Division From  tblcgdivmapping Where CategoryGroup In 
			(Select pcg.GroupName From tbl_mERP_DSTypeCGMapping dscg,ProductCategoryGroupAbstract pcg 
			Where dscg.GroupID = pcg.GroupID 
			And dscg.DSTypeID=@DSTypeID
			)
		) 
		Order By Category_Name
	End
	Else
	Begin
		exec mERP_SP_getCategoryforOCG NULL,@DSTypeID,2
	End
END
