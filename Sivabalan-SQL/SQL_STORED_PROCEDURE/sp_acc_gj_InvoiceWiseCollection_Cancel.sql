CREATE Procedure sp_acc_gj_InvoiceWiseCollection_Cancel(@InvCollectID INT,@BackDate DateTime=NULL)
AS
Begin
 Declare @CollectionID INT

 Declare ScanInvCollections Cursor KeySet For
  Select DocumentID From InvoiceWiseCollectionDetail Where CollectionID=@InvCollectID
 Open ScanInvCollections
 Fetch From ScanInvCollections Into @CollectionID
 While @@FETCH_STATUS=0
  Begin
   Exec sp_acc_gj_CollectionCancel @CollectionID,@BackDate
   Fetch Next From ScanInvCollections Into @CollectionID
  End
 Close ScanInvCollections
 DeAllocate ScanInvCollections
End

