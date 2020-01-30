CREATE Procedure sp_CheckCollectionExist (@CollectionID Int)
As
--Check whether the collectionid is adjusted against invoice
Declare @Delimeter as Char(1)      
Set @Delimeter = ','
Declare @CollID as nvarchar(100)
Create Table #TmpCollectionID (CollectionID int)
Declare CurPaymentIDS Cursor For 
	(Select PaymentDetails 
	From InvoiceAbstract, CollectionDetail
	Where InvoiceAbstract.InvoiceType in (1,2,3,4) 
	And InvoiceAbstract.InvoiceID = CollectionDetail.DocumentID
	And CollectionDetail.CollectionID = @CollectionID)
Open CurPaymentIDS
Fetch Next From CurPaymentIDS Into @CollID
While @@Fetch_Status = 0
Begin
	Insert into #TmpCollectionID select * from dbo.sp_SplitIn2Rows(@CollID,@Delimeter)
	Fetch Next From CurPaymentIDS Into @CollID
End
Close CurPaymentIDS
Deallocate CurPaymentIDS
If Exists(Select CollectionID from #TmpCollectionID where CollectionID = @CollectionID)
	Begin
		Select 1
	End
Else
	Begin
		Select 0
	End

Drop Table #TmpCollectionID


