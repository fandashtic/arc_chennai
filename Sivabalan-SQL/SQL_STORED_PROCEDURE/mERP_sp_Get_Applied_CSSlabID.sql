Create Procedure mERP_sp_Get_Applied_CSSlabID(@InvoiceID Int, @SchemeID Int, @ApplicableOn Int, @ItemGroup Int)
As
Begin
  Declare @TblTmpSch Table(SchemeInfo nVarchar(510) Collate SQL_Latin1_General_CP1_CI_AS, SlabInfo nVarchar(2000) Collate SQL_Latin1_General_CP1_CI_AS)
  Declare @TblTmpSlab Table(SlabInfo nVarchar(2000) Collate SQL_Latin1_General_CP1_CI_AS)
  Declare @SchemesList nVarchar(510)
  Declare @SchSlabList nVarchar(4000)
  Declare @SchCnt Int
  Declare @Delimeter Char(1)
  Set @Delimeter = Char(15)
  	
  IF @ApplicableOn = 1 And @ItemGroup = 1 /*SKU Schemes*/
    Insert into @TblTmpSch
    Select IsNull(MultipleSchemeID,N''), MultipleSchemeDetails From InvoiceDetail 
    Where InvoiceID = @InvoiceID And IsNull(MultipleSchemeID,N'') <> N''
  Else If @ApplicableOn = 1 And @ItemGroup = 2 /*SplCat Schemes*/
    Insert into @TblTmpSch
    Select IsNull(MultipleSplCatSchemeID,N''), MultipleSplCategorySchDetail  From InvoiceDetail 
    Where InvoiceID = @InvoiceID And IsNull(MultipleSplCatSchemeID,N'') <> N''
  Else If @ApplicableOn = 2 And @ItemGroup = 1 /*Invoice Schemes*/
    Insert into @TblTmpSch
    Select IsNull(InvoiceSchemeID,N''), MultipleSchemeDetails From InvoiceAbstract 
    Where InvoiceID = @InvoiceID And IsNull(InvoiceSchemeID,N'') <> N''
 
  Declare Cur_SlabInfo Cursor For
  SELECT Distinct SchemeInfo, SlabInfo From @TblTmpSch Where IsNull(SlabInfo,'') <> ''
  Open Cur_SlabInfo
  Fetch Next From Cur_SlabInfo Into @SchemesList, @SchSlabList 
  While (@@Fetch_Status = 0)
  Begin
    If CharIndex(N',',@SchemesList) > 0
    Begin
	  Insert into @TblTmpSlab 
      Select * from dbo.sp_SplitIn2Rows(@SchSlabList,@Delimeter)    
    End
    Else
    Begin
      Insert into @TblTmpSlab Values(@SchSlabList)
    End
    Fetch Next From Cur_SlabInfo Into @SchemesList, @SchSlabList 
  End
  Close Cur_SlabInfo
  Deallocate Cur_SlabInfo
  
  Select Left(SubString(SlabInfo,CharIndex(N'|',SlabInfo)+1,Len(SlabInfo)),(CharIndex(N'|',SubString(SlabInfo,CharIndex(N'|',SlabInfo)+1,Len(SlabInfo))))-1)
  From @TblTmpSlab 
  Where CAST(Left(SlabInfo, (CharIndex(N'|',SlabInfo))-1) as INT) = @SchemeID
End

