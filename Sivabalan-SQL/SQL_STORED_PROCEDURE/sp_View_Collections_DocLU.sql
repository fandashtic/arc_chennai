CREATE procedure sp_View_Collections_DocLU (@FromDocID int,
					    @ToDocID int,@DocumentRef nvarchar(510)=N'')
as
If Len(@DocumentRef)=0 
begin
	select Customer.Company_Name, Customer.CustomerID, FullDocID, Collections.DocumentDate, 
	Value, DocumentID, Balance, Status, OriginalRef,
	"DocID" = Collections.DocumentReference,
	"DocType" = Collections.DocSerialType
	from Collections, Customer
	where Collections.CustomerID = Customer.CustomerID 
	and (dbo.GetTrueVal(Collections.FullDocID) between @FromDocID and @ToDocID 
	OR (Case Isnumeric(Collections.documentreference) When 1 then Cast(Collections.documentreference as int)end)between @FromDocID And @ToDocID) 
	order by Customer.Company_Name, Collections.DocumentDate
End
Else
Begin
	select Customer.Company_Name, Customer.CustomerID, FullDocID, Collections.DocumentDate, 
	Value, DocumentID, Balance, Status, OriginalRef,
	"DocID" = Collections.DocumentReference,
	"DocType" = Collections.DocSerialType
	from Collections, Customer
	where Collections.CustomerID = Customer.CustomerID
	AND Collections.documentreference LIKE  @DocumentRef + N'%' + N'[0-9]'
	And (CAse ISnumeric(Substring(Collections.documentreference,Len(@DocumentRef)+1,Len(Collections.documentreference))) 
	When 1 then Cast(Substring(Collections.documentreference,Len(@DocumentRef)+1,Len(Collections.documentreference))as int)End) BETWEEN @FromDocID and @ToDocID
	order by Customer.Company_Name, Collections.DocumentDate
End


