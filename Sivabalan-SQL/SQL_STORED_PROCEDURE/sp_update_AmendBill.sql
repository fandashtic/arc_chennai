
CREATE procedure sp_update_AmendBill(@Old_Bill int, @Vendor_ID nvarchar(15),
@BillDate datetime, @UserName nvarchar(50), @Value Decimal(18,6)) as

declare @GRN_ID as int
declare @NewGRN_ID as int
declare @Inv_No as nvarchar(50)
declare @Bill_No as int
declare @OldDocID as int
DECLARE @DocumentID as int

SELECT @DocumentID = DocumentID FROM DocumentNumbers WHERE DocType = 6
UPDATE DocumentNumbers SET DocumentID = DocumentID + 1 WHERE DocType = 6

select @GRN_ID = GRNID , @Inv_No = InvoiceReference, @OldDocID = DocumentID from BillAbstract 
where BillID = @Old_Bill

insert into BillAbstract (GRNID, BillDate, VendorID, UserName, Value, 
CreationTime, Status, InvoiceReference, BillReference, NewGRNID, DocumentReference, DocumentID) values
(@GRN_ID, @BillDate, @Vendor_ID, @UserName, @Value, GetDate(), 0, @Inv_No, @Old_Bill, @NewGRN_ID, @OldDocID, @DocumentID)

select @Bill_No = @@IDENTITY

update BillAbstract set Status = Status | 128 where BillID = @Old_Bill

update GRNAbstract set BillID = @Bill_No, NewBillID = @DocumentID where GRNID =  @GRN_ID

select @Bill_No, @DocumentID

