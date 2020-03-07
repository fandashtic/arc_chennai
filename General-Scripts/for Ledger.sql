Set DateFormat DMY
;WITh CTE_Sales(GSTFullDocID, InvoiceDate, Year, WeekId, DeliveryDate, CustomerID, SalesmanID, BeatID, DocSerialType, NetValue)
AS
(
	select Distinct GSTFullDocID, InvoiceDate, YEAR(InvoiceDate), DATEPART(WEEK,InvoiceDate), DeliveryDate, CustomerID, SalesmanID, BeatID, DocSerialType, (ISNULL(NetValue, 0) + ISNULL(RoundOffAmount, 0)) 
	from InvoiceAbstract 
	Where invoicetype IN ( 1, 3 ) AND ( invoiceabstract.status & 128 ) = 0 
	And dbo.StripDateFromTime(InvoiceDate) <= '29-Feb-2020'	
)
SELECT * FROM CTE_Sales
order by InvoiceDate ASC


;WITh CTE_SalesReturn(GSTFullDocID, InvoiceDate, Year, WeekId, CustomerID, SalesmanID, BeatID, DocSerialType, Type, NetValue)
AS
(
	select Distinct GSTFullDocID, InvoiceDate, YEAR(InvoiceDate), DATEPART(WEEK,InvoiceDate), CustomerID, SalesmanID, BeatID, DocSerialType, 
	Status, --case When (Status & 32) <> 0 Then 'DAMAGES' Else 'SALEABLE' End, 
	(ISNULL(NetValue, 0) + ISNULL(RoundOffAmount, 0)) 
	from InvoiceAbstract 
	Where invoicetype = 4 AND (status & 128) = 0 
	And dbo.StripDateFromTime(InvoiceDate) <= '29-Feb-2020'	
)
SELECT * FROM CTE_SalesReturn
order by InvoiceDate ASC

;WITh CTE_Collections(DocumentDate,Value,Balance,CustomerID,SalesmanID,BeatID,FullDocID,DocumentID)
AS
(
	select DocumentDate, Value, Balance, CustomerID, SalesmanID, BeatID, FullDocID, DocumentID 
	from Collections WITH (NOLOCK)
	WHERE (isnull(Status,0) & 192) = 0 
	AND dbo.StripDateFromTime(DocumentDate) <= '28-Feb-2020'
)
SELECT * FROM CTE_Collections
order by DocumentDate ASC


