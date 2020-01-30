CREATE PROCEDURE [dbo].[mERP_sp_List_GRN]
(
@VendorID nVarChar(50),
@FromDate DateTime,
@ToDate DateTime,
@FromDocID Int=0,
@ToDocID Int=0,
@SelMode Int=0
)
AS
Declare @GRNPreFix nVarChar(50)
Declare @BPreFix nVarChar(50)
Declare @BAPreFix nVarChar(50)

SELECT @GRNPreFix = Prefix FROM VoucherPrefix WHERE TranID = N'GOODS RECEIVED NOTE'
SELECT @BPreFix = Prefix FROM VoucherPrefix WHERE TranID = N'BILL'
SELECT @BAPreFix = Prefix FROM VoucherPrefix WHERE TranID = N'BILL AMENDMENT'

Create Table #BillList (BillID Int, DocType Int)

Create Table #GRNBills 
(BillID Int, GRNID Int, DocType Int, VendorID nVarchar(15), VendorName nVarchar(50), BillNumber nVarChar(50) , GRNNumber nVarchar(50),
Date DateTime, DocValue Decimal(18,6), Balance Decimal(18,6), BillGRNID nVarChar(255),Locality Int,RecdInvID Int, BGStatus Int, DocIDRef nVarChar(510),BillReference Int)

If @FromDocID = 0
Begin

--	Insert Into #BillList
--	Select BillID, 1 From GRNAbstract G, Vendors V, InvoiceAbstractReceived IAR
--	Where G.VendorID Like @VendorID
--	And IsNull(BillID,0) > 0
--	And IsNull(RecdInvoiceID,0) > 0
--	And IsNull(IAR.Status,0) & 1 <> 0
--	And G.VendorID = V.VendorID
--	And IAR.InvoiceID = G.RecdInvoiceID
--	And BillID In (Select BillID From BillAbstract Where VendorID Like @VendorID And BillDate Between @FromDate and @ToDate)
--	Group By BillID
--	Having Count(GRNID) = 1 
--	
--	Insert Into #BillList
--	Select BillID, 2  From GRNAbstract G, Vendors V, InvoiceAbstractReceived IAR
--	Where G.VendorID Like @VendorID
--	And IsNull(BillID,0) > 0
--	And IsNull(RecdInvoiceID,0) > 0
--	And IsNull(IAR.Status,0) & 1 = 0
--	And G.VendorID = V.VendorID
--	And IAR.InvoiceID = G.RecdInvoiceID
--	And (
--	(BillID In (Select BillID From BillAbstract Where VendorID Like @VendorID And BillDate Between @FromDate and @ToDate))
--	OR
--	(GRNDate Between @FromDate and @ToDate)
--	)
--	Group By BillID
--	Having Count(GRNID) = 1 
--	
--	Insert Into #BillList
--	Select BillID, 2 From GRNAbstract G, Vendors V
--	Where G.VendorID Like @VendorID
--	And IsNull(BillID,0) > 0
--	And G.VendorID = V.VendorID
--	And (
--	(BillID In (Select BillID From BillAbstract Where VendorID Like @VendorID And BillDate Between @FromDate and @ToDate))
--	OR
--	(GRNDate Between @FromDate and @ToDate)
--	)
--	Group By BillID
--	Having Count(GRNID) > 1 

	If IsNull(@SelMode,0) = 8
	Begin
		Insert Into #GRNBills 
		(BillID, GRNID, DocType, VendorID, VendorName, BillNumber, GRNNumber, 
		Date, DocValue, Balance, BillGRNID, Locality,RecdInvID, BGStatus, DocIDRef,BillReference)
		Select IsNull(BillID,0), GRNID , 3, G.VendorID, V.Vendor_Name ,
 		IsNull((Select Case When IsNull(B.BillReference,0) = 0 Then @BPreFix + Cast(B.DocumentID As nVarChar) Else @BAPreFix + Cast(B.DocumentID As nVarChar) End 
		From BillAbstract B Where B.BillID = G.BillID),''),
		@GRNPreFix + Cast(G.DocumentID As nVarChar), G.GRNDate , 0, 0,'', 
		V.Locality, IsNull(G.RecdInvoiceID,0), G.GRNStatus, '',0
		From GRNAbstract G, Vendors V
		Where G.VendorID Like @VendorID
	--	And IsNull(G.RecdInvoiceID,0) > 0
		And G.GRNDate Between @FromDate and @ToDate
	--	And G.BillID in (Select BillID From #BillList Where DocType in (1, 2))
		And IsNull(G.BillID,0) > 0
		And G.VendorID = V.VendorID
	End
	Else
	Begin
		Insert Into #GRNBills 
		(BillID, GRNID, DocType, VendorID, VendorName, BillNumber, GRNNumber, 
		Date, DocValue, Balance, BillGRNID, Locality,RecdInvID, BGStatus, DocIDRef,BillReference)
		Select IsNull(BillID,0), GRNID , 3, G.VendorID, V.Vendor_Name ,
 		IsNull((Select Case When IsNull(B.BillReference,0) = 0 Then @BPreFix + Cast(B.DocumentID As nVarChar) Else @BAPreFix + Cast(B.DocumentID As nVarChar) End 
		From BillAbstract B Where B.BillID = G.BillID),''),
		@GRNPreFix + Cast(G.DocumentID As nVarChar), G.GRNDate , 0, 0,'', 
		V.Locality, IsNull(G.RecdInvoiceID,0), G.GRNStatus, '',0
		From GRNAbstract G, Vendors V
		Where G.VendorID Like @VendorID
		And IsNull(G.RecdInvoiceID,0) > 0
		And G.GRNDate Between @FromDate and @ToDate
	--	And G.BillID in (Select BillID From #BillList Where DocType in (1, 2))
		And IsNull(G.BillID,0) > 0
		And G.VendorID = V.VendorID
	End
End
Else
Begin
	
--	Insert Into #BillList
--	Select BillID, 1 From GRNAbstract G, Vendors V, InvoiceAbstractReceived IAR
--	Where G.VendorID Like @VendorID
--	And IsNull(BillID,0) > 0
--	And IsNull(RecdInvoiceID,0) > 0
--	And IsNull(IAR.Status,0) & 1 <> 0
--	And G.VendorID = V.VendorID
--	And IAR.InvoiceID = G.RecdInvoiceID
--	And BillID In (Select BillID From BillAbstract Where VendorID Like @VendorID And dbo.GetTrueVal(DocumentID) Between @FromDocID And @ToDocID)
--	Group By BillID
--	Having Count(GRNID) = 1 
--	
--	Insert Into #BillList
--	Select BillID, 2 From GRNAbstract G, Vendors V, InvoiceAbstractReceived IAR
--	Where G.VendorID Like @VendorID
--	And IsNull(BillID,0) > 0
--	And IsNull(RecdInvoiceID,0) > 0
--	And IsNull(IAR.Status,0) & 1 = 0
--	And G.VendorID = V.VendorID
--	And IAR.InvoiceID = G.RecdInvoiceID
--	And BillID In (Select BillID From BillAbstract Where VendorID Like @VendorID And dbo.GetTrueVal(DocumentID) Between @FromDocID And @ToDocID)
--	Group By BillID
--	Having Count(GRNID) = 1 
--	
--	Insert Into #BillList
--	Select BillID, 2 From GRNAbstract G, Vendors V
--	Where G.VendorID Like @VendorID
--	And IsNull(BillID,0) > 0
--	And G.VendorID = V.VendorID
--	And BillID In (Select BillID From BillAbstract Where VendorID Like @VendorID And dbo.GetTrueVal(DocumentID) Between @FromDocID And @ToDocID)
--	Group By BillID
--	Having Count(GRNID) > 1 
	
	If IsNull(@SelMode,0) = 8
	Begin
		Insert Into #GRNBills 
		(BillID, GRNID, DocType, VendorID, VendorName, BillNumber, GRNNumber, 
		Date, DocValue, Balance, BillGRNID, Locality,RecdInvID, BGStatus, DocIDRef,BillReference)
		Select IsNull(BillID,0), GRNID , 3, G.VendorID, V.Vendor_Name ,
 		IsNull((Select Case When IsNull(B.BillReference,0) = 0 Then @BPreFix + Cast(B.DocumentID As nVarChar) Else @BAPreFix + Cast(B.DocumentID As nVarChar) End 
		From BillAbstract B Where B.BillID = G.BillID),''),
		@GRNPreFix + Cast(G.DocumentID As nVarChar), G.GRNDate , 0, 0,'', 
		V.Locality, IsNull(G.RecdInvoiceID,0), G.GRNStatus, '', 0
		From GRNAbstract G, Vendors V
		Where G.VendorID Like @VendorID
	--	And IsNull(G.RecdInvoiceID,0) > 0
		And dbo.GetTrueVal(DocumentID) Between @FromDocID And @ToDocID
	--	And G.BillID in (Select BillID From #BillList Where DocType in (1,2))
		And IsNull(G.BillID,0) > 0
		And G.VendorID = V.VendorID
	End
	Else
	Begin
		Insert Into #GRNBills 
		(BillID, GRNID, DocType, VendorID, VendorName, BillNumber, GRNNumber, 
		Date, DocValue, Balance, BillGRNID, Locality,RecdInvID, BGStatus, DocIDRef,BillReference)
		Select IsNull(BillID,0), GRNID , 3, G.VendorID, V.Vendor_Name ,
 		IsNull((Select Case When IsNull(B.BillReference,0) = 0 Then @BPreFix + Cast(B.DocumentID As nVarChar) Else @BAPreFix + Cast(B.DocumentID As nVarChar) End 
		From BillAbstract B Where B.BillID = G.BillID),''),
		@GRNPreFix + Cast(G.DocumentID As nVarChar), G.GRNDate , 0, 0,'', 
		V.Locality, IsNull(G.RecdInvoiceID,0), G.GRNStatus, '', 0
		From GRNAbstract G, Vendors V
		Where G.VendorID Like @VendorID
		And IsNull(G.RecdInvoiceID,0) > 0
		And dbo.GetTrueVal(DocumentID) Between @FromDocID And @ToDocID
	--	And G.BillID in (Select BillID From #BillList Where DocType in (1,2))
		And IsNull(G.BillID,0) > 0
		And G.VendorID = V.VendorID
	End
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
From #GRNBills
Order by #GRNBills.VendorID, GRNID --, BillID

Drop Table #BillList
Drop Table #GRNBills 


