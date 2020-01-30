Create Procedure mERP_sp_GenerateDandD_XML(@DandDID as int)
As
Begin
Declare @WDCode NVarchar(255)
Declare @WDDest NVarchar(255)
Declare @CompaniesToUploadCode NVarchar(255)

Select Top 1 @CompaniesToUploadCode=ForumCode From Companies_To_Upload
Select Top 1 @WDCode = RegisteredOwner From Setup

If @CompaniesToUploadCode = N'ITC001'
Set @WDDest= @WDCode
Else
Begin
Set @WDDest= @WDCode
Set @WDCode= @CompaniesToUploadCode
End

Declare @DanDInvID Int
Select @DanDInvID = DandDInvoiceID From DandDAbstract Where ID = @DandDID

Select SystemSKU as 'RFAUnqID' ,@WDCode as 'WDCode',@WDDest 'WDDestCode', DDIA.GSTFullDocID  'RFADocID',
SchemeType,ActivityCode,Description,ActiveFrom,ActiveTo,PayoutFrom,
PayoutTo,Division,SubCategory,MarketSKU,SystemSKU,UOM,SaleQty,SaleValue, SalvageQty, SalvageValue, '0' as PromotedQty,
'0' as PromotedValue,'' as FreeBaseUOM,'0' as RebateQty,RebateValue,'0' as BudgetedQty,'0' as BudgetedValue,SubmissionDate, '' as AppOn ,
'DI'+ Cast(GSTDOCID as nvarchar) 'RFAID',IsNull(DamageOption,'') as 'DamageOption', Case When GreenDandD =1 Then 'Yes' Else 'No' End as 'GreenDandD' ,
[TotalTaxAmount] as 'TotalTaxAmount',[CGSTRate] as 'CGSTRate',[CGSTAmount] as 'CGSTAmount',[SGSTRate] as 'SGSTRate',[SGSTAmount] as 'SGSTAmount',
[IGSTRate] as 'IGSTRate',[IGSTAmount] as 'IGSTAmount',[CessRate] as 'CessRate',[CessAmount] as 'CessAmount',[AddlCessRate] as 'AddlCessRate',[AddlCessAmount] as 'AddlCessAmount'
,IsNull([CCESSRate],0) as 'CCESSRate',IsNull([CCESSAmount],0) as 'CCESSAmount'
Into #tmpRFAAbs
From DandDInvAbstract DDIA
Join DandDInvDetail DDID On DDIA.DandDInvID = DDID.DandDInvID
Where DDIA.DandDInvID = @DanDInvID

Create Table #tmpRFA(RFAUnqID nVarChar(30) COLLATE SQL_Latin1_General_CP1_CI_AS)
Insert Into #tmpRFA
Select Distinct RFAUnqID from #tmpRFAAbs

/* This table is used to link the abstract and the detail record*/
--Create Table #tmpRFA(RFAUnqID Int)
--Insert Into #tmpRFA
--Select Distinct RFAID From tbl_mERP_RFAAbstract Where RFADocID = @RFADocID

/* Get The Abstract Data */
--Select RFAID 'RFAUnqID' ,@WDCode as 'WDCode',@WDDest 'WDDestCode','RFA'+ Cast(RFADocID as nvarchar) 'RFADocID',
--   SchemeType,ActivityCode,Description,ActiveFrom,ActiveTo,PayoutFrom,
--   PayoutTo,Division,SubCategory,MarketSKU,SystemSKU,UOM,SaleQty,SaleValue, SalvageQty, SalvageValue, PromotedQty,
--   PromotedValue,FreeBaseUOM,RebateQty,RebateValue,BudgetedQty,BudgetedValue,SubmissionDate, AppOn ,
--'RFA'+ Cast(RFAID as nvarchar) 'RFAID',IsNull(DamageOption,'') as 'DamageOption'
--Into #tmpRFAAbs
--From tbl_mERP_RFAAbstract
--Where RFADocID = @RFADocID

--/* Get The Detail Data */
--Select RFADet.RFAID 'RFAUnqID',@WDCode as 'WDCode' ,@WDDest as 'WDDestCode' ,'RFA'+ Cast(@RFADocID as nvarchar) as 'RFADocID',
--   RFADet.ActivityCode,RFADet.CSSchemeID,RFADet.Description,RFADet.ActiveFrom,RFADet.ActiveTo,RFADet.BillRef,RFADet.DocNo,RFADet.CustomerID,RFADet.RCSID,RFADet.ActiveInRCS,LineType
--   ,RFADet.Division,RFADet.SubCategory,RFADet.MarketSKU,RFADet.SystemSKU,RFADet.UOM,RFADet.SaleQty,RFADet.SaleValue,RFADet.PromotedQty,
--   RFADet.PromotedValue,RFADet.RebateQty,RFADet.RebateValue,
--   Price_Excl_Tax,Tax_Percentage,Tax_Amount,Price_Incl_Tax,
--   RFADet.BudgetedQty,RFADet.BudgetedValue,Cust.Company_Name,'RFA'+ Cast(RFADet.RFAID as nvarchar)as  'RFAID'
--   ,isnull(RDR.Reason,'') as Reason
--Into #tmpRFADet
--   From tbl_mERP_RFAAbstract RFAAbs join tbl_mERP_RFADetail RFADet on RFAAbs.RFAID = RFADet.RFAID
--   join Customer Cust on RFADet.CustomerID = Cust.CustomerID
--   Left join (
--	Select Distinct RFAID, CSSchemeID, RFAReason,Reason
--	From tbl_mERP_RFADet_Reason X
--	Join tbl_mERP_RFASubmission_Reason RFARea on RFARea.ReasonID = X.RFAReason
--	) RDR on RDR.RFAID = RFADet.RFAID and RDR.CSSchemeID = RFADet.CSSchemeID
--   where RFAAbs.RFADocID = @RFADocID

Select 'RFAInfo' as 'RFA',
(Select WDCode as 'WDCODE',WDDestCode as 'WDDEST',RFADocID as 'RFA_ID',
SchemeType as 'SCHEMETYPE',ActivityCode as 'ACTIVITY_CODE',Description as 'ACTIVITY_DESC',ActiveFrom as 'ACTIVITY_PERIOD_FROM',ActiveTo as 'ACTIVITY_PERIOD_TO',PayoutFrom as 'PAYOUT_PERIOD_FROM',
PayoutTo as 'PAYOUT_PERIOD_TO',Division as 'DIVISION',SubCategory as 'SUB_CATEGORY',MarketSKU as 'MARKETSKU',SystemSKU as 'SKU_CODE',UOM,SaleQty as 'SALE_QTY',SaleValue as 'SALE_VALUE',
SalvageQty AS 'SALVAGE_QTY', SalvageValue As 'SALVAGE_VALUE', PromotedQty as 'PROMOTED_QTY',
PromotedValue as 'PROMOTED_VALUE',FreeBaseUOM as 'FREE_BASE_UOM',RebateQty as 'REBATE_QTY',RebateValue as 'REBATE_VALUE',BudgetedQty as 'BUDGETED_QTY',BudgetedValue as 'BUDGETED_VALUE',SubmissionDate as 'SUBMITTED_ON', AppOn  as 'APPL_ON',
DamageOption as 'DAMAGE_OPTION', GreenDandD As 	'GreenDandD' ,
TotalTaxAmount as 'TotalTaxAmount',CGSTRate as 'CGSTRate',CGSTAmount as 'CGSTAmount',SGSTRate as 'SGSTRate',SGSTAmount as 'SGSTAmount',
IGSTRate as 'IGSTRate',IGSTAmount as 'IGSTAmount',CessRate as 'CessRate',CessAmount as 'CessAmount',AddlCessRate as 'AddlCessRate',AddlCessAmount as 'AddlCessAmount'
, IsNull(CCESSRate,0) as 'CCESSRate', IsNull(CCESSAmount,0) as 'CCESSAmount'
From #tmpRFAAbs RFAHeader Where RFAHeader.RFAUnqID = RFAInfo.RFAUnqID
For XML Auto, Type)--,
--(Select WDCode as 'WDCODE',WDDestCode  as 'WDDEST',RFADocID as 'RFA_ID',
--   ActivityCode as 'ACTIVITY_CODE',CSSchemeID as 'COMP_SCHEME_ID',Description as 'ACTIVITY_DESC',
--ActiveFrom as 'ACTIVITY_PERIOD_FROM',ActiveTo as 'ACTIVITY_PERIOD_TO',BillRef as 'BILL_REF',DocNo as 'DOC_NO' ,CustomerID as 'OUTLET_CODE',
--RCSID as 'RCS_ID' ,ActiveInRCS as 'ACTIVE_IN_RCS',LineType as 'LINE_TYPE', Division as 'DIVISION',
--SubCategory as 'SUB_CATEGORY',MarketSKU as 'MARKETSKU',SystemSKU as 'SKU_CODE',UOM,SaleQty as 'SALE_QTY',SaleValue as 'SALE_VALUE',
--PromotedQty as 'PROMOTED_QTY', PromotedValue as 'PROMOTED_VALUE',RebateQty as 'REBATE_QTY',RebateValue as 'REBATE_VALUE',
--   Price_Excl_Tax as 'PRICE_EXCL_TAX',Tax_Percentage as 'TAX_PERCENTAGE',Tax_Amount as 'TAX_AMOUNT',Price_Incl_Tax as 'PRICE_INC_TAX',
--   BudgetedQty as 'BUDGETED_QTY',BudgetedValue as 'BUDGETED_VALUE', Case when isnull(Reason,'') = '' then '' else isnull(Reason,'') End as 'RFA_REASON'
--From #tmpRFADet RFADetail Where RFADetail.RFAUnqID =RFAInfo.RFAUnqID
--For XML Auto , Type
--)
From #tmpRFA RFAInfo
For XML Auto,Root('Root')

End
