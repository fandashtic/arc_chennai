 
CREATE Procedure mERP_sp_Get_SchemeRFAClaimInfo @FromMonth nvarchar(100),@ToMonth nvarchar(100)  
As      
Begin      
 SET DATEFORMAT DMY   
 Declare @ProcessDate As DateTime      
 Declare @CloseDay Int      
      
 Create Table #tmpSchemeDetail(SchemeID Int, Description nVarchar(255), ActivityCode nVarchar(255),       
  SchemeFrom DateTime, SchemeTo DateTime, PayoutFrom DateTime, PayoutTo DateTime, SchType Int,       
  PayoutID Int)      
      
 Select @CloseDay = IsNull(Flag, 0) From tbl_mERP_ConfigAbstract Where ScreenCode = 'CLSDAY01'      
      
       
 If (@CloseDay) > 0      
  Select @ProcessDate =  isNull(LastInventoryUpload,'') From Setup      
 Else      
  Select @ProcessDate = Case IsNull(Max(InvoiceDate),'')       
   When '' Then GETDATE()       
   Else Max(InvoiceDate) End      
   From InvoiceAbstract       
   Where InvoiceType In (1,3,4)       
   And (Status & 128)= 0      
      
 /*Select Trade Schemes detail*/      
 If @CloseDay = 1      
 Begin      
   /*Referring RFA data Posting log table Process status to filter the payout listing based on the process completion*/      
   Declare @DCProcessStauts Int       
   Declare @DCProcessUpto DateTime       
   Select @DCProcessStauts = ISNull(Active,0), @DCProcessUpto = dbo.StriptimeFromDate(ProcessUptoDate) From tbl_mERP_BackDtSchProcessInfo  where isnull(Active,0)=1
   If @DCProcessStauts = 1      
   Begin      
      /*To list only the completed payouts during Data Correction process execution by checking with ProcessUptoDate in Log table*/      
     Insert Into #tmpSchemeDetail       
     Select Distinct SA.SchemeID,  SA.Description, SA.ActivityCode,      
     SA.SchemeFrom, SA.SchemeTo, SPP.PayoutPeriodFrom, SPP.PayoutPeriodTo, 1, SPP.ID       
     From tbl_mERP_SchemeAbstract SA, (select SchemeId, Min(QPS) QPS  From tbl_mERP_SchemeOutlet Group By SchemeId) SO, tbl_mERP_SchemePayoutPeriod SPP      
     Where SA.SchemeID = SO.SchemeID      
     And SA.SchemeType = 1      
     And SO.QPS = 0      
     And IsNull(SPP.ClaimRFA,0) = 0       
     And SA.RFAApplicable = 1      
     And SA.SchemeID = SPP.SchemeID      
     And SPP.Active = 1        
     And dbo.StripTimeFromDate(SPP.PayoutPeriodTo) <= dbo.StripTimeFromDate(@ProcessDate)       
     And dbo.StripTimeFromDate(SPP.PayoutPeriodTo) <= dbo.StripTimeFromDate(@DCProcessUpto)      
    
     /*QPS Schemes for which Cr.Note generated - Start*/      
     Insert Into #tmpSchemeDetail       
     Select Distinct SA.SchemeID, SA.Description, SA.ActivityCode,       
     SA.SchemeFrom , SA.SchemeTo, SPP.PayoutPeriodFrom, SPP.PayoutPeriodTo,1, SPP.ID       
     From tbl_mERP_SchemeAbstract SA, tbl_mERP_SchemePayoutPeriod SPP,      
            (select SchemeId, Max(QPS) QPS From tbl_mERP_SchemeOutlet Group By SchemeId) SO      
     Where SA.RFAApplicable = 1      
     And SA.SchemeType = 1       
     And SA.SchemeID = SPP.SchemeID      
     And SA.SchemeID = SO.SchemeID      
     And IsNull(SPP.ClaimRFA,0) = 0       
     And IsNull(SPP.Status, 0) = 128         
     And SPP.Active = 1        
     And SO.QPS = 1      
     And dbo.StripTimeFromDate(SPP.PayoutPeriodTo) <= dbo.StripTimeFromDate(@DCProcessUpto)      
    /*End Select Trade Schemes detail*/      
   End      
   Else      
   Begin      
     Insert Into #tmpSchemeDetail       
     Select Distinct SA.SchemeID,  SA.Description, SA.ActivityCode,      
     SA.SchemeFrom, SA.SchemeTo, SPP.PayoutPeriodFrom, SPP.PayoutPeriodTo, 1, SPP.ID       
     From tbl_mERP_SchemeAbstract SA, (select SchemeId, Max(QPS) QPS  From tbl_mERP_SchemeOutlet Group By SchemeId) SO, tbl_mERP_SchemePayoutPeriod SPP      
     Where SA.SchemeID = SO.SchemeID      
     And SA.SchemeType = 1      
     And SO.QPS = 0      
     And IsNull(SPP.ClaimRFA,0) = 0       
     And SA.RFAApplicable = 1      
     And SA.SchemeID = SPP.SchemeID      
     And SPP.Active = 1        
     And dbo.StripTimeFromDate(SPP.PayoutPeriodTo) <= dbo.StripTimeFromDate(@ProcessDate)       
    
     /*QPS Schemes for which Cr.Note generated - Start*/      
     Insert Into #tmpSchemeDetail       
     Select Distinct SA.SchemeID, SA.Description, SA.ActivityCode,       
     SA.SchemeFrom , SA.SchemeTo, SPP.PayoutPeriodFrom, SPP.PayoutPeriodTo,1, SPP.ID       
     From tbl_mERP_SchemeAbstract SA, tbl_mERP_SchemePayoutPeriod SPP,      
            (select SchemeId, Max(QPS) QPS From tbl_mERP_SchemeOutlet Group By SchemeId) SO      
     Where SA.RFAApplicable = 1      
     And SA.SchemeType = 1       
     And SA.SchemeID = SPP.SchemeID      
     And SA.SchemeID = SO.SchemeID      
     And IsNull(SPP.ClaimRFA,0) = 0       
     And IsNull(SPP.Status, 0) = 128         
     And SPP.Active = 1        
     And SO.QPS = 1      
     /*End Select Trade Schemes detail*/      
   End      
 End      
 Else      
 Begin      
   Insert Into #tmpSchemeDetail       
   Select Distinct SA.SchemeID,  SA.Description, SA.ActivityCode,      
   SA.SchemeFrom, SA.SchemeTo, SPP.PayoutPeriodFrom, SPP.PayoutPeriodTo, 1, SPP.ID       
   From tbl_mERP_SchemeAbstract SA, (select SchemeId, Max(QPS) QPS  From tbl_mERP_SchemeOutlet Group By SchemeId) SO, tbl_mERP_SchemePayoutPeriod SPP      
   Where SA.SchemeID = SO.SchemeID      
   And SA.SchemeType = 1      
   And SO.QPS = 0      
   And IsNull(SPP.ClaimRFA,0) = 0       
   And SA.RFAApplicable = 1      
   And SA.SchemeID = SPP.SchemeID      
   And SPP.Active = 1        
   And dbo.StripTimeFromDate(DateAdd(Day,DateDiff(Day,SA.ActiveTo,SA.ExpiryDate),SPP.PayoutPeriodTo)) < dbo.StripTimeFromDate(@ProcessDate)       
    
  /*QPS Schemes for which Cr.Note generated - Start*/      
   Insert Into #tmpSchemeDetail       
   Select Distinct SA.SchemeID, SA.Description, SA.ActivityCode,       
   SA.SchemeFrom , SA.SchemeTo, SPP.PayoutPeriodFrom, SPP.PayoutPeriodTo,1, SPP.ID       
   From tbl_mERP_SchemeAbstract SA, tbl_mERP_SchemePayoutPeriod SPP,      
            (select SchemeId, Max(QPS) QPS From tbl_mERP_SchemeOutlet Group By SchemeId) SO      
   Where SA.RFAApplicable = 1      
   And SA.SchemeType = 1       
   And SA.SchemeID = SPP.SchemeID      
   And SA.SchemeID = SO.SchemeID      
   And IsNull(SPP.ClaimRFA,0) = 0       
   And IsNull(SPP.Status, 0) = 128         
   And SPP.Active = 1        
   And SO.QPS = 1      
   /*End Select Trade Schemes detail*/      
 End      
      
 --Point Scheme      
 Insert into #tmpSchemeDetail       
 Select SA.SchemeId, SA.Description, SA.ActivityCode,       
   SA.SchemeFrom, SA.SchemeTo, SPP.PayoutPeriodFrom, SPP.PayoutPeriodTo, 4, CSR.PayoutID      
   From tbl_mERP_SchemeAbstract SA, tbl_mERP_SchemePayoutPeriod SPP, tbl_mERP_CSRedemption CSR      
   Where SA.SchemeID = SPP.SchemeID      
   And SA.SchemeType = 4      
   And IsNull(RFAApplicable,0) = 1      
   And IsNull(SPP.Status, 0) = 1       
   And IsNull(SPP.ClaimRFA, 0) = 0       
   And SPP.Active = 1      
   And SPP.SchemeID = CSR.SchemeID      
   And SPP.ID = CSR.PayoutID      
   And IsNull(CSR.RFAStatus, 0) = 1      
   Group By SA.SchemeId, SA.ActivityCode, SA.Description, SA.SchemeFrom, SA.SchemeTo, SPP.PayoutPeriodFrom, SPP.PayoutPeriodTo,CSR.PayoutID      
 --Display Scheme      
 Insert Into #tmpSchemeDetail Select SA.SchemeID, SA.Description, SA.ActivityCode,        
   SA.SchemeFrom, SA.SchemeTo, SPP.PayoutPeriodFrom, SPP.PayoutPeriodTo, 3, DBP.PayoutPeriodID      
   From tbl_mERP_SchemeAbstract SA, tbl_mERP_SchemePayoutPeriod SPP,tbl_mERP_DispSchBudgetPayout DBP      
   Where SA.SchemeID = SPP.SchemeID      
   And SA.SchemeType = 3       
   And IsNull(SA.RFAApplicable,0) = 1      
   And SPP.SchemeID = DBP.SchemeID      
   And IsNull(SPP.ClaimRFA, 0) = 0      
   And IsNull(SPP.Status, 0) = 128        
   And SPP.Active = 1      
   And SPP.ID = DBP.PayoutPeriodID    
   Group By SA.SchemeID,SA.ActivityCode, SA.Description, SA.SchemeFrom, SA.SchemeTo, SPP.PayoutPeriodFrom, SPP.PayoutPeriodTo,DBP.PayoutPeriodID      
      
    --Consolidated       
  --For getting Expiry Month  
  Declare @Expiry int  
  Select @Expiry=isnull(Value,0) from tbl_merp_configdetail where Screencode='SENDRFA' and ControlName='Expiry'  
  
  --If expiry is zero then dont consider the Expiry  
  if @expiry = 0  
  BEGIN  
   Select Distinct SchemeID, Description, ActivityCode, SchemeFrom, SchemeTo,       
   PayoutFrom as PayoutPeriodFrom, PayoutTo as PayoutPeriodTo, SchType, PayoutID         
   From #tmpSchemeDetail  
   -- Expiry condition is not validated below  
   Where --(datediff(d,dateadd(m,@Expiry,PayoutTo),getdate())) < 0  
   -- to display only payouts falls under selected months  
   PayoutTo between dbo.mERP_fn_getFromDate(@FromMonth) and dbo.mERP_fn_getToDate(@ToMonth)  
   Order By ActivityCode, PayoutFrom, PayoutTo      
  END  
  ELSE  
  BEGIN  
   Select Distinct SchemeID, Description, ActivityCode, SchemeFrom, SchemeTo,       
   PayoutFrom as PayoutPeriodFrom, PayoutTo as PayoutPeriodTo, SchType, PayoutID         
   From #tmpSchemeDetail  
   -- To display only non expired schemes, additional condition is included below      
   Where (datediff(d,dateadd(m,@Expiry,PayoutTo),getdate())) < 0  
   -- to display only payouts falls under selected months  
   And PayoutTo between dbo.mERP_fn_getFromDate(@FromMonth) and dbo.mERP_fn_getToDate(@ToMonth)  
   Order By ActivityCode, PayoutFrom, PayoutTo      
  END  
  Drop table #tmpSchemeDetail    
      
End      
  
