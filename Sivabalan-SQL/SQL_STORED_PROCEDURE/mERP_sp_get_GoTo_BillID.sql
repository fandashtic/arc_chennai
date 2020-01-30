Create Procedure mERP_sp_get_GoTo_BillID(@BillID Int=0, @DocRefID nVarChar(255)='', @MenuMode Int=1)
As
Declare @GRNPreFix nVarChar(50)
Declare @BPreFix nVarChar(50)
Declare @BAPreFix nVarChar(50)

SELECT @GRNPreFix = Prefix FROM VoucherPrefix WHERE TranID = N'GOODS RECEIVED NOTE'
SELECT @BPreFix = Prefix FROM VoucherPrefix WHERE TranID = N'BILL'
SELECT @BAPreFix = Prefix FROM VoucherPrefix WHERE TranID = N'BILL AMENDMENT'

Declare @ID Int
Set @ID = 0

If IsNull(@MenuMode,0) = 2
Begin
	If IsNull(@BillID,0) > 0 And Len(IsNull(@DocRefID,'')) > 0
	Begin
		If (Select Count(GrnID) from GRNAbstract Where DocumentID = @BillID and DocRef = @DocRefID  And (IsNull(GRNStatus,0) & 96 = 0 Or IsNull(GRNStatus,0) & 64 <> 0) And IsNull(BillID,0) > 0 ) > 0
			Select @ID = Max(GRNID) from GRNAbstract Where DocumentID = @BillID And DocRef = @DocRefID And (IsNull(GRNStatus,0) & 96 = 0  Or IsNull(GRNStatus,0) & 64 <> 0) And IsNull(BillID,0) > 0
	End
	Else
	Begin
		If IsNull(@BillID,0) > 0 And Len(IsNull(@DocRefID,'')) = 0
		Begin
		If (Select Count(GrnID) from GRNAbstract Where DocumentID = @BillID And (IsNull(GRNStatus,0) & 96 = 0  Or IsNull(GRNStatus,0) & 64 <> 0) And IsNull(BillID,0) > 0) > 0
			Select @ID = Max(GRNID) from GRNAbstract Where DocumentID = @BillID  And (IsNull(GRNStatus,0) & 96 = 0  Or IsNull(GRNStatus,0) & 64 <> 0) And IsNull(BillID,0) > 0
		End
		Else If IsNull(@BillID,0) = 0 And Len(IsNull(@DocRefID,'')) > 0
		Begin
		If (Select Count(GrnID) from GRNAbstract Where DocRef = @DocRefID And (IsNull(GRNStatus,0) & 96 = 0  Or IsNull(GRNStatus,0) & 64 <> 0) And IsNull(BillID,0) > 0) > 0
			Select @ID = Max(GRNID) from GRNAbstract Where DocRef = @DocRefID And (IsNull(GRNStatus,0) & 96 = 0  Or IsNull(GRNStatus,0) & 64 <> 0) And IsNull(BillID,0) > 0
		End
	End
	If IsNull(@ID,0) > 0
		Select 1, "BillID" = BillID,"GRNID" = GRNID, "BILLGRNID" = '', "VendorID" = GRNAbstract.VendorID, "Vendor" = Vendors.Vendor_Name,
		"BillNumber" = IsNull((Select Case When IsNull(BillReference,0) = 0 Then @BPreFix + Cast(DocumentID As nVarChar) Else @BAPreFix + Cast(DocumentID As nVarChar) End From BillAbstract Where BillID = GRNAbstract.BillID),''),
		"GRNNumber"  = @GRNPreFix + Cast(DocumentID As nVarChar), "Date" = GRNDate , 
		"Locality" = Vendors.Locality, "DocRef" = DocumentReference
		From GRNAbstract , Vendors
		Where GRNID = @ID
		And GRNAbstract.VendorID = Vendors.VendorID
	Else
		Select 0
End
Else
Begin
	If IsNull(@BillID,0) > 0 And Len(IsNull(@DocRefID,'')) > 0
	Begin
		If (Select Count(BillID) from BillAbstract Where DocumentID = @BillID and DocIDReference = @DocRefID And (IsNull(Status,0) & 128 = 0 Or IsNull(Status,0) & 64 <> 0)) > 0
			Select @ID = Max(BillID) From BillAbstract Where DocumentID = @BillID And DocIDReference = @DocRefID And (IsNull(Status,0) & 128 = 0 Or IsNull(Status,0) & 64 <> 0)
	End
	Else
	Begin
		If IsNull(@BillID,0) > 0 And Len(IsNull(@DocRefID,'')) = 0
		Begin
			If (Select Count(GrnID) from BillAbstract Where DocumentID = @BillID And (IsNull(Status,0) & 128 = 0 Or IsNull(Status,0) & 64 <> 0)) > 0
				Select @ID = Max(BillID) from BillAbstract Where DocumentID = @BillID And (IsNull(Status,0) & 128 = 0 Or IsNull(Status,0) & 64 <> 0)
		End
		Else If IsNull(@BillID,0) = 0 And Len(IsNull(@DocRefID,'')) > 0
		Begin
			If (Select Count(GrnID) from BillAbstract Where DocIDReference = @DocRefID And (IsNull(Status,0) & 128 = 0 Or IsNull(Status,0) & 64 <> 0)) > 0
				Select @ID = Max(BillID) from BillAbstract Where DocIDReference = @DocRefID And (IsNull(Status,0) & 128 = 0 Or IsNull(Status,0) & 64 <> 0)
		End
	End
	If IsNull(@ID,0) > 0
		Select 1, "BillID" = BillID,"GRNID" = 0, "BILLGRNID" = GRNID, "VendorID" = BillAbstract.VendorID, "Vendor" = Vendors.Vendor_Name,
		"BillNumber" = Case When IsNull(BillReference,0) = 0 Then @BPreFix + Cast(DocumentID As nVarChar) Else @BAPreFix + Cast(DocumentID As nVarChar) End ,
		"GRNNumber"  = '', "Date" = BillDate , 
		"Locality" = Vendors.Locality, "DocRef" = DocIDReference
		From BillAbstract , Vendors
		Where BillID = @ID
		And BillAbstract.VendorID = Vendors.VendorID
	Else
		Select 0
End
