CREATE procedure sp_list_Payments_DocLU(@FromDocID int,
					 @ToDocID int,@DocumentRef nvarchar(510)=N'')
as
If Len(@DocumentRef)=0 
begin
	select Vendors.Vendor_Name, Vendors.VendorID, FullDocID, Payments.DocumentDate, Value, 
	DocumentID, Balance, Status,docref,
	"DocID" = Payments.DocumentReference, "DocType" = Payments.DocSerialtype
	from Payments, Vendors
	where Payments.VendorID = Vendors.VendorID
	and (dbo.GetTrueVal(Payments.FullDocID) between @FromDocID and @ToDocID 
	OR (Case Isnumeric(Payments.documentreference) When 1 then Cast(Payments.documentreference as int)end)between @FromDocID And @ToDocID) 
	order by Vendors.Vendor_Name, Payments.DocumentDate
End
Else
Begin
	select Vendors.Vendor_Name, Vendors.VendorID, FullDocID, Payments.DocumentDate, Value, 
	DocumentID, Balance, Status,docref,
	"DocID" = Payments.DocumentReference, "DocType" = Payments.DocSerialtype
	from Payments, Vendors
	where Payments.VendorID = Vendors.VendorID
	AND Payments.documentreference LIKE  @DocumentRef + N'%' + N'[0-9]'
	And (CAse ISnumeric(Substring(Payments.documentreference,Len(@DocumentRef)+1,Len(Payments.documentreference))) 
	When 1 then Cast(Substring(Payments.documentreference,Len(@DocumentRef)+1,Len(Payments.documentreference))as int)End) BETWEEN @FromDocID and @ToDocID
	order by Vendors.Vendor_Name, Payments.DocumentDate
End



