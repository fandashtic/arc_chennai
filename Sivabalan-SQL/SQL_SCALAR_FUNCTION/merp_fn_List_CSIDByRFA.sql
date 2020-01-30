Create function dbo.merp_fn_List_CSIDByRFA(@SchemeList nVarchar(510),@RFAClaimable nVarchar(5) = 'Both')
Returns nVarchar(510)
As
Begin
  Declare @RFAValue Int
  Declare @SchemeID Int  
  Declare @RFASchemeList nVarchar(510)
  Set @RFASchemeList = ''

  IF @RFAClaimable = 'Yes'
    Set @RFAValue = 1 
  Else If @RFAClaimable = 'No'
    Set @RFAValue = 0

  If @RFAClaimable = 'Both'
  Begin
    Declare CutSchemeList Cursor For
    Select SchemeId From tbl_mERP_schemeAbstract Where SchemeID in (select * from dbo.sp_SplitIn2Rows(@SchemeList,','))
  End
  Else
  Begin
    Declare CutSchemeList Cursor For
    Select SchemeId From tbl_mERP_schemeAbstract Where SchemeID in (select * from dbo.sp_SplitIn2Rows(@SchemeList,','))
     And RFAApplicable = @RFAValue
  End 
  Open CutSchemeList
  Fetch Next From CutSchemeList Into @SchemeID
  While (@@Fetch_Status) = 0
  Begin
    Set @RFASchemeList = @RFASchemeList + Cast(@SchemeID as nVarchar(10))+ ','
    Fetch Next From CutSchemeList Into @SchemeID 
  End
  Close CutSchemeList
  Deallocate CutSchemeList

  If CharIndex(',',@RFASchemeList) > 0
  Begin
    Set @RFASchemeList = SubString(@RFASchemeList,1,Len(@RFASchemeList)-1)
  End 
  Return @RFASchemeList
End 

