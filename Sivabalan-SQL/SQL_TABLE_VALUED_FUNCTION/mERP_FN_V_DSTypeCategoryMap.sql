Create Function mERP_FN_V_DSTypeCategoryMap()
Returns @TmpOutput Table (DSID int, DSType nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
		SKUCode nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS, PortFolio nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
		Flag int)
BEGIN

	Declare @OCGFlag int
	Set @OCGFlag = (Select Top 1 isnull(Flag,0) From tbl_Merp_ConfigAbstract Where ScreenCode = 'OCGDS')

	Declare @CurrentDate Datetime
	Set @CurrentDate = dbo.StripTimeFromDate(Cast(GetDate() as Datetime))

	Declare @TmpDSType as Table(SalesmanID int, DSTypeCode nvarchar(25) COLLATE SQL_Latin1_General_CP1_CI_AS, DSTypeID int,
		DSType nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Flag int)

	IF EXISTS (Select 'x' From HHViewLog Where dbo.StripTimeFromDate(Date) = @CurrentDate)
		Insert Into @TmpOutput(DSID, DSType, SKUCode, PortFolio, Flag)		
		Select DSID, DSType, SKUCode, PortFolio, Flag from TmpDSTypeCategoryMap
	ELSE
		Begin
			IF @OCGFlag = 1
				Begin					
					Insert Into @TmpDSType(SalesmanID, DSTypeCode, DSTypeID, DSType, Flag)
					Select DD.SalesmanID, DM.DstypeCode, DM.DSTypeID, DM.DSTypeValue, DM.Flag
					From DSType_Details DD 
						Inner Join DSType_Master DM On DD.DSTypeID = DM.DSTypeID and isnull(DM.Flag,0) <> 0
						Inner Join Salesman S On S.SalesmanID = DD.SalesmanID
					Where DD.Dstypectlpos = 1 And Isnull(DD.SalesmanID,0) <> 0 
						And isnull(S.Active,0) <> 0 And isnull(OCGType,0) = 1
						And DD.SalesmanID In 
							(Select DD1.SalesmanID From DSType_Details DD1 
								Inner Join DSType_Master DM1 On DD1.DSTypeID = DM1.DSTypeID
								And DM1.DSTypeName = 'Handheld DS' And DM1.DSTypeValue = 'Yes' )

					Insert Into @TmpOutput(DSID, DSType, SKUCode, PortFolio, Flag)
					Select Tmp.SalesmanID, Tmp.DSType, SKU.System_SKU, isnull(Map.PortFolio,'') PortFolio, Tmp.Flag From @TmpDSType Tmp
						Inner Join OCG_DSTypeCategoryMap Map On Tmp.DSTypeID = Map.DSTypeID
						Inner Join DSTypeWiseSKU SKU On SKU.CatMapID = Map.ID
					Order By Tmp.SalesmanID, Tmp.DSType, SKU.System_SKU

				End

			ELSE
			Begin
				Insert Into @TmpDSType(SalesmanID, DSTypeCode, DSTypeID, DSType, Flag)
				Select DD.SalesmanID, DM.DstypeCode, DM.DSTypeID, DM.DSTypeValue, DM.Flag
				From DSType_Details DD 
					Inner Join DSType_Master DM On DD.DSTypeID = DM.DSTypeID and isnull(DM.Flag,0) <> 0
					Inner Join Salesman S On S.SalesmanID = DD.SalesmanID
				Where DD.Dstypectlpos = 1 And Isnull(DD.SalesmanID,0) <> 0 And isnull(S.Active,0) <> 0 
					And DD.SalesmanID In 
						(Select DD1.SalesmanID From DSType_Details DD1 
							Inner Join DSType_Master DM1 On DD1.DSTypeID = DM1.DSTypeID
							And DM1.DSTypeName = 'Handheld DS' And DM1.DSTypeValue = 'Yes' )

				Insert Into @TmpOutput(DSID, DSType, SKUCode, PortFolio, Flag)
				Select Tmp.SalesmanID, Tmp.DSType, SKU.System_SKU, isnull(Map.PortFolio,'') PortFolio, Tmp.Flag From @TmpDSType Tmp
					Inner Join DSTypeCGCategoryMap Map	On Tmp.DSTypeID = Map.DSTypeID
					Inner Join DSTypeWiseSKU SKU On SKU.CatMapID = Map.ID
				Order By Tmp.SalesmanID, Tmp.DSType, SKU.System_SKU

			End
		End
	Return
END
