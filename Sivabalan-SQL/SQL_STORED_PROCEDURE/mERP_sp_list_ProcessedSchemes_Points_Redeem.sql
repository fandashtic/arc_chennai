Create procedure mERP_sp_list_ProcessedSchemes_Points_Redeem(@SchemeCode nVarChar(50), @FromDate DateTime, @ToDate DateTime, @FILTER INT = 0, @SchemeType Int = 4 )
As
Select CSAbstract.SchemeID,
CSAbstract.CS_RecSchID,
CSAbstract.ActivityCode,
CSAbstract.Description,
CSType.SchemeType,
CSAbstract.ActiveFrom,
CSAbstract.ActiveTo,
Case
  When dbo.StripTimeFromDate(getdate()) Between ActiveFrom And ActiveTo then 'Active'
  Else 'Expired' End 'Status'
From tbl_mERP_SchemeAbstract CSAbstract, tbl_mERP_SchemeType CSType
Where
 CSAbstract.Schemeid in 
(
select distinct schemeid from tbl_merp_schemepayoutperiod where dbo.StripTimeFromDate(PayoutPeriodFrom) >= @FromDate and 
--dbo.StripTimeFromDate(PayoutPeriodTo) <= @ToDate 
DateAdd(Day, DateDiff(d, dbo.StripTimeFromDate(CSAbstract.ActiveTo), dbo.StripTimeFromDate(CSAbstract.ExpiryDate)), dbo.StripTimeFromDate(PayoutPeriodTo)) < @ToDate 
and Active=1 --and status=0 
and DateAdd(Day, DateDiff(d, dbo.StripTimeFromDate(CSAbstract.ActiveTo), dbo.StripTimeFromDate(CSAbstract.ExpiryDate)), dbo.StripTimeFromDate(PayoutPeriodTo))  < DATEADD(D, 0, DATEDIFF(D, 0, GETDATE()))
)
 --CSAbstract.ActiveFrom Between @FromDate And @ToDate 
 And CSType.ID=@SchemeType and CSType.ID  = CSAbstract.SchemeType And
 CSAbstract.CS_RecSchID = Case @SchemeCode When N'%' Then CSAbstract.CS_RecSchID Else @SchemeCode End
 --And dbo.StripTimeFromDate(CSAbstract.ActiveFrom) <= (Select Top 1 dbo.StripTimeFromDate(Transactiondate) From Setup)
 And CSAbstract.Active = Case @FILTER WHEN 0 THEN CSAbstract.Active WHEN 1 THEN 1 WHEN 2 THEN 0 END
Order by
 CSAbstract.CS_RecSchID
