create Procedure mERP_sp_RFApointschPrint(@RFADocID as nVarchar(2550))
As
Create Table #tempPointSchAbstract(RFAID Int,RFADocID nVarchar(255),DocumentID nVarchar(255),Activity_Code nVarchar(255),[Description] nVarchar(255),
Applicable_Period nVarchar(255),RFA_Period nVarchar(255),RFA_Value Decimal(18,6))
Create Table #tempPointSchDetail(Outlet_Code nVarchar(255),Name_of_Outlet nVarchar(255),Total_Points decimal(18,6), Redeemed_Value Decimal(18,6),Redeemed_Points Decimal(18,6),Amount_Spent Decimal(18,6))

------ Point Scheme Abstract


Insert into #tempPointSchAbstract
Select "RFAID" = [RFAID],
"RFADocID" = RFADocID,
"DocumentID" = DocumentID,
"Activity_Code" = ActivityCode,
"Description" = [Description],
"Applicable_Period" = (Convert(varchar, ActiveFrom, 103) + ' - ' + Convert(varchar, ActiveTo, 103)),
"RFA_Period" = (Convert(varchar, PayoutFrom, 103) + ' - ' + Convert(varchar, PayoutTo, 103)),
"RFA_Value" = Sum(RebateValue)
From tbl_mERP_RFAAbstract
Where SchemeType = 'Points'
And RFADocID = (@RFADocID)
And Isnull(Status,0)<>5
Group By RFAID, DocumentID, RFADocID, ActivityCode, [Description],ActiveFrom, ActiveTo, PayoutFrom, PayoutTo

------- Point Scheme Detail


declare @schemeid int
declare @payoutid int
set @schemeid=(select top 1 Documentid From tbl_merp_rfaabstract Where RFADocID = @RFADocID)
set @Payoutid = (select id from tbl_merp_schemepayoutperiod where schemeid=@schemeid and 
payoutperiodfrom=(select top 1 PayoutFrom from tbl_merp_rfaabstract Where RFADocID = @RFADocID)
and payoutperiodto = (select top 1 Payoutto from tbl_merp_rfaabstract Where RFADocID = @RFADocID)
)


Insert into #tempPointSchDetail
Select Distinct
"Outlet_Code" = CSR.OutletCode,
"Name_of_Outlet" = C.Company_Name,
"Total_Points" = CSR.TotalPoints,
"Redeemed_Value" = CSR.RedeemValue,
"Redeemed_Points" = CSR.RedeemedPoints,
"Amount_Spent" = CSR.AmountSpent
From tbl_mERP_CSRedemption CSR, Customer C
Where C.CustomerID = CSR.OutletCode
And Schemeid = @schemeid and payoutid=@payoutid and rfastatus =1

Select Activity_Code,[Description],Applicable_Period,RFA_Period,sum(isnull(RFA_Value,0)) RFA_Value From #tempPointSchAbstract
group by Activity_Code,[Description],Applicable_Period,RFA_Period
Select Outlet_Code,Name_of_Outlet,Total_points,Redeemed_Value,Redeemed_Points,Amount_Spent From #tempPointSchDetail

Drop table #temppointSchAbstract
Drop table #tempPointSchDetail


SET QUOTED_IDENTIFIER OFF 
