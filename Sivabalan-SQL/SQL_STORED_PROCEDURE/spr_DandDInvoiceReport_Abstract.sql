CREATE Procedure spr_DandDInvoiceReport_Abstract
(
@FromDate Datetime ,
@ToDate Datetime
)
AS
BEGIN
Declare @UTGSTFlag int
Set dateformat DMY

Select @UTGSTFlag = Isnull(Flag, 0) From tbl_merp_ConfigAbstract Where ScreenCode = 'UTGST' -- UTGST flag

Select InvAbs.* Into #TempDandDInvAbs From DandDInvAbstract InvAbs(Nolock)
Where dbo.StripDateFromTime(InvAbs.DandDInvDate) Between dbo.StripDateFromTime(@FromDate) and dbo.StripDateFromTime(@ToDate)
And (InvAbs.Status & 128) = 0 -- DandDinvabstract (tbl)

Select InvDet.* Into #TmpDandDInvDet From #TempDandDInvAbs DA
Join DandDInvDetail InvDet ON DA.DandDInvID = InvDet.DandDInvID  --- DandDInvabstract & DandDInvDetail (Join)

-- select
Select  DA.DandDInvID,
"InvoiceNo" = IsNull(DA.GSTFullDocID,0),
"InvoiceDate" = DA.DandDInvDate,
"DeliveryChallanNo" = IsNull(DAbs.DocumentID,0),
--"CustomerID" = 'ITC001Outlet',
--"CustomerName" = 'ITC Limited',
"CustomerID" = isnull(DAbs.CustomerID,''),
"CustomerName" = isnull(DAbs.CustomerName,''),
"GSTINoftheCustomer" = ISNULL(DA.GSTIN,''),
"TypeofInvoice" = Case When DA.FromStateCode = DA.ToStateCode then 'Intra' Else 'Inter' End,
"GoodsValue" = (Select Sum(RFAQuantity * PTS) From DandDDetail  Where DandDDetail.ID = DAbs.ID) ,
"DiscountValue" = SUM(ISNULL(DD.SalvageValue,0)),
"TaxableValue" = SUM(ISNULL(DD.TaxableValue,0)),
"TaxValue" = SUM(ISNULL(DD.TotalTaxAmount,0)),
"InvoiceValue" = SUM(ISNULL(DD.RebateValue,0)),
"IGSTAmount" = SUM(IsNull(DD.IGSTAmount,0)),
"CGSTAmount" = SUM(IsNull(DD.CGSTAmount,0)),
"SGSTAmount" = SUM(IsNull(DD.SGSTAmount,0)),
"CessAmount" = Sum(IsNull(DD.CessAmount,0)) + SUM(ISNULL(DD.AddlCessAmount,0)),
"Invoice Creation Date" = DA.CreationDate
Into #TempFinal
From #TempDandDInvAbs DA
Inner Join #TmpDandDInvDet DD ON DA.DandDInvID = DD.DandDInvID
Inner Join DandDAbstract DAbs ON DA.ClaimID = DAbs.ClaimID
Group By DA.DandDInvID,DA.GSTFullDocID,DA.DandDInvDate,DA.GSTIN,DA.FromStateCode,DA.ToStateCode,DAbs.DocumentID,
isnull(DAbs.CustomerID,''),isnull(DAbs.CustomerName,''),DD.TaxCode,DAbs.ID,DA.CreationDate



-- Final o/p
Select DandDInvID,"Invoice No" = InvoiceNo , "Invoice Date" = InvoiceDate,"Delivery Challan No" = DeliveryChallanNo ,"Customer ID" = CustomerID ,
"Customer Name" = CustomerName,"GSTIN of the Customer" = GSTINoftheCustomer ,"Type of Invoice" = TypeofInvoice ,
"Goods Value" = GoodsValue, "Discount Value" =SUM(DiscountValue) ,"Taxable Value" =SUM(TaxableValue) ,"Tax Value" = SUM(TaxValue),
"Invoice Value" =SUM(InvoiceValue) ,"IGSTAmount" = SUM(IGSTAmount),"CGSTAmount" = SUM(CGSTAmount),"SGSTAmount" = SUM(SGSTAmount),
"CessAmount" = SUM(CessAmount),
"Invoice Creation Date" = [Invoice Creation Date]
From #TempFinal
Group by DandDInvID,InvoiceNo,InvoiceDate,DeliveryChallanNo,GSTINoftheCustomer,TypeofInvoice,CustomerID,CustomerName,GoodsValue,[Invoice Creation Date]


IF OBJECT_ID('tempdb..#TempDandDInvAbs') IS NOT NULL
Drop Table #TempDandDInvAbs
IF OBJECT_ID('tempdb..#TmpDandDInvDet') IS NOT NULL
Drop Table #TmpDandDInvDet
IF OBJECT_ID('tempdb..#TempFinal') IS NOT NULL
Drop Table #TempFinal

END
