
CREATE PROCEDURE dbo.sp_Cancel_InvoicewiseCollection_for_Amendment(@CollectionID int, @AmendedDocID nVarchar(4000))            
As 
Begin
Declare @ColId as int

Create Table #tmpDocID(AmendedDocID nVarchar(1000))
Insert into #tmpDocID select * from dbo.sp_SplitIn2Rows(@AmendedDocID, ',')

Declare INVCOLLECTION_CURSOR CURSOR STATIC FOR  
Select DocumentID From InvoicewiseCollectionDetail Where CollectionID=@CollectionID
Open INVCOLLECTION_CURSOR  
Fetch From INVCOLLECTION_CURSOR INTO @ColID
While @@FETCH_STATUS = 0  
Begin  
	If Exists(Select * From #tmpDocID Where AmendedDocID = @ColID)
		Exec sp_Cancel_Collection_for_Amendment @ColID
	Else
		Exec sp_Cancel_Collection @ColID  
	FETCH NEXT FROM INVCOLLECTION_CURSOR INTO  @ColID
End
Update InvoicewiseCollectionAbstract Set Status = (IsNull(Status,0) | 128) Where CollectionID = @CollectionID
Close INVCOLLECTION_CURSOR
Deallocate INVCOLLECTION_CURSOR

Drop Table #tmpDocID
End

