Create Procedure [dbo].[spr_PurGSTRWithSKUs](@Fromdate datetime,@Todate datetime,@UOM  nVarchar(20) )
As
Declare @UTGST_flag  int

select @UTGST_flag = isnull(flag,0) from tbl_merp_configabstract(nolock) where screencode = 'UTGST'

Set DATEFormat DMY
Create Table #TempPurTaxDet(
BillID_1 nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
BillID nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Invoice No.] nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
[OD NO.] nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Date]  datetime,
[Type] Varchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,
[VendorID] nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Vendor Name] nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
[GSTIN OF Vendor] nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,
[VendorStateCode] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Goods Value] Decimal(18,6),
[Discount] Decimal(18,6),
[Gross Value] Decimal(18,6),
[Tax Value] Decimal(18,6),
[Net Value] Decimal(18,6),
[Taxable Sales Value] Decimal(18,6),
[CGST Tax Rate] Decimal(18,6),
[CGST Tax Amount] Decimal(18,6),
[SGST Tax Rate] Decimal(18,6),
[SGST Tax Amount] Decimal(18,6),
[IGST Tax Rate] Decimal(18,6),
[IGST Tax Amount] Decimal(18,6),
[UTGST Tax Rate] Decimal(18,6),
[UTGST Tax Amount] Decimal(18,6),
[Cess Rate] Decimal(18,6),
[Cess Amount] Decimal(18,6),
[AddlCess Rate] Decimal(18,6),
[AddlCess Amount] Decimal(18,6)
)
-- PurChase

Select  BillID, Product_Code, Tax_Code ,SerialNo,
SGSTPer = Max(Case When TCD.TaxComponent_desc = 'SGST' Then ITC.Tax_Percentage Else 0 End),
SGSTAmt = Sum(Case When TCD.TaxComponent_desc = 'SGST' Then ITC.Tax_Value Else 0 End),
CGSTPer = Max(Case When TCD.TaxComponent_desc = 'CGST' Then ITC.Tax_Percentage Else 0 End),
CGSTAmt = Sum(Case When TCD.TaxComponent_desc = 'CGST' Then ITC.Tax_Value Else 0 End),
IGSTPer = Max(Case When TCD.TaxComponent_desc = 'IGST' Then ITC.Tax_Percentage Else 0 End),
IGSTAmt = Sum(Case When TCD.TaxComponent_desc = 'IGST' Then ITC.Tax_Value Else 0 End),
UTGSTPer = Max(Case When TCD.TaxComponent_desc = 'UTGST' Then ITC.Tax_Percentage Else 0 End),
UTGSTAmt = Sum(Case When TCD.TaxComponent_desc = 'UTGST' Then ITC.Tax_Value Else 0 End),
CESSPer = Max(Case When TCD.TaxComponent_desc = 'CESS' Then ITC.Tax_Percentage Else 0 End),
CESSAmt = Sum(Case When TCD.TaxComponent_desc = 'CESS' Then ITC.Tax_Value Else 0 End),
ADDLCESSPer = Max(Case When TCD.TaxComponent_desc = 'ADDL CESS' Then ITC.Tax_Percentage Else 0 End),
ADDLCESSAmt = Sum(Case When TCD.TaxComponent_desc = 'ADDL CESS' Then ITC.Tax_Value Else 0 End) Into #TempTaxDet
From GSTBillTaxComponents ITC
Join TaxComponentDetail TCD
On TCD.TaxComponent_code = ITC.Tax_Component_Code
Group By BillID, Product_Code, Tax_Code,SerialNo

Insert Into #TempPurTaxDet
Select Cast(BA.BillID as Nvarchar(255)) + ',' + cast(BD.TaxCode as Nvarchar(255)) + ',1',
CASE
WHEN BA.DocumentReference IS NULL THEN
BillPrefix.Prefix + CAST(BA.DocumentID AS nVARCHAR)
ELSE
BillAPrefix.Prefix + CAST(BA.DocumentID AS nVARCHAR)
END,
BA.InvoiceReference as "Invoice No." ,BA.ODNumber  as "OD NO.",
--Case When Isnull(BA.InvoiceReference,'') = '' Then BA.BillDate Else IAR.InvoiceDate  End ,
IsNull((Select InvoiceDate From InvoiceAbstractReceived Where InvoiceID = (Select Top 1 RecdInvoiceID from GRNAbstract where BillID = BA.BillID )),BA.BillDate),
'Purchase' as "Type",BA.VendorID ,
V.Vendor_Name "Vendor Name",BA.GSTIN as "GSTIN OF Vendor",
"VendorStateCode" = (Select Top 1 ForumStateCode From StateCode Where StateID = BA.FromStatecode ),
sum(BD.OrgPTS * BD.Quantity) as "Goods Value",
sum(BD.InvDiscAmount + BD.OtherDiscAmount) ,

sum(BD.Amount)  as "Gross Value",
sum(BD.TaxAmount )  as "Tax Value",
sum(BD.Amount + BD.TaxAmount)  as "Net Value",
sum(BD.Amount) as "Taxable Sales Value",
"CGST Tax Rate" = max(CGSTPer),
"CGST Tax Amount" = sum(CGSTAmt),
"SGST Tax Rate" = Case When isnull(T.CS_TaxCode,0) = 0 Then MAX(BD.TaxSuffered) Else max(SGSTPer) End,
"SGST Tax Amount" = Case When isnull(T.CS_TaxCode,0) = 0 Then sum(BD.TaxAmount) Else sum(SGSTAmt) End,
"IGST Tax Rate" = max(IGSTPer),
"IGST Tax Amount" = sum(IGSTAmt),
"UTGST Tax Rate" = max(UTGSTPer),
"UTGST Tax Amount" = sum(UTGSTAmt),
"Cess Rate" = max(CESSPer),
"Cess Amount" = sum(CESSAmt),
"AddlCess Rate" = max(ADDLCESSPer),
"AddlCess Amount" = sum(ADDLCESSAmt)
from BillAbstract BA Join BillDetail BD On BA.BillID = BD.BillID
Left Join #TempTaxDet TCD On TCD.BillID = BD.BillID and TCD.Product_Code =BD.Product_Code
and TCD.Tax_Code = BD.TaxCode and TCD.SerialNo = BD.Serial And IsNull(BA.GSTEnableFlag,0) = 1
--Left Join InvoiceAbstractReceived IAR On IAR.DocumentID =IsNull(BA.InvoiceReference,'')
Inner Join Tax T ON T.Tax_Code = BD.TaxCode 
join Vendors V On BA.VendorID = V.VendorID
Join VoucherPrefix BillPrefix On BillPrefix.TranID = N'BILL'
Join VoucherPrefix BillAPrefix On BillAPrefix.TranID = N'BILL AMENDMENT'

Where BA.BillDate between @FromDate and @ToDate
And (BA.Status & 192)=0
Group by BA.BillID ,BA.InvoiceReference ,BA.ODNumber ,BA.BillDate ,BA.VendorID,V.Vendor_Name ,BA.GSTIN ,BA.FromStatecode,
BD.TaxCode ,BA.DocumentID,BA.DocumentReference,BillPrefix.Prefix,BillAPrefix.Prefix,isnull(T.CS_TaxCode,0)


-- PurChase Return

Select  AdjustmentID , Product_Code, Tax_Code ,SerialNo,
SGSTPer = Max(Case When TCD.TaxComponent_desc = 'SGST' Then ITC.Tax_Percentage Else 0 End),
SGSTAmt = Sum(Case When TCD.TaxComponent_desc = 'SGST' Then ITC.Tax_Value Else 0 End),
CGSTPer = Max(Case When TCD.TaxComponent_desc = 'CGST' Then ITC.Tax_Percentage Else 0 End),
CGSTAmt = Sum(Case When TCD.TaxComponent_desc = 'CGST' Then ITC.Tax_Value Else 0 End),
IGSTPer = Max(Case When TCD.TaxComponent_desc = 'IGST' Then ITC.Tax_Percentage Else 0 End),
IGSTAmt = Sum(Case When TCD.TaxComponent_desc = 'IGST' Then ITC.Tax_Value Else 0 End),
UTGSTPer = Max(Case When TCD.TaxComponent_desc = 'UTGST' Then ITC.Tax_Percentage Else 0 End),
UTGSTAmt = Sum(Case When TCD.TaxComponent_desc = 'UTGST' Then ITC.Tax_Value Else 0 End),
CESSPer = Max(Case When TCD.TaxComponent_desc = 'CESS' Then ITC.Tax_Percentage Else 0 End),
CESSAmt = Sum(Case When TCD.TaxComponent_desc = 'CESS' Then ITC.Tax_Value Else 0 End),
ADDLCESSPer = Max(Case When TCD.TaxComponent_desc = 'ADDL CESS' Then ITC.Tax_Percentage Else 0 End),
ADDLCESSAmt = Sum(Case When TCD.TaxComponent_desc = 'ADDL CESS' Then ITC.Tax_Value Else 0 End) Into #TempPRTTaxDet
From PRTaxComponents ITC
Join TaxComponentDetail TCD
On TCD.TaxComponent_code = ITC.Tax_Component_Code
Group By AdjustmentID, Product_Code, Tax_Code,SerialNo

Insert Into #TempPurTaxDet
Select Cast(AR.AdjustmentID as Nvarchar(255)) + ',' + cast(ARD.Tax_Code as Nvarchar(255))+ ',2',Isnull(AR.GSTFullDocID, ''),'' ,''  as "OD NO.",AR.AdjustmentDate ,'Purchase Return' as "Type",AR.VendorID ,
V.Vendor_Name as "Vendor Name",AR.GSTIN as "GSTIN OF Vendor",
"VendorStateCode" = (Select Top 1 ForumStateCode From StateCode Where StateID = AR.ToStateCode),
sum(ARD.Rate  * ARD.Quantity) as "Goods Value",
0 as "Discount" ,
sum(ARD.Rate * ARD.Quantity)  as "Gross Value",
sum(ARD.TaxAmount )  as "Tax Value",
sum(ARD.Total_Value   )  as "Net Value",
sum(ARD.Rate * ARD.Quantity) as "Taxable Sales Value",
"CGST Tax Rate" = max(CGSTPer),
"CGST Tax Amount" = sum(CGSTAmt),
"SGST Tax Rate" = Case When isnull(T.CS_TaxCode,0) = 0 Then MAX(ARD.Tax) Else max(SGSTPer) End,
"SGST Tax Amount" = Case When isnull(T.CS_TaxCode,0) = 0 Then sum(ARD.TaxAmount) Else sum(SGSTAmt) End,
"IGST Tax Rate" = max(IGSTPer),
"IGST Tax Amount" = sum(IGSTAmt),
"UTGST Tax Rate" = max(UTGSTPer),
"UTGST Tax Amount" = sum(UTGSTAmt),
"Cess Rate" = max(CESSPer),
"Cess Amount" = sum(CESSAmt),
"AddlCess Rate" = max(ADDLCESSPer),
"AddlCess Amount" = sum(ADDLCESSAmt)
from AdjustmentReturnAbstract AR Join AdjustmentReturnDetail ARD On AR.AdjustmentID  = ARD.AdjustmentID
Left Join #TempPRTTaxDet TCD On TCD.AdjustmentID = ARD.AdjustmentID and TCD.Product_Code =ARD.Product_Code
and TCD.Tax_Code = ARD.Tax_Code and TCD.SerialNo = ARD.SerialNo  And IsNull(AR.GSTFlag,0) = 1
Inner Join Tax T ON T.Tax_Code = Isnull(ARD.Tax_Code,0)  
join Vendors V On AR.VendorID = V.VendorID
Where AR.AdjustmentDate  between @FromDate and @ToDate
And (Isnull(AR.Status,0) & 192) = 0
Group by AR.AdjustmentID ,AR.AdjustmentDate ,AR.VendorID,V.Vendor_Name ,AR.GSTIN ,AR.ToStateCode ,ARD.Tax_Code,
AR.GSTFullDocID,isnull(T.CS_TaxCode,0)


Select BillID_1,BillID ,[Invoice No.] ,[OD NO.] ,[Date]  ,[Type] ,[VendorID] ,[Vendor Name] ,[GSTIN OF Vendor] ,
[VendorStateCode] ,[Goods Value] ,[Discount] ,[Gross Value] ,
[Tax Value] ,[Net Value] ,[Taxable Sales Value],IsNull([CGST Tax Rate],0) [CGST Tax Rate] ,IsNull([CGST Tax Amount],0) [CGST Tax Amount] ,
"SGST Tax Rate" = Case When @UTGST_flag = 1 Then IsNull([UTGST Tax Rate],0) Else IsNull([SGST Tax Rate],0) End ,
"SGST Tax Amount" = Case When @UTGST_flag = 1 Then IsNull([UTGST Tax Amount],0) Else Isnull([SGST Tax Amount],0) End,
IsNull([IGST Tax Rate],0) [IGST Tax Rate] ,IsNull([IGST Tax Amount],0) [IGST Tax Amount] ,Isnull([Cess Rate],0) [Cess Rate],
Isnull([Cess Amount],0) [Cess Amount] ,IsNull([AddlCess Rate],0) [AddlCess Rate] ,Isnull([AddlCess Amount],0) [AddlCess Amount]
from #TempPurTaxDet Order by BillID


Drop table  #TempPurTaxDet
Drop table #TempTaxDet
Drop table #TempPRTTaxDet

