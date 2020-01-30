Create Procedure [dbo].[mERP_spr_ServiceInvoice_Outward]
(
@FromDate Datetime,
@Todate Datetime
)
As
Begin
--Declare @FromDate Datetime
--Declare @Todate Datetime
--Set dateformat dmy
--Set @FromDate = '14-08-2018 00:00:00'
--Set @Todate = '14-08-2018 23:59:59'

Declare @WDTINNumber nVarchar(50)

Select * Into #TempServiceAbstract from ServiceAbstract
Where TransactionDate Between @FromDate And @Todate
And Isnull(Status,0) & 4 = 0
And ServiceType = 'Outward'

--Tax Details
Select  InvoiceID, serviceCodeid, SerialNo,
SGSTPer = Max(Case When TCD.TaxComponent_desc = 'SGST' Then ITC.Tax_Percentage Else 0 End),
SGSTAmt = Sum(Case When TCD.TaxComponent_desc = 'SGST' Then ITC.TaxSplitup Else 0 End),
CGSTPer = Max(Case When TCD.TaxComponent_desc = 'CGST' Then ITC.Tax_Percentage Else 0 End),
CGSTAmt = Sum(Case When TCD.TaxComponent_desc = 'CGST' Then ITC.TaxSplitup Else 0 End),
IGSTPer = Max(Case When TCD.TaxComponent_desc = 'IGST' Then ITC.Tax_Percentage Else 0 End),
IGSTAmt = Sum(Case When TCD.TaxComponent_desc = 'IGST' Then ITC.TaxSplitup Else 0 End),
UTGSTPer = Max(Case When TCD.TaxComponent_desc = 'UTGST' Then ITC.Tax_Percentage Else 0 End),
UTGSTAmt = Sum(Case When TCD.TaxComponent_desc = 'UTGST' Then ITC.TaxSplitup Else 0 End),
CESSPer = Max(Case When TCD.TaxComponent_desc = 'CESS' Then ITC.Tax_Percentage Else 0 End),
CESSAmt = Sum(Case When TCD.TaxComponent_desc = 'CESS' Then ITC.TaxSplitup Else 0 End),
ADDLCESSPer = Max(Case When TCD.TaxComponent_desc = 'ADDL CESS' Then ITC.Tax_Percentage Else 0 End),
ADDLCESSAmt = Sum(Case When TCD.TaxComponent_desc = 'ADDL CESS' Then ITC.TaxSplitup Else 0 End),
ITC.MapTaxId
Into #TmpserviceTaxDet
From ServiceInvoicesTaxSplitup ITC
Inner Join TaxComponentDetail TCD ON TCD.TaxComponent_code = ITC.TaxComponent
Where InvoiceID in(Select InvoiceID From #TempServiceAbstract)
Group By InvoiceID, serviceCodeid,SerialNo, ITC.MapTaxId



Select @WDTINNumber = GSTIN from Setup

Select 1,
"Tax Period" = CONVERT (CHAR(2), TransactionDate, 101) + CONVERT(CHAR(4), TransactionDate, 120)
,"GSTIN of Supplier" = @WDTINNumber
,"GSTIN of Recipient" = SA.GSTIN
,"State of Recipient" = ReceipientSC
,"Bill to State Code" = Case When ServiceFor = 1 Then
(Select BillingStateID from Vendors Where VendorID = SA.Code)
Else
(Select BillingStateID from Customer Where Customerid = SA.Code)
End
,"Ship To State Code" = Case When ServiceFor = 1 Then
(Select BillingStateID from Vendors Where VendorID = SA.Code)
Else
(Select ShippingStateID from Customer Where Customerid = SA.Code)
End

,"Place of Supply" =  Right(ReceipientSC, LEN(ReceipientSC) - 4)
,"Transaction Type" = TransactionType
,"Party Code" = Code
,"Party Name" = SelectReceipient
,"Supply Type" = ''
,"Document Type" = ''
,"Reverse Charge" = Case When ReverseChargeApplicable = 0 Then 'N' Else 'Y' End
,"Document No." = DocumentID
,"Document Date" = Transactiondate
,"Original Document No." = ''
,"Original Document Date" = ''
,"Cr/Dr Pre GST" = 'NA'
,"SAC" = ServiceCode
,"Service Type" = ServiceName
,"Description of Services" = Remarks
,"Invoice Value" = TotalNetAmount
,"Taxable Value" = TaxableValue
,"Total Tax Value" = Tax_Amount
,"Net Value" = Net_Amount
,"GST Rate" = Isnull(SGSTPer,0)+Isnull(CGSTPer,0)+Isnull(IGSTPer,0)
,"CGST Amount" = Isnull(CGSTAmt,0)
,"SGST Amount" = Isnull(SGSTAmt,0)
,"IGST Amount" = Isnull(IGSTAmt,0)
,"Cess(Adval Cess)" = Isnull(CESSPer,0)
,"Cess(Specific Cess)" = Isnull(CESSAmt,0)
from #TempServiceAbstract SA
Inner Join #TmpserviceTaxDet ST On SA.InvoiceId =  ST.InvoiceID
Inner Join ServiceDetails SD ON SA.InvoiceId = SD.InvoiceId And SD.SerialNo = ST.serialno And SD.MapTaxId = ST.MapTaxId And SD.serviceCodeid = ST.serviceCodeid
--Where TransactionDate Between @FromDate And @Todate
Where ServiceType = 'Outward'


Drop table #TempServiceAbstract
Drop table #TmpserviceTaxDet
End
