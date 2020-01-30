Create Procedure mERP_sp_GetSubmittedRFA(@ClaimType Int, @FromMonth nvarchar(100),@ToMonth nvarchar(100),@Type int )    
As    
 SET DATEFORMAT DMY  
 If @ClaimType = 1 Or @ClaimType = 2 /*Expiry Or Damages Or Sampling*/    
  If @ClaimType = 1 /*Damages Or Expiry*/    
   Select RFA.ActivityCode, RFA.Description , RFA.ActiveFrom as SchemeFrom, RFA.ActiveTo as SchemeTo,    
    RFA.PayoutFrom as PayoutFrom, RFA.PayoutTo as PayoutTo, CN.ClaimValue as RFAValue,  RFA.RFADocID as DocID,    
    Case CN.ClaimType     
     When 1 Then 6     
     Else 7 End as SchType, 
	 Sum(IsNull(RFA.SalvageQty, 0)) As SalvageQty,
	 Sum(IsNull(RFA.SalvageValue, 0)) As SalvageValue 
    From ClaimsNote CN, DandDAbstract dda, 
		tbl_mERP_RFAAbstract RFA    
    Where cn.ClaimID = dda.ClaimID
	And IsNull(dda.ClaimStatus, 0) = 3 
	And CN.ClaimDate between dbo.mERP_fn_getFromDate(@FromMonth) and dbo.mERP_fn_getToDate(@ToMonth)  
	and Isnull(RFA.Status,0)<>5 
	And CN.ClaimType In (2)    
    And IsNull(CN.ClaimRFA,0) > 0    
    And CN.ClaimID = RFA.DocReference  
	Group By RFA.ActivityCode, RFA.Description , RFA.ActiveFrom , RFA.ActiveTo ,    
		RFA.PayoutFrom , RFA.PayoutTo , CN.ClaimValue ,  RFA.RFADocID ,    
		CN.ClaimType 
   

	Union

   Select Distinct RFA.ActivityCode, RFA.Description , Null as SchemeFrom, Null as SchemeTo,    
    Null as PayoutFrom, Null as PayoutTo, CN.ClaimValue as RFAValue,  RFA.RFADocID as DocID,    
    Case CN.ClaimType     
     When 1 Then 6     
     Else 7 End as SchType, 
	 0, 0 
    From ClaimsNote CN, tbl_mERP_RFAAbstract RFA    
    Where   
   CN.ClaimDate between dbo.mERP_fn_getFromDate(@FromMonth) and dbo.mERP_fn_getToDate(@ToMonth)  
   and Isnull(RFA.Status,0)<>5 
   And CN.ClaimType In (1)    
    And IsNull(CN.ClaimRFA,0) > 0    
    And CN.ClaimID = RFA.DocReference 
  Else /*Sampling*/    
   Select Distinct RFA.ActivityCode, RFA.Description , Null as SchemeFrom, Null as SchemeTo,    
    Null as PayoutFrom, Null as PayoutTo, CN.ClaimValue as RFAValue,  RFA.RFADocID as DocID,    
    8 as SchType    
    From ClaimsNote CN, tbl_mERP_RFAAbstract RFA    
    Where CN.ClaimType = 3 
    and Isnull(RFA.Status,0)<>5    
    AND CN.ClaimDate between dbo.mERP_fn_getFromDate(@FromMonth) and dbo.mERP_fn_getToDate(@ToMonth)  
    And IsNull(CN.ClaimRFA,0) > 0    
    And CN.ClaimID = RFA.DocReference     
 Else If @ClaimType = 4    
   Select Distinct RFA.ActivityCode, RFA.Description , Null as SchemeFrom, Null as SchemeTo,    
    PayoutFrom as PayoutFrom, PayoutTo as PayoutTo, CN.ClaimValue as RFAValue,  RFA.RFADocID as DocID,    
    CN.ClaimType  as SchType    
    From ClaimsNote CN, tbl_mERP_RFAAbstract RFA    
    Where CN.ClaimType In (10)    
    And RFA.PayoutTo between dbo.mERP_fn_getFromDate(@FromMonth) and dbo.mERP_fn_getToDate(@ToMonth)  
    and Isnull(RFA.Status,0)<>5 
    And IsNull(CN.ClaimRFA,0) > 0    
    And CN.ClaimID = RFA.DocReference     
 Else     
 Begin    
  Create Table #tmpSPRFAInfo(ActivityCode nvarchar(255), Description nvarchar(255), SchemeFrom datetime, SchemeTo datetime, PayoutFrom datetime, PayoutTo datetime,     
    RFAValue decimal(18,6),DocID int, SchType int)  
  
  Create Table #tmpDispRFAInfo(ActivityCode nvarchar(255), Description nvarchar(255), SchemeFrom datetime, SchemeTo datetime, PayoutFrom datetime, PayoutTo datetime,     
    RFAValue decimal(18,6),DocID int, SchType int)  
  if @type = 1  
  BEGIN  
   insert Into #tmpSPRFAInfo  
   Select Distinct RFA.ActivityCode, RFA.Description, SA.SchemeFrom, SA.SchemeTo, RFA.PayoutFrom, RFA.PayoutTo,     
    CN.ClaimValue as RFAValue, RFA.RFADocID as DocID, 1 as SchType    
    From tbl_mERP_RFAAbstract RFA, ClaimsNote CN, tbl_mERP_SchemeAbstract SA    
    Where CN.ClaimType = 7    
    AND SA.schemeType in (1,2)  
    And RFA.PayoutTo between dbo.mERP_fn_getFromDate(@FromMonth) and dbo.mERP_fn_getToDate(@ToMonth)  
    and Isnull(RFA.Status,0)<>5 
    And RFA.DocumentID = SA.SchemeID    
    And IsNull(CN.ClaimRFA, 0) > 0    
    And CN.ClaimID = RFA.DocReference     
    And SA.ActivityCode = RFA.ActivityCode    
  END  
  ELSE IF @type = 2  
  BEGIN  
    insert Into #tmpSPRFAInfo  
    Select Distinct RFA.ActivityCode, RFA.Description, SA.SchemeFrom, SA.SchemeTo, RFA.PayoutFrom, RFA.PayoutTo,     
    CN.ClaimValue as RFAValue, RFA.RFADocID as DocID, 1 as SchType   
    From tbl_mERP_RFAAbstract RFA, ClaimsNote CN, tbl_mERP_SchemeAbstract SA    
    Where CN.ClaimType = 7    
    AND SA.schemeType = 3   
    And RFA.PayoutTo between dbo.mERP_fn_getFromDate(@FromMonth) and dbo.mERP_fn_getToDate(@ToMonth)  
    and Isnull(RFA.Status,0)<>5 
    And RFA.DocumentID = SA.SchemeID    
    And IsNull(CN.ClaimRFA, 0) > 0    
    And CN.ClaimID = RFA.DocReference     
    And SA.ActivityCode = RFA.ActivityCode    
  END  
  ELSE IF @type = 3  
  BEGIN  
    insert Into #tmpSPRFAInfo  
    Select Distinct RFA.ActivityCode, RFA.Description, SA.SchemeFrom, SA.SchemeTo, RFA.PayoutFrom, RFA.PayoutTo,     
    CN.ClaimValue as RFAValue, RFA.RFADocID as DocID, 1 as SchType  
    From tbl_mERP_RFAAbstract RFA, ClaimsNote CN, tbl_mERP_SchemeAbstract SA    
    Where CN.ClaimType = 7    
       AND SA.schemeType = 4   
    And RFA.PayoutTo between dbo.mERP_fn_getFromDate(@FromMonth) and dbo.mERP_fn_getToDate(@ToMonth)  
    and Isnull(RFA.Status,0)<>5 
    And RFA.DocumentID = SA.SchemeID    
    And IsNull(CN.ClaimRFA, 0) > 0    
    And CN.ClaimID = RFA.DocReference     
    And SA.ActivityCode = RFA.ActivityCode    
  END  
  ELSE  
  BEGIN  
    insert Into #tmpSPRFAInfo  
    Select Distinct RFA.ActivityCode, RFA.Description, SA.SchemeFrom, SA.SchemeTo, RFA.PayoutFrom, RFA.PayoutTo,     
    CN.ClaimValue as RFAValue, RFA.RFADocID as DocID, 1 as SchType  
    From tbl_mERP_RFAAbstract RFA, ClaimsNote CN, tbl_mERP_SchemeAbstract SA    
    Where CN.ClaimType = 7    
       AND SA.schemeType in (1,2,3,4)  
    And RFA.PayoutTo between dbo.mERP_fn_getFromDate(@FromMonth) and dbo.mERP_fn_getToDate(@ToMonth)  
   and Isnull(RFA.Status,0)<>5 
    And RFA.DocumentID = SA.SchemeID    
    And IsNull(CN.ClaimRFA, 0) > 0    
    And CN.ClaimID = RFA.DocReference     
    And SA.ActivityCode = RFA.ActivityCode    
  END  
  
  if @type = 1  
  BEGIN  
    insert into #tmpDispRFAInfo    
    Select Distinct RFA.ActivityCode, RFA.Description, SA.SchemeFrom as SchemeFrom, SA.SchemeTo as SchemeTo, RFA.PayoutFrom, RFA.PayoutTo,    
    CN.ClaimValue as RFAValue,  RFA.RFADocID as DocID, Case RFA.SchemeType     
     When 'Display' Then 3    
     Else 4    
     End as SchType     
      
    From tbl_mERP_RFAAbstract RFA, ClaimsNote CN, tbl_mERP_SchemeAbstract SA, tbl_mERP_SchemePayoutPeriod SPP    
    Where CN.ClaimType In (8,9)    
    AND SA.schemeType in (1,2)  
   and Isnull(RFA.Status,0)<>5 
    And RFA.PayoutTo between dbo.mERP_fn_getFromDate(@FromMonth) and dbo.mERP_fn_getToDate(@ToMonth)  
    And IsNull(CN.ClaimRFA, 0) > 0    
    And CN.ClaimID = RFA.DocReference     
    And SA.ActivityCode = RFA.ActivityCode    
    And SA.SchemeID = SPP.SchemeID    
    And RFA.PayoutFrom = SPP.PayoutPeriodFrom    
    And RFA.PayoutTo = SPP.PayoutPeriodTo    
  END  
  ELSE IF @type = 2  
  BEGIN  
    insert into #tmpDispRFAInfo    
    Select Distinct RFA.ActivityCode, RFA.Description, SA.SchemeFrom as SchemeFrom, SA.SchemeTo as SchemeTo, RFA.PayoutFrom, RFA.PayoutTo,    
    CN.ClaimValue as RFAValue,  RFA.RFADocID as DocID, Case RFA.SchemeType     
     When 'Display' Then 3    
     Else 4    
     End as SchType     
      
    From tbl_mERP_RFAAbstract RFA, ClaimsNote CN, tbl_mERP_SchemeAbstract SA, tbl_mERP_SchemePayoutPeriod SPP    
    Where CN.ClaimType In (8,9)    
    AND SA.schemeType = 3   
    And RFA.PayoutTo between dbo.mERP_fn_getFromDate(@FromMonth) and dbo.mERP_fn_getToDate(@ToMonth) 
    and Isnull(RFA.Status,0)<>5  
    And IsNull(CN.ClaimRFA, 0) > 0    
    And CN.ClaimID = RFA.DocReference     
    And SA.ActivityCode = RFA.ActivityCode    
    And SA.SchemeID = SPP.SchemeID    
    And RFA.PayoutFrom = SPP.PayoutPeriodFrom    
    And RFA.PayoutTo = SPP.PayoutPeriodTo    
  END  
  ELSE IF @type = 3  
  BEGIN  
    insert into #tmpDispRFAInfo    
    Select Distinct RFA.ActivityCode, RFA.Description, SA.SchemeFrom as SchemeFrom, SA.SchemeTo as SchemeTo, RFA.PayoutFrom, RFA.PayoutTo,    
    CN.ClaimValue as RFAValue,  RFA.RFADocID as DocID, Case RFA.SchemeType     
     When 'Display' Then 3    
     Else 4    
     End as SchType     
    From tbl_mERP_RFAAbstract RFA, ClaimsNote CN, tbl_mERP_SchemeAbstract SA, tbl_mERP_SchemePayoutPeriod SPP    
    Where CN.ClaimType In (8,9)    
       AND SA.schemeType = 4   
    And RFA.PayoutTo between dbo.mERP_fn_getFromDate(@FromMonth) and dbo.mERP_fn_getToDate(@ToMonth)  
    and Isnull(RFA.Status,0)<>5 
    And IsNull(CN.ClaimRFA, 0) > 0    
    And CN.ClaimID = RFA.DocReference     
    And SA.ActivityCode = RFA.ActivityCode    
    And SA.SchemeID = SPP.SchemeID    
    And RFA.PayoutFrom = SPP.PayoutPeriodFrom    
    And RFA.PayoutTo = SPP.PayoutPeriodTo    
  END  
  ELSE  
  BEGIN  
       insert into #tmpDispRFAInfo    
    Select Distinct RFA.ActivityCode, RFA.Description, SA.SchemeFrom as SchemeFrom, SA.SchemeTo as SchemeTo, RFA.PayoutFrom, RFA.PayoutTo,    
    CN.ClaimValue as RFAValue,  RFA.RFADocID as DocID, Case RFA.SchemeType     
     When 'Display' Then 3   
     Else 4    
     End as SchType     
    From tbl_mERP_RFAAbstract RFA, ClaimsNote CN, tbl_mERP_SchemeAbstract SA, tbl_mERP_SchemePayoutPeriod SPP    
    Where CN.ClaimType In (8,9)    
       AND SA.schemeType in(1,2,3,4)   
    And RFA.PayoutTo between dbo.mERP_fn_getFromDate(@FromMonth) and dbo.mERP_fn_getToDate(@ToMonth)  
    and Isnull(RFA.Status,0)<>5 
    And IsNull(CN.ClaimRFA, 0) > 0    
    And CN.ClaimID = RFA.DocReference     
    And SA.ActivityCode = RFA.ActivityCode    
    And SA.SchemeID = SPP.SchemeID    
    And RFA.PayoutFrom = SPP.PayoutPeriodFrom    
    And RFA.PayoutTo = SPP.PayoutPeriodTo    
  END  
  
  Select ActivityCode, Description, SchemeFrom, SchemeTo, PayoutFrom, PayoutTo,     
   Sum(RFAValue) as RFAValue, DocID, SchType     
   From #tmpSPRFAInfo    
   Group By ActivityCode, Description, SchemeFrom, SchemeTo, PayoutFrom, PayoutTo, DocID, SchType    
    
  Union     
    
  Select ActivityCode, Description, SchemeFrom, SchemeTo, PayoutFrom, PayoutTo,     
   Sum(RFAValue) as RFAValue, DocID, SchType     
   From #tmpDispRFAInfo    
   Group By ActivityCode, Description, SchemeFrom, SchemeTo, PayoutFrom, PayoutTo, DocID, SchType    
    
  Drop Table #tmpSPRFAInfo    
  Drop Table #tmpDispRFAInfo    
 End 
