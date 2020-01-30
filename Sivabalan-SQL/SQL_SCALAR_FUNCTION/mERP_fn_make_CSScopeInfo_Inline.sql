Create function mERP_fn_make_CSScopeInfo_Inline(@SchemeID Int, @ScopeType Int, @Level Int, @GroupID Int = 0)
Returns nVarchar(4000)
As
Begin

Declare @tblTemp Table (ScopeValue nVarchar(255)  COLLATE SQL_Latin1_General_CP1_CI_AS)
IF @ScopeType = 1 /*Customer Scope*/
  Begin
  If @Level = 1 
      Insert into @tblTemp Select Channel From tbl_mERP_SchemeChannel Where SchemeId = @SchemeID And GroupID = @GroupID 
  Else If @Level = 2
    Insert into @tblTemp Select OutletClass From tbl_mERP_SchemeOutletClass Where SchemeId = @SchemeID And GroupID = @GroupID 
  Else If @Level = 3
    Insert into @tblTemp Select OutletID From tbl_mERP_SchemeOutlet Where SchemeId = @SchemeID And GroupID = @GroupID 
  End 
Else IF @ScopeType = 2 /*Product Scope*/
  Begin
  If @Level = 1 
    Insert into @tblTemp Select Category From tbl_mERP_SchCategoryScope Where SchemeID = @SchemeID
  Else If @Level = 2
    Insert into @tblTemp Select SubCategory From tbl_mERP_SchSubCategoryScope Where SchemeID = @SchemeID
  Else If @Level = 3
    Insert into @tblTemp Select MarketSKU From tbl_mERP_SchMarketSKUScope Where SchemeID = @SchemeID
  Else If @Level = 4
    Insert into @tblTemp Select SKUCode From tbl_mERP_SchSKUCodeScope Where SchemeID = @SchemeID
  End

Declare @ReturnValue nVarchar(4000)
SET @ReturnValue = ''
Declare @ScopeValue  nVarchar(255)
Declare CurScopeValue Cursor For
Select IsNull(ScopeValue,'') From @tblTemp Order by 1 
Open CurScopeValue
Fetch Next From CurScopeValue Into @ScopeValue
While(@@fetch_status=0)        
  Begin
    Set @ReturnValue = @ReturnValue + @ScopeValue + '|'
  Fetch Next From CurScopeValue Into @ScopeValue
  End
Close CurScopeValue
Deallocate CurScopeValue 

SET @ReturnValue = SubString(@ReturnValue, 1, Len(@ReturnValue)-1)

Return @ReturnValue
End 

