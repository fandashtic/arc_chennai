 
Create PROCEDURE dbo.sp_list_InvoicewiseCollections (           
 @FROMDATE DATETIME,          
 @TODATE DATETIME, @TranName nvarchar(50)=N'')          

AS
Declare @CollID Int, @DebID Int, @ChqCollDocID Int, @ChqCollDocType Int
If @TranName=N''  
 Set @TranName=dbo.LookUpDictionaryItem(N'INVOICEWISE COLLECTION',Default)  

SELECT iwc.CollectionID, iwc.CollectionDate, (select Top 1 Prefix from VoucherPrefix where TranID=@TranName) + Convert(Nvarchar,iwc.DocumentID) as FullDocID,           
cld.DocumentValue, "CollAmt"=iwc.TotalValue,  iwc.DocumentID, iwc.Status, "DocID" = iwc.DocReference,       
"DocType" = iwc.DocSerialType, "CollDetCollID"=cld.CollectionID, "InvDebID" = cld.DocumentID, "InvDebType" = cld.DocumentType,
"DebitFlag" = (Case cld.DocumentType When 4 Then 0 Else (Select Flag From DebitNote Where DebitID = cld.DocumentID) End)
Into #tmpTable
From InvoicewiseCollectionAbstract iwc, collectiondetail CLD,Collections cl, InvoicewiseCollectionDetail iwcd, VoucherPrefix
where iwc.DocType=1 And iwc.CollectionDate between @FROMDATE and @TODATE AND iwc.CollectionID=iwcd.CollectionID 
And iwcd.DocumentID=cl.DocumentID And cl.DocumentID=CLD.CollectionID And cld.DocumentType in (4,5)
Group by iwc.CollectionID, iwc.CollectionDate, cld.DocumentValue, iwc.TotalValue, iwc.DocumentID, iwc.Status, 
iwc.DocReference, iwc.DocSerialType, cld.CollectionID, cld.DocumentID, cld.DocumentType
Order by iwc.CollectionDate

Declare CurDebID Cursor For
Select CollDetCollID, InvDebID From #tmpTable Where DebitFlag = 2
Open CurDebID
Fetch From CurDebID Into @CollID, @DebID
While @@Fetch_Status = 0
Begin
	Select @ChqCollDocID = DocumentID, @ChqCollDocType = DocumentType From ChequeCollDetails Where DebitID = @DebID
	If Exists(Select * From #tmpTable Where CollDetCollID = @CollID And InvDebID = @ChqCollDocID And InvDebType = @ChqCollDocType)
	Begin
		Delete From #tmpTable Where CollDetCollID = @CollID And InvDebID = @DebID And InvDebType = 5 And DebitFlag = 2
	End
	Else
	Begin
		If @ChqCollDocType = 4
			Update #tmpTable Set DocumentValue = (Select (Netvalue + RoundOffAmount) From InvoiceAbstract Where InvoiceID = @ChqCollDocID)
			Where CollDetCollID = @CollID And InvDebID = @DebID And InvDebType = 5 And DebitFlag = 2
		Else
			Update #tmpTable Set DocumentValue = (Select NoteValue From DebitNote Where DebitID = @ChqCollDocID)
			Where CollDetCollID = @CollID And InvDebID = @DebID And InvDebType = 5 And DebitFlag = 2
	End
	Fetch Next From CurDebID Into @CollID, @DebID
End
Close CurDebID
Deallocate CurDebID

Select * Into #tmpResults From #tmpTable

Select CollectionID, CollectionDate, FullDocID, Sum(DocumentValue) as DocumentValue, CollAmt, 
DocumentID, Status, DocID, Isnull(DocType, '') as DocType
From #tmpResults
Group By CollectionID, CollectionDate, FullDocID, CollAmt, DocumentID, Status, 
DocID, IsNull(DocType, '')

Drop Table #tmpResults
Drop Table #tmpTable
