CREATE PROCEDURE mERP_sp_List_Bill
(
@VendorID nVarChar(50),
@FromDate DateTime,
@ToDate DateTime,
@FromDocID Int=0,
@ToDocID Int=0,
@SelMode Int=0 -- NoUse
)
AS
Declare @GRNPreFix nVarChar(50)
Declare @BPreFix nVarChar(50)
Declare @BAPreFix nVarChar(50)

SELECT @GRNPreFix = Prefix FROM VoucherPrefix WHERE TranID = N'GOODS RECEIVED NOTE'
SELECT @BPreFix = Prefix FROM VoucherPrefix WHERE TranID = N'BILL'
SELECT @BAPreFix = Prefix FROM VoucherPrefix WHERE TranID = N'BILL AMENDMENT'

Create Table #BillList (BillID Int, DocType Int)
Create Table #FromGRNList (BillID Int)

Create Table #GRNBills 
(BillID Int, GRNID Int, DocType Int, VendorID nVarchar(15), VendorName nVarchar(50), BillNumber nVarChar(50) , GRNNumber nVarchar(50),
Date DateTime, DocValue Decimal(18,6), Balance Decimal(18,6), BillGRNID nVarChar(255),Locality Int,RecdInvID Int, BGStatus Int, DocIDRef nVarChar(510),BillReference Int
,TaxType Int,GSTFlag Int,StateType Int,FromStateCode Int,ToStateCode Int,GSTIN nVarChar(15), ODNumber nVarChar(50) )

If @FromDocID = 0
Begin

	Insert Into #BillList
	Select BillID, 1  From GRNAbstract G, Vendors V
	Where G.VendorID Like @VendorID
	And IsNull(BillID,0) > 0
	And IsNull(RecdInvoiceID,0) = 0
	And G.VendorID = V.VendorID
	And BillID In (Select BillID From BillAbstract Where VendorID Like @VendorID And BillDate Between @FromDate and @ToDate)
	Group By BillID
	Having Count(GRNID) = 1 

	Insert Into #FromGRNList
	Select BillID From BillAbstract
	Where GRNID in 
	(Select Cast(GRNID As nVarChar) From GRNAbstract G, Vendors V
	Where G.VendorID Like @VendorID
	And IsNull(BillID,0) > 0
	And IsNull(RecdInvoiceID,0) = 0
	And G.VendorID = V.VendorID
	And BillID In (Select BillID From BillAbstract Where VendorID Like @VendorID And BillDate Between @FromDate and @ToDate)
	Group By GRNID
	Having Count(GRNID) = 1 )

	Insert Into #BillList
	Select BillID, 1  From GRNAbstract G, Vendors V, InvoiceAbstractReceived IAR
	Where G.VendorID Like @VendorID
	And IsNull(BillID,0) > 0
	And IsNull(RecdInvoiceID,0) > 0
	And IsNull(IAR.Status,0) & 1 <> 0
	And G.VendorID = V.VendorID
	And IAR.InvoiceID = G.RecdInvoiceID
	And BillID In (Select BillID From BillAbstract Where VendorID Like @VendorID And BillDate Between @FromDate and @ToDate)
	Group By BillID
	Having Count(GRNID) = 1 
	
	Insert Into #BillList
	Select BillID, 2  From GRNAbstract G, Vendors V, InvoiceAbstractReceived IAR
	Where G.VendorID Like @VendorID
	And IsNull(BillID,0) > 0
	And IsNull(RecdInvoiceID,0) > 0
	And IsNull(IAR.Status,0) & 1 = 0
	And G.VendorID = V.VendorID
	And IAR.InvoiceID = G.RecdInvoiceID
	And BillID In (Select BillID From BillAbstract Where VendorID Like @VendorID And BillDate Between @FromDate and @ToDate)
--	And (
--	(BillID In (Select BillID From BillAbstract Where VendorID Like @VendorID And BillDate Between @FromDate and @ToDate))
--	OR
--	(GRNDate Between @FromDate and @ToDate)
--	)
	Group By BillID
	Having Count(GRNID) = 1 
	
	Insert Into #BillList
	Select BillID, 2 From GRNAbstract G, Vendors V
	Where G.VendorID Like @VendorID
	And IsNull(BillID,0) > 0
	And G.VendorID = V.VendorID
	And BillID In (Select BillID From BillAbstract Where VendorID Like @VendorID And BillDate Between @FromDate and @ToDate)
--	And (
--	(BillID In (Select BillID From BillAbstract Where VendorID Like @VendorID And BillDate Between @FromDate and @ToDate))
--	OR
--	(GRNDate Between @FromDate and @ToDate)
--	)
	Group By BillID
	Having Count(GRNID) > 1 
	
	Insert Into #GRNBills 
	(BillID, GRNID, DocType, VendorID, VendorName, BillNumber, 
	GRNNumber, Date, DocValue, Balance, BillGRNID, Locality,RecdInvID, BGStatus, DocIDRef,BillReference
	,TaxType ,GSTFlag ,StateType ,FromStateCode ,ToStateCode ,GSTIN, ODNumber)
	Select G.BillID , G.GRNID , 1,  G.VendorID, V.Vendor_Name ,
	Case When IsNull(B.BillReference,0) = 0 Then @BPreFix + Cast(B.DocumentID As nVarChar) Else @BAPreFix + Cast(B.DocumentID As nVarChar) End ,
	@GRNPreFix + Cast(G.DocumentID As nVarChar), B.BillDate , B.Value + B.AdjustmentAmount + B.TaxAmount, 
	B.Balance,  B.GRNID, V.Locality, IsNull(G.RecdInvoiceID,0) , B.Status, B.DocIDReference, IsNull(BillReference,0)
	,B.TaxType ,B.GSTFlag ,B.StateType ,B.FromStateCode ,B.ToStateCode ,B.GSTIN
	,B.ODNumber
	From BillAbstract B, GRNAbstract G, Vendors V
	Where B.VendorID Like @VendorID
	And G.BillID in (Select BillID From #BillList Where DocType = 1)
	And B.VendorID = V.VendorID
	And G.BillID = B.BillID
	
	Insert Into #GRNBills 
	(BillID, GRNID, DocType, VendorID, VendorName, BillNumber, GRNNumber, 
	Date, DocValue, Balance, BillGRNID, Locality,RecdInvID, BGStatus, DocIDRef,BillReference
	,TaxType ,GSTFlag ,StateType ,FromStateCode ,ToStateCode ,GSTIN, ODNumber )
	Select BillID , 0, 2,  B.VendorID, V.Vendor_Name ,
	Case When IsNull(BillReference,0) = 0 Then @BPreFix + Cast(B.DocumentID As nVarChar) Else @BAPreFix + Cast(B.DocumentID As nVarChar) End ,
	'', B.BillDate , B.Value + B.AdjustmentAmount + B.TaxAmount, B.Balance,  B.GRNID, V.Locality, 
	(Select Max(RecdInvoiceID) From GRNAbstract Where BillID = B.BillID) , B.Status, B.DocIDReference, IsNull(BillReference,0)
	,B.TaxType ,B.GSTFlag ,B.StateType ,B.FromStateCode ,B.ToStateCode ,B.GSTIN
	,B.ODNumber
	From BillAbstract B, Vendors V
	Where B.VendorID Like @VendorID
	And B.BillID in (Select BillID From #BillList Where DocType = 2)
	And B.VendorID = V.VendorID

	Insert Into #GRNBills 
	(BillID, GRNID, DocType, VendorID, VendorName, BillNumber, GRNNumber, 
	Date, DocValue, Balance, BillGRNID, Locality,RecdInvID, BGStatus, DocIDRef,BillReference
	,TaxType ,GSTFlag ,StateType ,FromStateCode ,ToStateCode ,GSTIN, ODNumber )
	Select BillID , 0, 1,  B.VendorID, V.Vendor_Name ,
	Case When IsNull(BillReference,0) = 0 Then @BPreFix + Cast(B.DocumentID As nVarChar) Else @BAPreFix + Cast(B.DocumentID As nVarChar) End ,
	'', B.BillDate , B.Value + B.AdjustmentAmount + B.TaxAmount, B.Balance,  B.GRNID, V.Locality, 
	(Select Max(RecdInvoiceID) From GRNAbstract Where BillID = B.BillID) , B.Status, B.DocIDReference, IsNull(BillReference,0)
	,B.TaxType ,B.GSTFlag ,B.StateType ,B.FromStateCode ,B.ToStateCode ,B.GSTIN
	,B.ODNumber
	From BillAbstract B, Vendors V
	Where B.VendorID Like @VendorID
	And B.BillDate Between @FromDate and @ToDate
	And B.BillID in (Select BillID From #FromGRNList)
	And B.BillID Not In (Select BillID From #BillList Where DocType = 1)
	And B.VendorID = V.VendorID

End
Else
Begin

	Insert Into #BillList
	Select BillID, 1 From GRNAbstract G, Vendors V
	Where G.VendorID Like @VendorID
	And IsNull(BillID,0) > 0
	And IsNull(RecdInvoiceID,0) = 0
	And G.VendorID = V.VendorID
	And BillID In (Select BillID From BillAbstract Where VendorID Like @VendorID And dbo.GetTrueVal(DocumentID) Between @FromDocID And @ToDocID)
	Group By BillID
	Having Count(GRNID) = 1 
	
	Insert Into #FromGRNList
	Select BillID From BillAbstract
	Where GRNID in 
	(Select Cast(GRNID As nVarChar) From GRNAbstract G, Vendors V
	Where G.VendorID Like @VendorID
	And IsNull(BillID,0) > 0
	And IsNull(RecdInvoiceID,0) = 0
	And G.VendorID = V.VendorID
	And BillID In (Select BillID From BillAbstract Where VendorID Like @VendorID And dbo.GetTrueVal(DocumentID) Between @FromDocID And @ToDocID)
	Group By GRNID
	Having Count(GRNID) = 1 )

	Insert Into #BillList
	Select BillID, 1 From GRNAbstract G, Vendors V, InvoiceAbstractReceived IAR
	Where G.VendorID Like @VendorID
	And IsNull(BillID,0) > 0
	And IsNull(RecdInvoiceID,0) > 0
	And IsNull(IAR.Status,0) & 1 <> 0
	And G.VendorID = V.VendorID
	And IAR.InvoiceID = G.RecdInvoiceID
	And BillID In (Select BillID From BillAbstract Where VendorID Like @VendorID And dbo.GetTrueVal(DocumentID) Between @FromDocID And @ToDocID)
	Group By BillID
	Having Count(GRNID) = 1 
	
	Insert Into #BillList
	Select BillID, 2 From GRNAbstract G, Vendors V, InvoiceAbstractReceived IAR
	Where G.VendorID Like @VendorID
	And IsNull(BillID,0) > 0
	And IsNull(RecdInvoiceID,0) > 0
	And IsNull(IAR.Status,0) & 1 = 0
	And G.VendorID = V.VendorID
	And IAR.InvoiceID = G.RecdInvoiceID
	And BillID In (Select BillID From BillAbstract Where VendorID Like @VendorID And dbo.GetTrueVal(DocumentID) Between @FromDocID And @ToDocID)
	Group By BillID
	Having Count(GRNID) = 1 
	
	Insert Into #BillList
	Select BillID, 2 From GRNAbstract G, Vendors V
	Where G.VendorID Like @VendorID
	And IsNull(BillID,0) > 0
	And G.VendorID = V.VendorID
	And BillID In (Select BillID From BillAbstract Where VendorID Like @VendorID And dbo.GetTrueVal(DocumentID) Between @FromDocID And @ToDocID)
	Group By BillID
	Having Count(GRNID) > 1 
	
	Insert Into #GRNBills 
	(BillID, GRNID, DocType, VendorID, VendorName, BillNumber, GRNNumber, 
	Date, DocValue, Balance, BillGRNID, Locality,RecdInvID,BGStatus, DocIDRef, BillReference
	,TaxType ,GSTFlag ,StateType ,FromStateCode ,ToStateCode ,GSTIN, ODNumber )
	Select G.BillID , G.GRNID , 1,  G.VendorID, V.Vendor_Name ,
	Case When IsNull(B.BillReference,0) = 0 Then @BPreFix + Cast(B.DocumentID As nVarChar) Else @BAPreFix + Cast(B.DocumentID As nVarChar) End ,
	@GRNPreFix + Cast(G.DocumentID As nVarChar), B.BillDate , B.Value + B.AdjustmentAmount + B.TaxAmount, 
	B.Balance,  B.GRNID, V.Locality, IsNull(G.RecdInvoiceID,0) , B.Status, B.DocIDReference, IsNull(BillReference,0)
	,B.TaxType ,B.GSTFlag ,B.StateType ,B.FromStateCode ,B.ToStateCode ,B.GSTIN
	,B.ODNumber
	From BillAbstract B, GRNAbstract G, Vendors V
	Where B.VendorID Like @VendorID
	And ((dbo.GetTrueVal(B.DocumentID) Between @FromDocID And @ToDocID) Or
	(dbo.GetTrueVal(DocIDReference) Between @FromDocID And @ToDocID))
	And G.BillID in (Select BillID From #BillList Where DocType = 1)
	And B.VendorID = V.VendorID
	And G.BillID = B.BillID
	
	Insert Into #GRNBills 
	(BillID, GRNID, DocType, VendorID, VendorName, BillNumber, GRNNumber, 
	Date, DocValue, Balance, BillGRNID, Locality,RecdInvID, BGStatus, DocIDRef, BillReference
	,TaxType ,GSTFlag ,StateType ,FromStateCode ,ToStateCode ,GSTIN, ODNumber )
	Select BillID , 0, 2,  B.VendorID, V.Vendor_Name ,
	Case When IsNull(BillReference,0) = 0 Then @BPreFix + Cast(B.DocumentID As nVarChar) Else @BAPreFix + Cast(B.DocumentID As nVarChar) End ,
	'', B.BillDate , B.Value + B.AdjustmentAmount + B.TaxAmount, B.Balance,  B.GRNID, V.Locality,
	(Select Max(RecdInvoiceID) From GRNAbstract Where BillID = B.BillID), B.Status, B.DocIDReference, IsNull(BillReference,0)
	,B.TaxType ,B.GSTFlag ,B.StateType ,B.FromStateCode ,B.ToStateCode ,B.GSTIN
	,B.ODNumber
	From BillAbstract B, Vendors V
	Where B.VendorID Like @VendorID
	And ((dbo.GetTrueVal(DocumentID) Between @FromDocID And @ToDocID) Or
	(dbo.GetTrueVal(DocIDReference) Between @FromDocID And @ToDocID))
	And B.BillID in (Select BillID From #BillList Where DocType = 2)
	And B.VendorID = V.VendorID

	Insert Into #GRNBills 
	(BillID, GRNID, DocType, VendorID, VendorName, BillNumber, GRNNumber, 
	Date, DocValue, Balance, BillGRNID, Locality,RecdInvID, BGStatus, DocIDRef, BillReference
	,TaxType ,GSTFlag ,StateType ,FromStateCode ,ToStateCode ,GSTIN, ODNumber )
	Select BillID , 0, 1,  B.VendorID, V.Vendor_Name ,
	Case When IsNull(BillReference,0) = 0 Then @BPreFix + Cast(B.DocumentID As nVarChar) Else @BAPreFix + Cast(B.DocumentID As nVarChar) End ,
	'', B.BillDate , B.Value + B.AdjustmentAmount + B.TaxAmount, B.Balance,  B.GRNID, V.Locality,
	(Select Max(RecdInvoiceID) From GRNAbstract Where BillID = B.BillID), B.Status, B.DocIDReference, IsNull(BillReference,0)
	,B.TaxType ,B.GSTFlag ,B.StateType ,B.FromStateCode ,B.ToStateCode ,B.GSTIN
	,B.ODNumber
	From BillAbstract B, Vendors V
	Where B.VendorID Like @VendorID
	And ((dbo.GetTrueVal(DocumentID) Between @FromDocID And @ToDocID) Or
	(dbo.GetTrueVal(DocIDReference) Between @FromDocID And @ToDocID))
	And B.BillID in (Select BillID From #FromGRNList)
	And B.BillID Not in (Select BillID From #BillList Where DocType = 1)
	And B.VendorID = V.VendorID
	
End


Select 
"VendorID" = VendorID,
"Vendor Name" = VendorName, 
"Bill Number" = BillNumber,
"GRN Number" = GRNNumber,
"Date" = Date,
"Value" = DocValue,
"Status" = BGStatus,
"Balance" = Balance,
"DocID" = DocIDRef,
"DocType" = DocType,
"BillID" = BillID,
"GRNID" = GRNID,
"BillGRNID" = BillGRNID,
"Locality" = Locality,
"VendorID" = VendorID,
"RecdInvNo" = RecdInvID,
"BillReference" = BillReference
,"TaxType"=TaxType ,"GSTFlag"=GSTFlag ,"StateType"=StateType ,"FromStateCode"=FromStateCode ,"ToStateCode"=ToStateCode ,"GSTIN"=GSTIN 
,"ODNumber" = ODNumber
From #GRNBills
Order by #GRNBills.VendorID, BillID--, GRNID


Drop Table #BillList
Drop Table #GRNBills 
Drop Table #FromGRNList

