CREATE PROCEDURE mERP_sp_List_RecedInvoice
(
@VendorID nVarChar(50),
@FromDate DateTime,
@ToDate DateTime,
@Filter Int=0,
@FromDocID Int=0,
@ToDocID Int=0
)
AS
If @FromDocID = 0
Select 
"TAG" = InvRA.InvoiceID, 
"VendorName" = V.Vendor_Name,
"InvoiceNo" = InvRA.DocumentID,
"Date" = InvRA.InvoiceDate,
"Value" = InvRA.NetValue,
"Status" = Case When IsNull(InvRA.Status,0) & 1 = 0 Then (Case When IsNull(InvRA.Status,0) & 32 = 0 Then 'Open' Else 'Partial' End) When IsNull(InvRA.Status,0) & 1 <> 0 Then 'Closed' Else 'Unknown' End,
"VendorID" = InvRA.VendorID,
"BillID" = (Select Max(BillID) from GRNAbstract Where RecdInvoiceID =  InvRA.InvoiceID And IsNull(GRNStatus,0) & 96 = 0),
"BillDocID" = (Select DocumentID From BillAbstract Where BillID = (Select Max(BillID) from GRNAbstract Where RecdInvoiceID =  InvRA.InvoiceID And IsNull(GRNStatus,0) & 96 = 0)),
"BillDate" = (Select BillDate From BillAbstract Where BillID = (Select Max(BillID) From GRNAbstract Where RecdInvoiceID =  InvRA.InvoiceID And IsNull(GRNStatus,0) & 96 = 0))
,"TaxType"=TaxType
,"GSTFlag"=GSTFlag
,"StateType"=StateType
,"FromStatecode"=FromStatecode
,"ToStatecode"=ToStatecode
,"GSTIN"=InvRA.GSTIN
,"ODNumber" = InvRA.ODNumber
From InvoiceAbstractReceived InvRA, Vendors V
Where InvRA.VendorID LIKE @VendorID
And IsNull(InvRA.Status,0) & 1 = 0 And IsNull(InvRA.Status,0) & 32 = (Case @Filter When 1 Then 0 When 2 Then 32 Else (IsNull(InvRA.Status,0) & 32) End) 
And IsNull(InvRA.Status,0) & 64 = 0
And InvRA.InvoiceDate Between @FromDate and @ToDate
And InvRA.VendorID = V.VendorID
Else
Select 
"TAG" = InvRA.InvoiceID, 
"VendorName" = V.Vendor_Name,
"InvoiceNo" = InvRA.DocumentID,
"Date" = InvRA.InvoiceDate,
"Value" = InvRA.NetValue,
"Status" = Case When IsNull(InvRA.Status,0) & 1 = 0 Then (Case When IsNull(InvRA.Status,0) & 32 = 0 Then 'Open' Else 'Partial' End) When IsNull(InvRA.Status,0) & 1 <> 0 Then 'Closed' Else 'Unknown' End,
"VendorID" = InvRA.VendorID, 
"BillID" = (Select Max(BillID) from GRNAbstract Where RecdInvoiceID =  InvRA.InvoiceID And IsNull(GRNStatus,0) & 96 = 0),
"BillDocID" = (Select DocumentID From BillAbstract Where BillID = (Select Max(BillID) from GRNAbstract Where RecdInvoiceID =  InvRA.InvoiceID And IsNull(GRNStatus,0) & 96 = 0)),
"BillDate" = (Select BillDate From BillAbstract Where BillID = (Select Max(BillID) From GRNAbstract Where RecdInvoiceID =  InvRA.InvoiceID And IsNull(GRNStatus,0) & 96 = 0))
,"TaxType"=TaxType
,"GSTFlag"=GSTFlag
,"StateType"=StateType
,"FromStatecode"=FromStatecode
,"ToStatecode"=ToStatecode
,"GSTIN"=InvRA.GSTIN
,"ODNumber" = InvRA.ODNumber
From InvoiceAbstractReceived InvRA, Vendors V
Where InvRA.VendorID LIKE @VendorID
And IsNull(InvRA.Status,0) & 1 = 0 And IsNull(InvRA.Status,0) & 32 = (Case @Filter When 1 Then 0 When 2 Then 32 Else (IsNull(InvRA.Status,0) & 32) End) 
And IsNull(InvRA.Status,0) & 64 = 0
And dbo.GetTrueVal(DocumentID) Between @FromDocID And @ToDocID
And InvRA.VendorID = V.VendorID
