CREATE Procedure mERP_sp_List_CSQPS_SchPayouts(@TransDate as Datetime, @FreeType Int, @SchStatus Int)    
AS    
Begin     
  Set Dateformat dmy    
  Declare @CLSDAY_FLAG Int  
  Declare @DAY_CLOSE DateTime 
  Declare @tblFreeType Table(SlabType Int)    

  /*To Check Day Close Date*/
  Select @CLSDAY_FLAG = IsNull(Flag,0) from tbl_mErp_ConfigAbstract where ScreenCode like N'CLSDAY01'
  Select @DAY_CLOSE = dbo.StripTimeFromDate(IsNull(LastInventoryUpload, 'Jan 01 1900')) From SetUp
  
  /*Slab Type*/  
  If @FreeType = 1    
    Begin    
    Insert into @tblFreeType Values(1)    
    Insert into @tblFreeType Values(2)    
    End    
  Else if @FreeType = 2     
    Begin    
    Insert into @tblFreeType Values(3)    
    End    
  Else IF @FreeType = 3     
    Begin    
    Insert into @tblFreeType Values(1)    
    Insert into @tblFreeType Values(2)     
    Insert into @tblFreeType Values(3)     
    End    
    
  IF @CLSDAY_FLAG = 0 
    Begin  
    Select SchAbs.ActivityCode, SchAbs.Description, dbo.StripTimeFromDate(SchAbs.SchemeFrom) 'SchemeFrom', dbo.MakeDayEnd(SchAbs.SchemeTo) 'SchemeTo',     
    dbo.StripTimeFromDate(SchPP.PayoutPeriodFrom) 'PayoutFrom' , dbo.MakeDayEnd(SchPP.PayoutPeriodTo) 'PayoutTo',     
    SchAbs.SchemeID, SchPP.ID as 'PayoutID', IsNull(SchSlab.SlabType,0) 'SlabType',  IsNull(ItemGroup,0) 'ItemGroup', ApplicableOn, dbo.MakeDayEnd(DateAdd(Day,DateDiff(d, dbo.StripTimeFromDate(SchAbs.ActiveTo),     
    dbo.StripTimeFromDate(SchAbs.ExpiryDate)), dbo.StripTimeFromDate(SchPP.PayoutPeriodTo))) 'ExpiryDate'    
    From tbl_mERP_SchemeAbstract SchAbs, tbl_mERP_SchemeOutlet SchOtl, tbl_mERP_SchemePayoutPeriod SchPP, tbl_mERP_SchemeSlabDetail SchSlab    
    Where SchAbs.SchemeID = SchOtl.SchemeID And     
    SchAbs.SchemeType in (1,2) And     
    SchAbs.SchemeID = SchPP.SchemeID And    
    SchAbs.SchemeID = SchSlab.SchemeID And    
    SchOtl.GroupID = SchSlab.GroupID And     
   (DateAdd(Day, DateDiff(d, dbo.StripTimeFromDate(SchAbs.ActiveTo), dbo.StripTimeFromDate(SchAbs.ExpiryDate)), dbo.StripTimeFromDate(SchPP.PayoutPeriodTo)) < dbo.StripTimeFromDate(@TransDate)) And
    SchOtl.QPS = 1 And SchAbs.Active = 1 And     
    SchPP.Active = 1 And --SchPP.ClaimRFA = 0 And     
    SchPP.Status & 128= Case @SchStatus When 1 Then 128 Else 0 End And     
    SchSlab.SlabType in ( Select SlabType From  @tblFreeType) And 
    SchPP.ID not in (Select PayoutID From tbl_merp_QPSAbsData Where RowID in (1,2) and IsNull(SalesValue,0) = 0)
    Group by SchAbs.ActivityCode, SchAbs.Description, SchAbs.SchemeID, SchPP.ID, SchAbs.SchemeFrom, SchAbs.SchemeTo,     
    SchAbs.ActiveTo, SchPP.PayoutPeriodFrom, SchPP.PayoutPeriodTo, SchAbs.ApplicableOn, IsNull(ItemGroup,0),    
    IsNull(SchSlab.SlabType,0), (SchPP.PayoutPeriodTo), SchAbs.ExpiryDate    
    End
  ELSE
    Begin
    Select SchAbs.ActivityCode, SchAbs.Description, dbo.StripTimeFromDate(SchAbs.SchemeFrom) 'SchemeFrom', dbo.MakeDayEnd(SchAbs.SchemeTo) 'SchemeTo',     
    dbo.StripTimeFromDate(SchPP.PayoutPeriodFrom) 'PayoutFrom' , dbo.MakeDayEnd(SchPP.PayoutPeriodTo) 'PayoutTo',     
    SchAbs.SchemeID, SchPP.ID as 'PayoutID', IsNull(SchSlab.SlabType,0) 'SlabType',  IsNull(ItemGroup,0) 'ItemGroup', ApplicableOn, dbo.MakeDayEnd(DateAdd(Day,DateDiff(d, dbo.StripTimeFromDate(SchAbs.ActiveTo),     
    dbo.StripTimeFromDate(SchAbs.ExpiryDate)), dbo.StripTimeFromDate(SchPP.PayoutPeriodTo))) 'ExpiryDate'    
    From tbl_mERP_SchemeAbstract SchAbs, tbl_mERP_SchemeOutlet SchOtl, tbl_mERP_SchemePayoutPeriod SchPP, tbl_mERP_SchemeSlabDetail SchSlab    
    Where SchAbs.SchemeID = SchOtl.SchemeID And     
    SchAbs.SchemeType in (1,2) And     
    SchAbs.SchemeID = SchPP.SchemeID And    
    SchAbs.SchemeID = SchSlab.SchemeID And    
    SchOtl.GroupID = SchSlab.GroupID And     
    dbo.StripTimeFromDate(SchPP.PayoutPeriodTo) <= @DAY_CLOSE And
    dbo.StripTimeFromDate(SchPP.PayoutPeriodTo) < dbo.StripTimeFromDate(@TransDate) And 
    SchOtl.QPS = 1 And SchAbs.Active = 1 And     
    SchPP.Active = 1 And --SchPP.ClaimRFA = 0 And     
    SchPP.Status & 128= Case @SchStatus When 1 Then 128 Else 0 End And     
    SchSlab.SlabType in ( Select SlabType From  @tblFreeType) And   
    SchPP.ID not in (Select PayoutID From tbl_merp_QPSAbsData Where RowID in (1,2) and IsNull(SalesValue,0) = 0)
    Group by SchAbs.ActivityCode, SchAbs.Description, SchAbs.SchemeID, SchPP.ID, SchAbs.SchemeFrom, SchAbs.SchemeTo,     
    SchAbs.ActiveTo, SchPP.PayoutPeriodFrom, SchPP.PayoutPeriodTo, SchAbs.ApplicableOn, IsNull(ItemGroup,0),    
    IsNull(SchSlab.SlabType,0), (SchPP.PayoutPeriodTo), SchAbs.ExpiryDate
    End
End
