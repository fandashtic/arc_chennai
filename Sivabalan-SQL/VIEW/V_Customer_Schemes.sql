CREATE VIEW [dbo].[V_Customer_Schemes]  
([SchemeID],[CustomerID],[AllotedAmount])  
AS  
	Select SBP.Schemeid,SBP.OutletCode,SBP.allocatedamount from tbl_mERP_SchemePayoutPeriod SPP 
	INNER JOIN tbl_mERP_DispSchBudgetPayout SBP
	ON SBP.PayoutPeriodID=SPP.ID and SBP.Schemeid=SPP.Schemeid
	WHERE  Convert(smalldatetime, Cast(convert(smalldatetime, getdate(), 103) as nvarchar(12))) 
	between SPP.PayoutPeriodFrom AND SPP.PayoutPeriodTo  

	UNION ALL
	Select Distinct [SchemeID],[CustomerID],[AllotedAmount] from dbo.mERP_fn_GetSchemeOutletDetails_HH()
