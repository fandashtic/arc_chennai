CREATE PROCEDURE mERP_sp_Save_Vehicle_AllocationDet
(         
	@VAllocID Int,
	@InvoiceID Int,
	@InvoiceDate DateTime,
	@CustID nVarChar(15),
	@GSTDocID Int,
	@GSTFullDocID nVarChar(255),
	@InvDocRef nVarChar(255),
	@InvoiceValue Decimal(18,6),
	@SalesManID Int,
	@BeatID Int,	
	@ZoneID Int,
	@SequenceNo Int = 0
)
AS  
Begin
Insert Into VAllocDetail
(VAllocID,InvoiceID,InvoiceDate,CustomerID,GSTDocID,GSTFullDocID,DocReference,InvoiceValue,SalesmanID,BeatID,ZoneID,SequenceNo) Values
(@VAllocID,@InvoiceID,@InvoiceDate,@CustID,@GSTDocID,@GSTFullDocID,@InvDocRef,@InvoiceValue,@SalesManID,@BeatID,@ZoneID,@SequenceNo)
End
