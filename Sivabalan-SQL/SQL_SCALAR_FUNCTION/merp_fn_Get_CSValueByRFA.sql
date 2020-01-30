Create function dbo.merp_fn_Get_CSValueByRFA(@SchemeSlabList nVarchar(2000),@RFAClaimable nVarchar(5) = 'No',@InvoiceID int=0,@Product_Code nvarchar(50)=null,@Serial int=0)
Returns nVarchar(1020)
As
Begin
  Declare @RFAValue Int
  Declare @Delimeter Char(1)
  Set @Delimeter = Char(15)
  Declare @TmpSchData Table (SchemeData nVarchar(510))
  Declare @SchemeID Int
  Declare @SchemeValue Decimal(18,6)
  Declare @SalePrice decimal(18,6)
  declare @ApplicableOn int
  Set @SchemeValue = 0
  declare @RFASchValueList nvarchar(2040)
  Set @RFASchValueList = ''
  IF @RFAClaimable = 'Yes'
  Begin
    Set @RFAValue = 1 
  End
  Else
  Begin
    Set @RFAValue = 0
  End

  Insert into @TmpSchData 
  Select * from dbo.sp_SplitIn2Rows(@SchemeSlabList, @Delimeter) Where ItemValue <> ''

  If @RFAClaimable = 'Both'
  Begin
	
    Declare CutSchemeList Cursor For
    Select CAST(Left(SchemeData, (CharIndex(N'|',SchemeData))-1) as INT) 'SchemeID',
    --Cast(Left((SubString((SubString(SchemeData,CharIndex(N'|',SchemeData)+1,Len(SchemeData))),(CharIndex('|',SubString(SchemeData,CharIndex(N'|',SchemeData)+1,Len(SchemeData)))+1), Len((SubString(SchemeData,CharIndex(N'|',SchemeData)+1,Len(SchemeData)))))),CharIndex('|',((SubString((SubString(SchemeData,CharIndex(N'|',SchemeData)+1,Len(SchemeData))),(CharIndex('|',SubString(SchemeData,CharIndex(N'|',SchemeData)+1,Len(SchemeData)))+1), Len((SubString(SchemeData,CharIndex(N'|',SchemeData)+1,Len(SchemeData))))))))-1) as Decimal(18,6)) 'SchValue'
    Cast(Substring(substring(substring(SchemeData,CharIndex(N'|',SchemeData)+1,len(SchemeData)),CharIndex(N'|',substring(SchemeData,CharIndex(N'|',SchemeData)+1,len(SchemeData)))+1,len(substring(SchemeData,CharIndex(N'|',SchemeData)+1,len(SchemeData)))),charindex(N'|',substring(substring(SchemeData,CharIndex(N'|',SchemeData)+1,len(SchemeData)),CharIndex(N'|',substring(SchemeData,CharIndex(N'|',SchemeData)+1,len(SchemeData)))+1,len(substring(SchemeData,CharIndex(N'|',SchemeData)+1,len(SchemeData)))))+1,len(substring(substring(SchemeData,CharIndex(N'|',SchemeData)+1,len(SchemeData)),CharIndex(N'|',substring(SchemeData,CharIndex(N'|',SchemeData)+1,len(SchemeData)))+1,len(substring(SchemeData,CharIndex(N'|',SchemeData)+1,len(SchemeData)))))) as decimal(18,6)) 'SchValue'
    from @TmpSchData
  End
  Else
  Begin
    Declare CutSchemeList Cursor For
    Select CAST(Left(SchemeData, (CharIndex(N'|',SchemeData))-1) as INT) 'SchemeID',
    --Cast(Left((SubString((SubString(SchemeData,CharIndex(N'|',SchemeData)+1,Len(SchemeData))),(CharIndex('|',SubString(SchemeData,CharIndex(N'|',SchemeData)+1,Len(SchemeData)))+1), Len((SubString(SchemeData,CharIndex(N'|',SchemeData)+1,Len(SchemeData)))))),CharIndex('|',((SubString((SubString(SchemeData,CharIndex(N'|',SchemeData)+1,Len(SchemeData))),(CharIndex('|',SubString(SchemeData,CharIndex(N'|',SchemeData)+1,Len(SchemeData)))+1), Len((SubString(SchemeData,CharIndex(N'|',SchemeData)+1,Len(SchemeData))))))))-1) as Decimal(18,6)) 'SchValue'
	Cast(Substring(substring(substring(SchemeData,CharIndex(N'|',SchemeData)+1,len(SchemeData)),CharIndex(N'|',substring(SchemeData,CharIndex(N'|',SchemeData)+1,len(SchemeData)))+1,len(substring(SchemeData,CharIndex(N'|',SchemeData)+1,len(SchemeData)))),charindex(N'|',substring(substring(SchemeData,CharIndex(N'|',SchemeData)+1,len(SchemeData)),CharIndex(N'|',substring(SchemeData,CharIndex(N'|',SchemeData)+1,len(SchemeData)))+1,len(substring(SchemeData,CharIndex(N'|',SchemeData)+1,len(SchemeData)))))+1,len(substring(substring(SchemeData,CharIndex(N'|',SchemeData)+1,len(SchemeData)),CharIndex(N'|',substring(SchemeData,CharIndex(N'|',SchemeData)+1,len(SchemeData)))+1,len(substring(SchemeData,CharIndex(N'|',SchemeData)+1,len(SchemeData)))))) as decimal(18,6)) 'SchValue'
    From @TmpSchData tmp, tbl_mERP_schemeAbstract SchAbs 
    Where CAST(Left(SchemeData, (CharIndex(N'|',SchemeData))-1) as INT) =  SchAbs.schemeID 
    And RFAApplicable = @RFAValue
  End 
  Open CutSchemeList
  Fetch Next From CutSchemeList Into @SchemeID, @SchemeValue
  While (@@Fetch_Status) = 0
  Begin
    IF @SchemeValue <> 0
    Begin
		If @InvoiceID > 0  and @Product_Code<>''
		Begin
			set @SchemeValue=(@SchemeValue/100)	
            select @ApplicableOn=ApplicableOn from tbl_mERP_SchemeAbstract where SchemeID=@SchemeID		
			if @ApplicableOn=1 
            Begin 
				select @SalePrice=sum((Quantity * SalePrice)) from InvoiceDetail 
				where InvoiceID=@InvoiceID and Product_Code=@Product_Code
                and serial=@Serial 
				and FlagWord=0
            End
            Else if @ApplicableOn=2
            Begin
               select @SalePrice=sum((Quantity * SalePrice)-DiscountValue) from InvoiceDetail 
				where InvoiceID=@InvoiceID and Product_Code=@Product_Code
				and serial=@Serial
				and FlagWord=0
            End
            Else
            Begin
                select @SalePrice=sum((Quantity * SalePrice)) from InvoiceDetail 
				where InvoiceID=@InvoiceID and Product_Code=@Product_Code
                and serial=@Serial
				and FlagWord=0
            End  
              
            set @SchemeValue=@SalePrice* @SchemeValue			
		End
		Set @RFASchValueList = @RFASchValueList + Cast(@SchemeID as nVarchar(10))+ '|' + Cast(@SchemeValue as nVarchar(25))+ Char(15)
    End 
    Fetch Next From CutSchemeList Into @SchemeID, @SchemeValue
  End
  Close CutSchemeList
  Deallocate CutSchemeList
  If CharIndex(Char(15),@RFASchValueList) > 0
  Begin
    Set @RFASchValueList = SubString(@RFASchValueList,1,Len(@RFASchValueList)-1)
  End 

Return @RFASchValueList
End
