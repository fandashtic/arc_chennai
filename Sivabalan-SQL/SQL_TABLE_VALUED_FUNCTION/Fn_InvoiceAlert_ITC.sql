
Create Function [dbo].[Fn_InvoiceAlert_ITC]()
Returns @InvoiceAltert Table  
(
	InvoiceID   nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,
	InvoiceType int,
	InvoiceDate Datetime,
	CreationTime Datetime,
	CustomerID nvarchar (15) COLLATE SQL_Latin1_General_CP1_CI_AS,
	NetValue decimal(18, 6),
	SalesmanID int,
    BeatID   int,
	DocumentID nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	NewReference nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
	DocReference nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	Status int,
	Balance decimal(18, 6)	
)
As
Begin
Declare @FromDate datetime
Declare @ToDate datetime
select @FromDate = cast (convert(varchar(10),dateadd(d,-2,GETDATE()),112) AS datetime) 
select @ToDate = cast (convert(varchar(10),GETDATE(),112) AS datetime) +  '23:59:59.000'
insert into @InvoiceAltert
select cast(InvoiceAbstract.InvoiceID as nvarchar(15)) as invoiceid,Invoiceabstract.Invoicetype,InvoiceAbstract.InvoiceDate,
InvoiceAbstract.CreationTime,Customer.CustomerID,InvoiceAbstract.NetValue,SalesMan.SalesmanID,Beat.BeatID,
--cast(invoiceabstract.DocumentID as nvarchar(10)) as docid
Case When isnull(GSTFLAG,0)>0  Then Isnull(GSTFullDocID,'') Else cast(DocumentID as nvarchar(255))  End as docid,
invoiceabstract.NewReference,
Case When isnull(GSTFLAG,0)>0  Then Isnull(GSTFullDocID,'') Else isnull(VoucherPrefix.Prefix,'') + Cast (invoiceabstract.DocumentID as nvarchar) End as 'DocReference',
invoiceabstract.Status,invoiceabstract.Balance
from invoiceabstract
Inner Join Customer On invoiceabstract.Customerid = Customer.Customerid
Inner Join SalesMan On invoiceabstract.SalesmanId = SalesMan.SalesManid
Inner Join Beat On InvoiceAbstract.BeatID = Beat.BeatID
inner Join (SELECT Salesmanid FROM DSType_Master TDM inner join DSType_Details TDD
on TDM.DSTypeId =TDD.DSTypeId and TDM.DSTypeCtlPos=TDD.DSTypeCtlPos and TDM.DSTypeName='Handheld DS' and TDM.DSTypeValue='Yes') HHS
On SalesMan.SalesManid = HHS.SalesManid
Left Outer Join VoucherPrefix On VoucherPrefix.TranID =
(Case 	when InvoiceAbstract.InvoiceType = 1 then  'INVOICE'
when InvoiceAbstract.InvoiceType = 3 then 'INVOICE AMENDMENT'
end)
and VoucherPrefix.TranID in ('INVOICE', 'INVOICE AMENDMENT')
Where 
(select isnull(Flag,0) as 'SMSALERT'from Tbl_merp_Configabstract
 where screencode='SMSALERT' ) = 1
And (select isnull(Flag,0) as 'SMSINVALERT'from Tbl_merp_Configabstract
 where screencode='SMSINVALERT' ) = 1
And InvoiceAbstract.InvoiceType in (1,3) 
And InvoiceAbstract.Status & 128 = 0  
And InvoiceAbstract.Status not in (1,16)
And isnull(Customer.SMSAlert,0)  = 1
And isnull(SalesMan.SMSAlert,0)  = 1 
And isnull(Salesman.Active,0) = 1
And InvoiceAbstract.InvoiceDate between @FromDate and @Todate	
order by InvoiceDate
Return
End 
