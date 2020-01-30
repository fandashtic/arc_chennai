Create Procedure dbo.Sp_DataRemoveProcess
As
BegIn
/* Deletion Script*/
Set Dateformat dmy

If Not Exists(select 'X' From setup where isnull(FYCPStatus,0)=0)
Begin
Goto Out
End

Declare @OpeningDate as DateTime
Declare @SchOpeningDate as DateTime
Set @OpeningDate = (Select top 1 OpeningDate From setup)

Delete From Collection_Details Where processed=1 and collectiondate < @OpeningDate
Delete From Collection_Action Where collectionid Not In (Select documentid From collections)
Delete From Collection_Action Where collectionid In (Select documentid From collections Where documentdate < @OpeningDate)
Delete from SoDetail where soNumber in (select sonumber from SoAbstract where soDate < @OpeningDate)
Delete from SoAbstract where soDate < @OpeningDate
--	Delete From Order_Details Where SaleOrderID In (Select SONumber From SOAbstract Where SODate  < @OpeningDate
--	Delete From Order_Header Where Ordernumber Not In (Select ordernumber From Order_Details)
Delete From Order_Header Where Order_Date   < @OpeningDate
Delete From Order_Details Where Ordernumber Not In( Select ordernumber From Order_header )
Delete From Scheme_Details Where Ordernumber Not In( Select ordernumber From Order_header )

--	Delete From Order_Details_copy Where SaleOrderID In (Select SONumber From SOAbstract Where SODate < @OpeningDate
--	Delete From Order_Header_copy Where Ordernumber Not In (Select ordernumber From Order_Details_copy)
Delete From Order_Header_copy Where Order_Date   < @OpeningDate
Delete From Order_Details_copy Where Ordernumber Not In( Select ordernumber From Order_header )

Delete From tbl_Merp_UploadReportXMLTracker Where ReportDocId In (
Select ReportDocID From tbl_Merp_UploadReportTracker Where isnull(ackStatus,0)=193 And IsNull(Status,0) = 129)
Delete From tbl_Merp_UploadReportXMLTracker Where ReportDocId Not In (
Select reportdocid From tbl_Merp_UploadReportTracker)

--Scheme remove process
Set @SchOpeningDate = DATEADD (Year,-1,@OpeningDate)

Create table #Temppayout(
ID Int,
SchemeID Int,
PayoutPeriodFrom DateTime,
PayoutPeriodTo DateTime,
Status Int,
Active Int,
ClaimRFA Int,
CS_SchemeID Int)

Truncate Table #Temppayout

--Insert Into #Temppayout(ID,SchemeID,PayoutPeriodFrom,PayoutPeriodTo,Status,Active,ClaimRFA)
--Select ID,SchemeID,PayoutPeriodFrom,PayoutPeriodTo,Status,Active,ClaimRFA
Insert Into #Temppayout(SchemeID,CS_SchemeID)
Select Distinct SPP.SchemeID ,SA.CS_SchemeID
From tbl_mERP_SchemePayoutPeriod SPP Join tbl_mERP_SchemeAbstract SA On SA.SchemeID = SPP.SchemeID
Where SPP.SchemeID Not In  (
Select DistInct S.SchemeID From tbl_mERP_SchemePayoutPeriod PP,tbl_mERP_SchemeAbstract S Where S.SchemeID=PP.SchemeID
--	and isnull(S.RFAApplicable,0) =1
and (PP.PayoutPeriodTo>=@SchOpeningDate Or isnull(PP.ClaimRFA,0)=0))

Insert Into #Temppayout(SchemeID,CS_SchemeID)
Select DistInct S.SchemeID,S.CS_SchemeID From tbl_mERP_SchemeAbstract S Where --s.SchemeID=pp.SchemeID
isnull(S.RFAApplicable,0) = 0
And S.ActiveTo < @OpeningDate

Insert Into #Temppayout(SchemeID,CS_SchemeID)
Select SchemeID,CS_SchemeID From tbl_mERP_SchemeAbstract Where Active =0 and ActiveTo > @OpeningDate

Delete From tbl_Merp_SchemeProductScopeMap Where SchemeID In (Select DistInct SchemeID From #Temppayout)
Delete From tbl_Merp_SchemeChannel Where SchemeID In (Select DistInct SchemeID From #Temppayout)
Delete From tbl_Merp_SchemeOutletClass Where SchemeID In (Select DistInct SchemeID From #Temppayout)
Delete From tbl_Merp_SchemeOutlet Where SchemeID In (Select DistInct SchemeID From #Temppayout)
Delete From tbl_Merp_SchemeLoyaltyList Where SchemeID In (Select DistInct SchemeID From #Temppayout)
Delete From tbl_Merp_SchemePayoutPeriod Where SchemeID In (Select DistInct SchemeID From #Temppayout)
Delete From tbl_Merp_SchemeSubGroup Where SchemeID In (Select DistInct SchemeID From #Temppayout)
Delete From tbl_Merp_SchemeFreeSKU Where SlabID In (Select SlabID From tbl_Merp_SchemeSlabDetail Where SchemeID In (Select DistInct SchemeID From #Temppayout))
Delete From tbl_Merp_SchemeSlabDetail Where SchemeID In (Select DistInct SchemeID From #Temppayout)
Delete From tbl_Merp_SchCategoryScope Where SchemeID In (Select DistInct SchemeID From #Temppayout)
Delete From tbl_Merp_SchMarketSKUScope Where SchemeID In (Select DistInct SchemeID From #Temppayout)
Delete From tbl_Merp_SchSKUCodeScope Where SchemeID In (Select DistInct SchemeID From #Temppayout)
Delete From tbl_Merp_SchSubCategoryScope Where SchemeID In (Select DistInct SchemeID From #Temppayout)
Delete From tbl_Merp_SchemeAbstract Where SchemeID In (Select DistInct SchemeID From #Temppayout)
Delete From SchemeCustomerItems Where SchemeID In (Select DistInct SchemeID From #Temppayout)
Delete From tbl_mERP_SchemeSale Where SchemeID In (Select DistInct SchemeID From #Temppayout)
Delete From SchemeCustomers Where SchemeID In (Select DistInct SchemeID From #Temppayout)
Delete From tbl_mERP_QPSDtlData Where SchemeID In (Select DistInct SchemeID From #Temppayout)
Delete From tbl_mERP_DispSchCapPerOutlet Where SchemeID In (Select DistInct SchemeID From #Temppayout)
Delete From tbl_mERP_DispSchBudgetPayout Where SchemeID In (Select DistInct SchemeID From #Temppayout)
Delete From tbl_mERP_QPSAbsData Where SchemeID In (Select DistInct SchemeID From #Temppayout)
Delete From SchemeItems Where SchemeID In (Select DistInct SchemeID From #Temppayout)
Delete From tbl_mERP_RecdSchProductScope Where CS_SchemeID In (Select DistInct CS_SchemeID From #Temppayout)
Delete From tbl_mERP_RecdDispSchCapPerOutlet Where CS_SchemeID In (Select DistInct CS_SchemeID From #Temppayout)
Delete From tbl_mERP_RecdSchAbstract Where CS_SchemeID In (Select DistInct CS_SchemeID From #Temppayout)
Delete From tbl_mERP_RecdSchSlabDetail Where CS_SchemeID In (Select DistInct CS_SchemeID From #Temppayout)
Delete From tbl_mERP_RecdSchChannel Where CS_SchemeID In (Select DistInct CS_SchemeID From #Temppayout)
Delete From tbl_mERP_RecdSchLoyaltyList Where CS_SchemeID In (Select DistInct CS_SchemeID From #Temppayout)
Delete From tbl_mERP_RecdSchOutlet Where CS_SchemeID In (Select DistInct CS_SchemeID From #Temppayout)
Delete From tbl_mERP_RecdSchOutletClass Where CS_SchemeID In (Select DistInct CS_SchemeID From #Temppayout)


--Delete From tbl_Merp_nonqpsdata Where SchemeID In (Select DistInct SchemeID From #Temppayout)
update tbl_Merp_rfaabstract set Status =100 Where documentid In (Select DistInct SchemeID From #Temppayout)
Delete From tbl_Merp_rfaxmlStatus Where replace(RFAID,'rfa','') In (Select rfadocid From tbl_Merp_rfaabstract Where Status=100)
Delete From tbl_Merp_rfadetail Where RFAID In (Select RFAID From tbl_Merp_rfaabstract Where Status=100)
Delete From tbl_Merp_rfaabstract Where Status=100
Delete From tbl_mERP_CSRedemption Where SchemeID In (Select DistInct SchemeID From #Temppayout)
Delete From tbl_mERP_OutletPoints Where SchemeID In (Select DistInct SchemeID From #Temppayout)
Delete From tbl_mERP_OutletPoints_NonQPS Where SchemeID In (Select DistInct SchemeID From #Temppayout)
Delete From SchemeProducts Where SchemeID In (Select DistInct SchemeID From #Temppayout)
Delete From SchemeProducts_log where CreationDate = dateadd(day,-90,getdate())

if Exists(Select * From Sys.Objects Where Type='U' and Name='tbl_Merp_QPSCrNoteLog')
Begin
Delete From dbo.tbl_Merp_QPSCrNoteLog Where SchemeID In (Select DistInct SchemeID From #Temppayout)
End

Delete From tbl_Merp_rfaxmlStatus Where creationdate  <  @OpeningDate
Delete From tbl_Merp_nonqpsdata Where Invoicedate  <  @OpeningDate
Delete From tblErrorLog Where CreationDate  <  @OpeningDate
Delete From tbl_mERP_AEAuditLog Where CreationTime  <  @OpeningDate
Delete From SyncError Where CREATIONDATE  <  @OpeningDate
Delete From DSFailVisitReasons Where UploadDate  <  @OpeningDate
Delete From tbl_mERP_RecdErrMessages Where ProcessDate  <  @OpeningDate
Delete From tbl_mERP_OLClassMapping Where CreationDate  <  @OpeningDate And isnull(Active ,0) = 0
Delete From tbl_mERP_CatHandler_Log Where CreationDate  <  @OpeningDate
Delete From Inbound_Log Where Date  <  @OpeningDate
Delete From tbl_mERP_RecdRptAckAbstract Where ReceivedDate  <  @OpeningDate

If(Select dbo.columnexists('PM_DS_Data','InvoiceDate'))=1
Begin
Delete From PM_DS_Data Where InvoiceDate  <  @OpeningDate
End

/* GGRR Data Removing Process */

Delete From GGDROutlet Where cast(('01-' + Todate) as dateTime) < @OpeningDate
Delete From GGDRProduct Where ProdDefnID Not in (Select Distinct ProdDefnID From GGDROutlet)
Delete From TmpGGDRSKUDetails Where ProdDefnID Not in (Select Distinct ProdDefnID From GGDROutlet)
Delete From GGDRData Where InvoiceDate < @OpeningDate
Delete From GGRRFinalData Where [Month] Not in (Select Distinct Fromdate [Month] From GGDROutlet Union Select Distinct Todate [Month] From GGDROutlet)
Delete From Recd_GGDROutlet Where isnull(Status,0) in (1,2)
Delete From Recd_GGDRProduct Where isnull(Status,0) in (1,2)
Delete From Recd_GGDR Where isnull(Status,0) <> 0

/* SKU OPT */
Delete From Recd_SKUPortfolio Where isnull(Status,0) in (1,2)

/* LP data */
Delete from LP_RecdAchievementDetail Where isnull(Status,0) in (1,2)
Delete from LP_RecdScoreDetail Where isnull(Status,0) in (1,2)
Delete from LP_RecdDocAbstract Where isnull(Status,0) in (1,2)

/*PM Master */
Declare @PMdate as DateTime
Declare @PMValue as Int
--	Set @PMValue = (Select Top 1 Isnull([value],0) From Config_DataPurging Where ProcessName = 'PM Master' And isnull(Active,0) = 1)
--	Set @PMdate = DateAdd(m,-(@PMValue), cast(('01/' + Cast((Month(Getdate())) as Nvarchar(10)) + '/' + Cast((Year(Getdate())) as Nvarchar(10))) as DateTime))

Delete From tbl_mERP_PMMaster Where Cast(('01-' + Period) as DateTime) < @OpeningDate
Delete From tbl_mERP_PMDSType Where PMID Not In (Select Distinct PMID From tbl_mERP_PMMaster)
Delete From tbl_mERP_PMParam Where DSTypeID Not In (Select Distinct DSTypeID From tbl_mERP_PMDSType)
Delete From tbl_mERP_PMParamFocus Where ParamID Not In (Select Distinct ParamID From tbl_mERP_PMParam)
Delete From tbl_mERP_PMParamSlab Where ParamID Not In (Select Distinct ParamID From tbl_mERP_PMParam)
Delete From tbl_mERP_PMetric_TargetDefn Where PMID Not In (Select Distinct PMID From tbl_mERP_PMMaster)

--Business Achievement Purge
Delete From PMOutlet where PMID Not In (Select Distinct PMID  from tbl_mERP_PMMaster)
--Total lines cut TLC Purge
Delete From PMOutletAchieve where PMID Not In (Select Distinct PMID  from tbl_mERP_PMMaster)

--SS
Declare @3MothsBackDate as DateTime
Declare @3Moths as int
select @3Moths = Isnull(Value,0) from Config_DataPurging where ProcessName ='PMOutlet'
--select @3MothsBackDate = DateAdd(d,+1,DateAdd(m,-(@3Moths),GETDATE()))
select @3MothsBackDate =  DATEADD(month, -@3Moths, DATEADD(month, DATEDIFF(month, 0, GETDATE()), 0))

--Delete From tbl_mERP_Recd_PMMaster Where isnull(Status,0) <> 0
select distinct  A.CPM_PMCode into #tmpRecdPMMaster from tbl_mERP_Recd_PMMaster A
join tbl_mERP_PMMaster B on A.CPM_PMCode =B.PMCode and A.Status <> 0 and cast(('01-' + B.Period ) as dateTime) < @3MothsBackDate

delete from tbl_mERP_Recd_PMMaster where CPM_PMCode in (select CPM_PMCode from #tmpRecdPMMaster )

Delete From tbl_mERP_Recd_PMDSType Where REC_PMID Not In (Select Distinct REC_PMID From tbl_mERP_Recd_PMMaster)
Delete From tbl_mERP_Recd_PMParam Where REC_DSID  Not In (Select Distinct REC_DSID From tbl_mERP_Recd_PMDSType)
Delete From tbl_mERP_Recd_PMParamFocus Where REC_ParamID  Not In (Select Distinct REC_ParamID From tbl_mERP_Recd_PMParam)
Delete From tbl_mERP_Recd_PMParamSlab Where REC_ParamID  Not In (Select Distinct REC_ParamID From tbl_mERP_Recd_PMParam)

select distinct A.PMCode into #tmpRecd_PMOLT from Recd_PMOLT A
join tbl_mERP_PMMaster B on A.PMCode =B.PMCode and cast(('01-' + B.Period ) as dateTime) < @3MothsBackDate

delete from Recd_PMOLT where PMCode IN (select PMCode from #tmpRecd_PMOLT)

--delete from Recd_PMOLT where creationdate < DATEADD(month, -@3Moths, DATEADD(month, DATEDIFF(month, 0, @OpeningDate), 0))
delete from Recd_PMOLT where creationdate < Cast(('01/' + Cast((Month(@OpeningDate)) as Nvarchar(10)) + '/' + Cast((Year(@OpeningDate)) as Nvarchar(10))) as DateTime)

select distinct A.PMCode into #tmpRecdPMOutletAchieve from Recd_PMOutletAchieve A
join  tbl_mERP_PMMaster B on A.PMCode =B.PMCode and cast(('01-' + B.Period ) as dateTime) < @3MothsBackDate

delete from Recd_PMOutletAchieve where PMCode IN (select PMCode from #tmpRecdPMOutletAchieve)

--delete from Recd_PMOutletAchieve where creationdate < DATEADD(month, -@3Moths, DATEADD(month, DATEDIFF(month, 0, @OpeningDate), 0))
delete from Recd_PMOutletAchieve where creationdate < Cast(('01/' + Cast((Month(@OpeningDate)) as Nvarchar(10)) + '/' + Cast((Year(@OpeningDate)) as Nvarchar(10))) as DateTime)

Delete From tbl_merp_PMOutletAch_TargetDefn Where PMID Not In (Select Distinct PMID From tbl_mERP_PMMaster)
Delete From tbl_merp_NOA_TargetDefn Where PMID Not In (Select Distinct PMID From tbl_mERP_PMMaster)
Delete From tbl_merp_NOA_TargetDefn_Detail Where TargetDefnID  Not In (Select Distinct TargetDefnID  From tbl_merp_NOA_TargetDefn)

--SS

Delete From tbl_mERP_RecdAELoginAbstract Where Isnull(Status,0) <> 0
Delete From tbl_mERP_RecdQuotationAbstract Where Isnull(Status,0) <> 0

/* Where InvoiceID Not in InvoiceAbstract */
Delete From SchemeSale Where InvoiceID Not in (Select Distinct InvoiceID From InvoiceAbstract)
Delete From tbl_mERP_RebateRate Where InvoiceID Not in (Select Distinct InvoiceID From InvoiceAbstract)

/* Retain data From last month data */
Declare @LastMonthFirstDate as DateTime
Set @LastMonthFirstDate = DateAdd(m,-1,('01/' + Cast((Month(Getdate())) as Nvarchar(10)) + '/' + Cast((Year(Getdate())) as Nvarchar(10))))
Delete From tbl_mERP_RecdRFAckAbstract Where ReceivedDate < @LastMonthFirstDate
Delete From tbl_mERP_RecdRFAckDetail Where RFAAbsID Not in (Select Distinct Id From tbl_mERP_RecdRFAckAbstract)

Delete From tbl_mERP_RecdDocAck Where CreationDateTime < @LastMonthFirstDate
Delete From tbl_mERP_AEActivity Where ActivityTimeStamp < @LastMonthFirstDate


--/* GST Tax Received tables purge*/
--	Delete From Recd_Tax Where Flag = 64 And CreationDate < @OpeningDate
--	Delete From Recd_TaxComponents Where TaxID Not In (Select Distinct ID From Recd_Tax )
--	Delete From Recd_ItemTaxMapping Where Status = 64 And CreationDate < @OpeningDate


/* Old Unused Tables */
If Exists(Select 'x' From Sys.Objects Where Type = 'U' and Name = 'tbl_mERP_Margin_Log')
Begin
Truncate Table tbl_mERP_Margin_Log
End
If Exists(Select 'x' From Sys.Objects Where Type = 'U' and Name = 'Schemes')
Begin
Truncate Table Schemes
End
If Exists(Select 'x' From Sys.Objects Where Type = 'U' and Name = 'ItemSchemes')
Begin
Truncate Table ItemSchemes
End

Drop Table #Temppayout
Drop Table #tmpRecdPMMaster
Drop Table  #tmpRecd_PMOLT
Drop Table #tmpRecdPMOutletAchieve
Out:
End
