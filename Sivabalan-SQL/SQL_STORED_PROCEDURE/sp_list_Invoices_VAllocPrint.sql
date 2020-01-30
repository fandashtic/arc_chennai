CREATE PROCEDURE sp_list_Invoices_VAllocPrint
(
	@VAllocID Int
)
AS
Begin
 Select * Into #tmpVAllocDetail From VAllocDetail Where VAllocID = @VAllocID 
 If (Select SUM(IsNull(SequenceNo,0)) From #tmpVAllocDetail) > 0
 Begin
	SELECT IA.InvoiceID,IA.DocumentID,IA.DocReference, C.Company_Name, IA.InvoiceDate, IA.NetValue,             
	S.SalesMan_Name,B.Description,Case When IA.GroupID = '0' Then 'All Categories'
		Else (Select dbo.mERP_fn_Get_GroupNames(IA.GroupID) ) End        
	, IA.GSTFlag, IA.GSTFullDocID
	FROM InvoiceAbstract IA
	Inner Join #tmpVAllocDetail VAD On VAd.GSTFullDocID = IA.GSTFullDocID --VAD.InvoiceID = IA.InvoiceID
	Inner Join Customer C On C.CustomerID = IA.CustomerID 
	Left Outer Join SalesMan S On S.SalesmanID = IA.SalesmanID 
	Left Outer Join Beat B On B.BeatID = IA.BeatID
	WHERE IA.InvoiceType In (1, 3) And (IsNull(Status,0) & 128) = 0
	ORDER BY VAD.SequenceNo
 End
 Else
 Begin
	SELECT IA.InvoiceID,IA.DocumentID,IA.DocReference, C.Company_Name, IA.InvoiceDate, IA.NetValue,             
	S.SalesMan_Name,B.Description,Case When IA.GroupID = '0' Then 'All Categories'
		Else (Select dbo.mERP_fn_Get_GroupNames(IA.GroupID) ) End        
	, IA.GSTFlag, IA.GSTFullDocID
	FROM InvoiceAbstract IA
	Inner Join #tmpVAllocDetail VAD On VAD.GSTFullDocID = IA.GSTFullDocID  --VAD.InvoiceID = IA.InvoiceID
	Inner Join Customer C On C.CustomerID = IA.CustomerID 
	Left Outer Join SalesMan S On S.SalesmanID = IA.SalesmanID 
	Left Outer Join Beat B On B.BeatID = IA.BeatID
	WHERE IA.InvoiceType In (1, 3) And (IsNull(Status,0) & 128) = 0
	ORDER BY dbo.StripTimeFromDate(IA.InvoiceDate) , IA.GSTFullDocID 
 End
End
