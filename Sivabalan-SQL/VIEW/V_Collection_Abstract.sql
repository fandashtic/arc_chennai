CREATE VIEW  [V_Collection_Abstract]([DocumentID],[DocumentDate],[Value],[Balance],[PaymentMode],[ChequeNumber],[ChequeDate],[CustomerID],
[SalesmanID],[DocReference],[BankCode],[BranchCode])
AS
SELECT C.DocumentID,
C.DocumentDate,
C.Value,
C.Balance,
C.PaymentMode,
C.ChequeNumber,
C.ChequeDate,
C.CustomerID,
C.SalesmanID,
C.DocReference,
C.BankCode,
C.BranchCode
FROM  Collections C
inner join 
(SELECT Salesmanid FROM DSType_Master TDM inner join DSType_Details TDD
  on TDM.DSTypeId =TDD.DSTypeId and TDM.DSTypeCtlPos=TDD.DSTypeCtlPos and TDM.DSTypeName='Handheld DS' and TDM.DSTypeValue='Yes') HHS
on HHS.Salesmanid=C.Salesmanid  
where  C.DocumentID in (select distinct CD.CollectionID from CollectionDetail CD inner join  InvoiceAbstract IA on CD.DocumentID = IA.InvoiceID where IA.Balance > 0 ) 
And  (IsNull(C.Status,0) & 64) = 0  
And  (IsNull(C.Status,0) & 128) = 0  
And C.CustomerID <> 'GIFT VOUCHER'
And C.CustomerID Is Not Null
