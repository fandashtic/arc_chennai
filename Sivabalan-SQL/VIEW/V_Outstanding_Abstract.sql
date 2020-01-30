Create VIEW  [V_Outstanding_Abstract]
([Invoice_number], [Order_ID], [REFNO], [Invoice_Date], [Invocie_Net_Amount], [Amount_Paid], 
[Balance_Due], [CustomerID], [SalesmanID], [BeatID], [PaymentDate],[DocID])
AS
SELECT InvoiceAbstract.InvoiceID,
Isnull(Ord.ORDERNUMBER, ''),
--case when isnull(GSTFLAG,0)>0  then Isnull(GSTFullDocID,'') else cast(DocumentID AS char(255)) end,
--DocumentID,
DocReference,
InvoiceDate,
NetValue,
NetValue + RoundOffAmount - Balance as Amount_Paid, 
Balance, 
Customerid, 
InvoiceAbstract.Salesmanid,
 Beatid,
paymentdate,
case when isnull(GSTFLAG,0)>0  then Isnull(GSTFullDocID,'') else cast(DocumentID AS char(255)) end
--DocReference 
FROM InvoiceAbstract
--inner join 
--(SELECT Salesmanid FROM DSType_Master TDM inner join DSType_Details TDD
--  on TDM.DSTypeId =TDD.DSTypeId and TDM.DSTypeCtlPos=TDD.DSTypeCtlPos and TDM.DSTypeName='Handheld DS' and TDM.DSTypeValue='Yes') HHS
--on HHS.Salesmanid=InvoiceAbstract.Salesmanid 
Left Outer Join (Select Distinct ORDERNUMBER, SALEORDERID From Order_Details Where IsNull(SALEORDERID, 0) <> 0) Ord
	on Ord.SALEORDERID = Isnull(InvoiceAbstract.SONumber, 0) 
Where Balance > 0 
 	and (isnull(InvoiceAbstract.Status,0) & 128 ) = 0 
	and (isnull(InvoiceAbstract.Status,0) & 64 ) = 0 
	and InvoiceAbstract.DocumentID Not In (Select InvoiceDocumentID from tbl_merp_dsostransfer)
	and InvoiceAbstract.InvoiceType in (1,3)

UNION


SELECT InvoiceAbstract.InvoiceID,
Isnull(Ord.ORDERNUMBER, ''),
--case when isnull(GSTFLAG,0)>0  then Isnull(GSTFullDocID,'') else cast(DocumentID AS char(255)) end,
--DocumentID,
DocReference,
InvoiceDate,
NetValue,
NetValue + RoundOffAmount - Balance as Amount_Paid, 
Balance, 
Customerid, 
DSOSTrfr.MappedSalesmanID 'SalesmanID',
DSOSTrfr.MappedBeatID  'BeatID',
paymentdate,
case when isnull(GSTFLAG,0)>0  then Isnull(GSTFullDocID,'') else cast(DocumentID AS char(255)) end
--DocReference 
FROM InvoiceAbstract
Inner Join tbl_mERP_DSOSTransfer DSOSTrfr On InvoiceAbstract.DocumentID = DSOSTrfr.InvoiceDocumentID
--inner join 
--(SELECT Salesmanid FROM DSType_Master TDM inner join DSType_Details TDD
--  on TDM.DSTypeId =TDD.DSTypeId and TDM.DSTypeCtlPos=TDD.DSTypeCtlPos and TDM.DSTypeName='Handheld DS' and TDM.DSTypeValue='Yes') HHS
--on HHS.Salesmanid = DSOSTrfr.MappedSalesmanID 
Left Outer Join (Select Distinct ORDERNUMBER, SALEORDERID From Order_Details Where IsNull(SALEORDERID, 0) <> 0) Ord
	on Ord.SALEORDERID = Isnull(InvoiceAbstract.SONumber, 0) 
Where Balance > 0 
 	and (isnull(InvoiceAbstract.Status,0) & 128 ) = 0 
	and (isnull(InvoiceAbstract.Status,0) & 64 ) = 0 
	and InvoiceAbstract.InvoiceType in (1,3)

