CREATE Procedure sp_Get_Adjusted_Documents (@InvoiceID Int,@CustomerID nvarchar(15)=N'')
As

Create Table #tmpDocList(
DocType Int,
DocID nVarchar(50)  COLLATE SQL_Latin1_General_CP1_CI_AS,
DocDate DateTime,
TranID Int,
Balance Decimal(18,6),
NetValue Decimal(18,6),
RecSchTag Int,
Memo nVarChar(255)  COLLATE SQL_Latin1_General_CP1_CI_AS,
AutoAdjFlag Int Default 0,
SplFreeSKUFlag Int Default 0)

Declare @CustID nVarChar(15)

Declare @CollectionID Int
if @customerID = N''
Select @CollectionID = Cast(PaymentDetails as Int),@CustID = CustomerID  From InvoiceAbstract
Where InvoiceID = @InvoiceID
Else
Select @CollectionID = Cast(PaymentDetails as Int), @CustID = @CustomerID  From InvoiceAbstract
Where InvoiceID = @InvoiceID and customerid = @CustomerID

Insert Into #tmpDocList(DocType, DocID, DocDate, TranID, Balance, NetValue, RecSchTag, Memo,SplFreeSKUFlag)
Select DocumentType, OriginalID, DocumentDate, DocumentID, abs(AdjustedAmount),
DocumentValue, 0, '',0  From CollectionDetail
Where CollectionID = @CollectionID And
DocumentType in (1, 3, 10)
Union All
Select ColDet.DocumentType, ColDet.OriginalID, ColDet.DocumentDate, ColDet.DocumentID, abs(ColDet.AdjustedAmount),
ColDet.DocumentValue, 0,  memo, CreditNote.FreeSKUFlag  From CollectionDetail ColDet, CreditNote
Where ColDet.CollectionID = @CollectionID And
CreditID = ColDet.DocumentID And
ColDet.DocumentType = 2 And ColDet.DocumentID Not In (Select ReferenceID From AdjustmentReference
Where InvoiceID = @InvoiceID and TransactionType = 0)

Select DocType, DocID, DocDate, TranID, Balance, NetValue, RecSchTag, Memo,
Case When (DocType = 2 Or DocType = 10) And IsNull(DSCR.CreditID,0) > 0  Then  1 Else 0 End,
IsNull(SplFreeSKUFlag,0)  SplFreeSKUFlag
From #tmpDocList DL
Left Join (Select Distinct DS.CreditID From CrNoteDSType DS
Join CreditNote CR On Cr.CreditID = DS.CreditID And CR.CustomerID = @CustID ) DSCR On DSCR.CreditID = DL.TranID
where IsNull(SplFreeSKUFlag,0)=0
