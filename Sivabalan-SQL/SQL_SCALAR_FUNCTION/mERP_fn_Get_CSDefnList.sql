Create Function dbo.mERP_fn_Get_CSDefnList(@SchemeDataLst nVarchar(500), @DefnType nVarchar(50), @SchRefDataList nVarchar(500) = '', @Count Int)
Returns nVarchar(4000)
As
Begin
  IF @Count = 0 
  Begin
    Set @Count = 1 
  End 
  Declare @CS_Desc nVarchar(1000)
  Declare @CS_DescList nVarchar(4000)
  
   Set @CS_DescList = ''
  IF @DefnType ='Scheme'
  Begin
    Declare @TempSchID Table (SchID Int)
    Insert into @TempSchID Select * from dbo.sp_SplitIn2Rows(@SchemeDatalst, ',')
    Declare CurSchDesc Cursor For
    Select Distinct Cs_RecSchID +'_'+ Description From tbl_merp_schemeAbstract, @TempSchID
    Where SchID = SchemeID
  End 
  Else if @DefnType ='Product'
  Begin
    Declare @TempPrdtCode Table (PrdtCode nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)
    Insert into @TempPrdtCode Select * from dbo.sp_SplitIn2Rows(@SchemeDatalst, '|')
    Declare CurSchDesc Cursor For
    Select ProductName From Items, @TempPrdtCode
    Where PrdtCode = Product_code
  End 
  Else if @DefnType ='UOM'
  Begin
    Declare @TempUOM Table (UOMID Decimal(18,2))
    Insert into @TempUOM Select * from dbo.sp_SplitIn2Rows(@SchemeDatalst, '|')
    Declare CurSchDesc Cursor For
    Select Description From UOM, @TempUOM
    Where Cast(UOMID as Int)= UOM
  End 
  Else if @DefnType ='Quantity'
  Begin
    Declare @TempProCode Table (RowID Int Identity, PrdtCode nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)
    Insert into @TempProCode Select * from dbo.sp_SplitIn2Rows(@SchRefDataList, '|')
    Declare @TempQty Table (RowID Int Identity, Qty Decimal(18,6))
    Insert into @TempQty Select * from dbo.sp_SplitIn2Rows(@SchemeDatalst, '|')
    Declare CurSchDesc Cursor For
    Select Cast((((Case IsNull(Qty,0) When 0 Then 0 Else Qty End) / (Case When IsNull(UOM2_Conversion,0) > 0 Then UOM2_Conversion Else 1 End)) * @Count) as Decimal(18,2))
    From Items, @TempProCode TmpPrdt, @TempQty TmpQty
    Where Product_code = PrdtCode And TmpPrdt.RowID = TmpQty.RowID
  End 
  Else if @DefnType ='Value'
  Begin
    Declare @Delimeter Char(1)
    Set @Delimeter = Char(15)
    Declare @Delimeter_1 Char(1)
    Set @Delimeter_1 = '|'
    Declare @TempSchValue Table (SchValue nVarchar(100))
    Declare @TempSchemeValue Table (SchValue nVarchar(100))
	Declare @TempSchemeValueSum Table (SchValue Decimal(18, 6))
    Declare @TempSchResult Table (SchValue Decimal(18,2))
    Insert into @TempSchValue Select * from dbo.sp_SplitIn2Rows(@SchemeDatalst, @Delimeter)
    Insert into @TempSchemeValue Select * from dbo.sp_SplitIn2Rows(@SchRefDataList, @Delimeter)

    Declare @SchVal nVarchar(4000)
	Declare @SchSum Decimal(18, 6)

	Insert Into @TempSchemeValueSum 
	Select dbo.fnToSum(SchValue, '|') from @TempSchemeValue 

    Insert into @TempSchResult
    Select Cast(SubString(SchValue,CharIndex(N'|',SchValue)+1,
	Case When CharIndex(N'|',SchValue, CharIndex(N'|',SchValue) + 1) > 0 Then 
		(CharIndex(N'|',SchValue, CharIndex(N'|',SchValue) + 1) - (CharIndex(N'|',SchValue) + 1)) Else Len(SchValue) End) as Decimal(18,2)) * (@Count)  From @TempSchValue
    Union ALL
	Select SchValue From @TempSchemeValueSum 
--    Select Cast(SubString(SchValue,CharIndex(N'|',SchValue)+1,
--	Case When CharIndex(N'|',SchValue, CharIndex(N'|',SchValue) + 1) > 0 Then 
--		(CharIndex(N'|',SchValue, CharIndex(N'|',SchValue) + 1) - (CharIndex(N'|',SchValue) + 1)) 
--Else Len(SchValue) End) as Decimal(18,2)) * (@Count)  From @TempSchemeValue


    Declare CurSchDesc Cursor For
    Select Cast(SchValue as nVarchar(50)) From @TempSchResult
  End 
  Open CurSchDesc
  Fetch Next From CurSchDesc Into @CS_Desc
  While @@Fetch_status = 0 
  Begin
    Set @CS_DescList = @CS_DescList + @CS_Desc + '|'
    Fetch Next From CurSchDesc Into @CS_Desc
  End
  Close CurSchDesc
  Deallocate CurSchDesc

  If CharIndex('|',@CS_DescList) > 0 
  Begin
  SEt @CS_DescList = SubString(@CS_DescList, 1, Len(@CS_DescList)-1)
  End 

  Return @CS_DescList
End

