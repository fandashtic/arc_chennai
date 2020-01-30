CREATE PROCEDURE sp_get_Collection_Alert(@CUSTOMER nvarchar(15),
					 @FROM DATETIME,
					 @TO DATETIME)
AS
Create Table #temp(
CustomerID nvarchar(20) Null,
DocCount Int Null,
Balance Decimal(18,6) Null)

Insert #temp  (CustomerID, DocCount, Balance)
SELECT InvoiceAbstract.CustomerID, Count(*), Sum(Balance) 
FROM InvoiceAbstract
WHERE InvoiceAbstract.CustomerID LIKE @CUSTOMER AND
Balance <> 0 AND
InvoiceAbstract.PaymentDate BETWEEN @FROM AND @TO AND
InvoiceType in (1, 3) And
(InvoiceAbstract.Status & 128) = 0
GROUP BY InvoiceAbstract.CustomerID

--Begin: Changes has been made for Over Due Collections of service Invoice
if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[ServiceInvoiceAbstract]') 
and OBJECTPROPERTY(id, N'IsUserTable') = 1)
begin
	Insert #temp (CustomerID, DocCount, Balance)
	SELECT ServiceInvoiceAbstract.CustomerID,Count(*),Sum(IsNull(Balance,0))
	FROM ServiceInvoiceAbstract
	WHERE ServiceInvoiceAbstract.CustomerID LIKE @CUSTOMER and
	ServiceInvoiceAbstract.PaymentDate Between @FROM and @TO and
	isNull(Balance,0) <> 0 and
	isNull(ServiceInvoiceType,0) in (1) and
	isNull(Status,0) & 192 = 0
	Group by ServiceInvoiceAbstract.CustomerID
End
--End: Over Due Collections of service Invoice

Insert #temp (CustomerID, DocCount, Balance)
Select InvoiceAbstract.CustomerID, Count(*), 0 - Sum(InvoiceAbstract.Balance)
From InvoiceAbstract
Where InvoiceAbstract.CustomerID like @CUSTOMER And
InvoiceAbstract.PaymentDate Between @FROM And @TO And
InvoiceAbstract.Balance > 0 And
InvoiceAbstract.InvoiceType = 4 and
InvoiceAbstract.Status & 128 = 0
Group By InvoiceAbstract.CustomerID

Insert #temp (CustomerID, DocCount, Balance)
Select CreditNote.CustomerID, Count(*), 0 - Sum(CreditNote.Balance)
From CreditNote
Where CreditNote.CustomerID Like @Customer And
CreditNote.DocumentDate Between @From And @To And
CreditNote.Balance > 0 And
CreditNote.CustomerID Is Not Null
Group By CreditNote.CustomerID

Insert #temp  (CustomerID, DocCount, Balance)
Select DebitNote.CustomerID, Count(*), Sum(DebitNote.Balance)
From DebitNote
Where DebitNote.CustomerID Like @Customer And
DebitNote.CustomerID Is Not Null And
DebitNote.DocumentDate Between @From And @To And
DebitNote.Balance > 0
Group By DebitNote.CustomerID

Insert #temp (CustomerID, DocCount, Balance)
Select Collections.CustomerID, Count(*), 0 - Sum(Collections.Balance)
From Collections
Where Collections.CustomerID Like @Customer And
Collections.DocumentDate Between @From And @To And
Collections.Balance > 0 And
IsNull(Collections.Status, 0) & 128 = 0
Group By Collections.CustomerID

Select Customer.Company_Name, #temp.CustomerID, Sum(DocCount), Sum(Balance)
From #temp, Customer
Where #temp.CustomerID collate SQL_Latin1_General_Cp1_CI_AS = Customer.CustomerID
Group By #temp.CustomerID, Customer.Company_Name
Drop Table #temp
