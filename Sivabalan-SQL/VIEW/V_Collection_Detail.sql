Create VIEW  [V_Collection_Detail]
([DocumentID],[DocumentType],[DocumentDate],[PaymentDate],[CollectedAmount],[CollectionID],
[DocumentNumber],[SCRef],[Order_ID],[DocumentValue],
[Extracollection],[Adjustment],[DocRef],
[Others],[Discount])
AS
SELECT
C.DocumentID
,C.DocumentType
,C.DocumentDate
,C.PaymentDate
,C.AdjustedAmount
,C.CollectionID
--,"[DocumentNumber]" = Isnull((Case When C.DocumentType = 4 or C.DocumentType = 6 or C.DocumentType = 1 then  IsNull(I.DocumentID, '')
,"[DocumentNumber]" = Isnull((Case When C.DocumentType = 4 or C.DocumentType = 6 or C.DocumentType = 1 then  Case When isnull(I.GSTFLAG,0)>0  Then Isnull(I.GSTFullDocID,'')   Else cast(IsNull(I.DocumentID, '') AS nvarchar(255))  End 
When C.DocumentType = 5 then  
cast(Isnull(D.DebitID, '') AS nvarchar(255)) end), '')
,"SCRef"  = Isnull(I.SONumber, '')
,"Order_ID" = Isnull(Ord.ORDERNUMBER, '')
,C.DocumentValue
,C.ExtraCollection
,C.Adjustment
,C.DocRef
,C.Others
,C.Discount  
FROM  CollectionDetail C
Inner Join collections CL On C.CollectionID = CL.DocumentID  and C.DocumentType in (4, 6, 1,5,2,3)
And   CL.DocumentID in (select distinct CD.CollectionID from CollectionDetail CD inner join  InvoiceAbstract IA on CD.DocumentID = IA.InvoiceID where CD.DocumentType in (4, 6, 1,5,2,3) And  IA.Balance > 0 )
And  (IsNull(CL.Status,0) & 64) = 0
And  (IsNull(CL.Status,0) & 128) = 0
And CL.CustomerID <> 'GIFT VOUCHER'
And CL.CustomerID Is Not Null
Left Outer Join InvoiceAbstract I On I.InvoiceID = C.DocumentID and C.DocumentType in (4, 6, 1) -- 4,6,1 Invoice
Left Outer Join DebitNote D On D.DocumentID = C.DocumentID and C.DocumentType = 5
Left Outer Join (Select Distinct ORDERNUMBER, SALEORDERID From Order_Details Where IsNull(SALEORDERID, 0) <> 0) Ord
on Ord.SALEORDERID = (Case When C.DocumentType = 4 or C.DocumentType = 6 or C.DocumentType = 1 then Isnull(I.SONumber, 0) else 0 end)
