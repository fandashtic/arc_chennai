Create Procedure mERP_Spr_PointSchNonClaimAbs  
( @ParmMonth as nVarchar(25) )  
As  
Begin  
 Set DateFormat DMY  
 Declare @TillDate DateTime  
 Declare @DtMonth DateTime  
 Declare @FromDate DateTime  
 Declare @ToDate DateTime  
 Declare @Month nVarchar(25)  
 Declare @WDCode NVarchar(255)  
 Declare @WDDest NVarchar(255)  
 Declare @CompaniesToUploadCode NVarchar(255)  
 Create Table #OutPut (WDCode nVarchar(255),WDDest nVarchar(255),FromDate DateTime,ToDate DateTime,SchemeID nVarchar(255),ActivityCode nVarchar(255),Description nVarchar(255),[Scheme From Date] datetime,[Scheme To Date] datetime)   
 Select Top 1 @CompaniesToUploadCode=ForumCode From Companies_To_Upload  
 Select Top 1 @WDCode = RegisteredOwner From Setup  
 If @CompaniesToUploadCode = N'ITC001'  
 Set @WDDest= @WDCode  
 Else  
 Begin  
  Set @WDDest= @WDCode  
  Set @WDCode= @CompaniesToUploadCode  
  End  
  
 Set @TillDate = GetDate()  
 If @ParmMonth = '' Or @ParmMonth = '%'   
  Set @Month = Right((Convert(nVarchar(10), @TillDate, 103)),7)   
 Else if  Len(@ParmMonth) > 7  
 Begin  
  Set @Month = Right((Convert(nVarchar(10), @TillDate, 103)),7)  
 End  
 Else if isDate(Cast(('01' + '/' + @ParmMonth) as nVarchar(15))) = 0  
  Set @Month = Right((Convert(nVarchar(10), @TillDate, 103)),7)  
 Else  
  Set @Month = Cast(@ParmMonth as nVarchar(7))   
 Set @DtMonth = cast(Cast('01' + '/' +  @Month as nVarchar(15)) as datetime)  
 Select @FromDate =  Convert(nVarchar(10), @DtMonth, 103)   
 Select @ToDate = DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,@DtMonth)+1,0))  
 Insert Into #OutPut (SchemeID,ActivityCode,Description,[Scheme From Date],[Scheme To Date])  
 Select Distinct Cast(SPP.ID As nVarchar(25)) + Char(15) + Cast (SA.SchemeID As nVarchar(25)) As 'SchemeID',  
   SA.ActivityCode As 'ActivityCode',   
   SA.[Description] As 'Description',  
   SPP.PayoutPeriodFrom As 'Scheme From Date',  SPP.PayoutPeriodTo As 'Scheme To Date'  
 From tbl_mERP_SchemeAbstract SA   
 --Join tbl_mERP_CSRedemption CSR On CSR.SchemeID = SA.SchemeID And CSR.RFAstatus <> 2  
 Join tbl_mERP_SchemePayoutPeriod SPP On SPP.SchemeID = SA.SchemeID And SPP.Active = 1 --And SPP.ID = CSR.PayOutId  
 Where SA.SchemeType = 4 And SPP.PayoutPeriodTo Between @FromDate And @ToDate And IsNull(SA.RFAApplicable,0) = 0  
   
 Update #OutPut set WDCode = @WDCode,WDDest = @WDDest, FromDate = @FromDate, ToDate = @ToDate  
   
 Select SchemeID, WDCode, WDDest, FromDate As 'From Date', ToDate As 'To_Date', ActivityCode As 'Activity Code',Description,[Scheme From Date] As 'Scheme From Date',[Scheme To Date] as 'Scheme To Date'  from #OutPut  
End  

