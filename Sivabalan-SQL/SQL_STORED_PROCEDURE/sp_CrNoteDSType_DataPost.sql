Create Procedure sp_CrNoteDSType_DataPost(@CrNoteID Int,@CrNoteType Int)
As
Begin

Create Table #tmpCatList(Divitions nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
Create Table #UniqueCatList(Divitions nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
If @CrNoteType = 1 --CLO Credit Notes
Begin		
	Declare @Cats as nVarchar(255)
	Set @Cats = ''
	
	Select @Cats=Max(Category) From CLOCrNote CLO Where CLO.CreditID = @CrNoteID	
	
	Truncate Table #tmpCatList
	
	Insert Into #tmpCatList (Divitions)
	Select Distinct ItemValue From dbo.sp_SplitIn2Rows(@Cats ,'|' )	
End
Else If @CrNoteType = 2 --QPS CreditNotes
Begin	
	Truncate Table #tmpCatList		
	
	Insert Into #tmpCatList (Divitions)
	Select Distinct SCS.Category 	
	From CreditNote CR
	Join  tbl_mERP_SchemePayoutPeriod SP On SP.ID = CR.PayoutID 
	Join tbl_mERP_SchemeAbstract SA On SA.SchemeID = SP.SchemeID And SA.SchemeType in (1,2)
	Join tbl_mERP_SchCategoryScope SCS on SCS.SchemeID = SA.SchemeID 
	Where CR.CreditID  = @CrNoteID And IsNull(Flag,0) = 1	
End
Else If @CrNoteType = 3  --Display Scheme CreditNotes
Begin
	Truncate Table #tmpCatList	
	
	Insert Into #tmpCatList (Divitions)
	Select Distinct DSC.Category
	From CreditNote CR
	Join  tbl_mERP_SchemePayoutPeriod SP On SP.ID = CR.PayoutID 
	Join tbl_mERP_SchemeAbstract SA On SA.SchemeID = SP.SchemeID And SA.SchemeType in (3)
	Join tbl_mERP_Display_SchCategory DSC on DSC.SchemeID = SA.SchemeID 
	Where CR.CreditID  = @CrNoteID And IsNull(Flag,0) = 1	
End
	
Insert Into #UniqueCatList(Divitions)
Select Distinct Divitions  From #tmpCatList where IsNull(Divitions,'') <> '' 

IF (Select count(Divitions) From #UniqueCatList) = 0
GoTo NoPost

IF Not Exists(Select 'x' From CrNoteDSType Where CreditID = @CrNoteID) 
Begin
	Declare @OCG int
	Select @OCG=isnull(Flag,0) From Tbl_merp_Configabstract Where ScreenCode = 'OCGDS' And ScreenName ='OperationalCategoryGroup'	
	If @OCG = 1
	Begin
		Insert Into CrNoteDSType (DSTypeID,CreditID,CreditNoteType)
		Select Distinct DSM.DSTypeId, CreditID=@CrNoteID, CreditNoteType=@CrNoteType 
		From DSType_Master DSM
		Join tbl_mERP_DSTypeCGMapping Map On Map.DSTypeID = DSM.DSTypeId And Map.Active = 1
		Join ProductCategoryGroupAbstract PCGA On PCGA .GroupId = Map.GroupID  And PCGA.Active = 1 And IsNull(PCGA.OCGType,0) = 1 
		Join OCGItemMaster OCGP On OCGP.GroupName  = PCGA.GroupName And OCGP.Exclusion = 0 
		Join #UniqueCatList Div On Div.Divitions = OCGP.Division 
		Where  DSM.Active  = 1 And DSM.DSTypeCtlPos =1 And IsNull(DSM.OCGType ,0) = 1
		And DSM.DSTypeCode Not In (Select DSTypeCode From AutoAdjExcludeDSType Where Active = 1)
		Order By  DSM.DSTypeId
	End
	Else --@OCG = 0
	Begin
		Insert Into CrNoteDSType (DSTypeID,CreditID,CreditNoteType)
		Select Distinct DSM.DSTypeId, @CrNoteID, CreditNoteType=@CrNoteType 
		From DSType_Master DSM
		Join tbl_mERP_DSTypeCGMapping Map On Map.DSTypeID = DSM.DSTypeId And Map.Active = 1
		Join ProductCategoryGroupAbstract PCGA On PCGA .GroupId = Map.GroupID  And PCGA.Active = 1
		Join tblCGDivMapping DivMap On DivMap.CategoryGroup   = PCGA.GroupName
		Join #UniqueCatList Div On Div.Divitions = DivMap.Division 
		Where  DSM.Active  = 1 And DSM.DSTypeCtlPos =1
		And DSM.DSTypeCode Not In (Select DSTypeCode From AutoAdjExcludeDSType Where Active = 1)
		Order By  DSM.DSTypeId
	End
End

NoPost:

End
