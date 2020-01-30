Create Procedure mERP_sp_view_Applied_CSAbstract (@InvoiceID Int)
As
Declare @tblTmp as table (CSID Int)
Declare @SchemesList Varchar(550)  
Begin
  /* To get the Invoice Level Schemes */
  Select @SchemesList = IsNull(InvoiceSchemeID,'') From InvoiceAbstract where InvoiceID = @InvoiceID
  /* To get the Multiple Schemes & Spl Category Schemes */
  Declare @TblMultipleSchemes Table (SchemeList nVarchar(550) Collate SQL_Latin1_General_CP1_CI_AS)
  Declare @TblSchemes Table (SchemeID Int)
  Insert Into @TblMultipleSchemes
  Select IsNull(MultipleSchemeID,'') From InvoiceDetail where InvoiceID = @InvoiceID And IsNull(MultipleSchemeID,'') <> ''
   Union
  Select IsNull(MultipleSplCatSchemeID,'') From InvoiceDetail where InvoiceID = @InvoiceID And IsNull(MultipleSplCatSchemeID,'') <> ''
  Declare @SchemesApplied nVarchar(550)
  Declare CurMultSchemes Cursor For
  Select SchemeList From @TblMultipleSchemes
  Open CurMultSchemes
  Fetch Next From CurMultSchemes into @SchemesApplied
  While (@@Fetch_status) = 0 
  Begin
    Insert into @TblSchemes Select * from dbo.sp_SplitIn2Rows(@SchemesApplied,',')
    Fetch Next From CurMultSchemes into @SchemesApplied
  End
  Close CurMultSchemes
  Deallocate CurMultSchemes
  /* Grouping all Schemes Applied */
  Insert into @tblTmp 
  select ItemValue as 'InvoiceSchemeID' from dbo.sp_SplitIn2Rows(@SchemesList,',')
  Union  
  Select Distinct SchemeID From InvoiceDetail Where InvoiceID = @InvoiceID
  Union
  Select Distinct SplCatSchemeID From InvoiceDetail Where InvoiceID = @InvoiceID
  Union 
  Select Distinct SchemeID From @TblSchemes
  /* Display the Schemes Applied */
  Select CSabs.SchemeID, CSabs.CS_RecSchID, CSabs.ActivityCode, CSabs.Description, CSabs.ActiveFrom, CSabs.ActiveTo, CSAppType.ApplicableOn, CSIGrp.ItemGroup, 
  CSabs.ApplicableOn, CSAbs.ItemGroup From @tblTmp tmp, tbl_mERP_SchemeAbstract CSAbs, tbl_mERP_SchemeItemGroup CSIGrp, tbl_mERP_SchemeApplicableType CSAppType
  Where CSabs.SchemeID = tmp.CSID And 
	CSabs.SChemeType in (1,2) and
    CSabs.ApplicableOn = CSAppType.ID And 
    CSAbs.ItemGroup = CSIGrp.ID And 
    tmp.CSID > 0 
  Order By CSabs.SchemeID

End
