Create Procedure dbo.sp_Cancel_InvoicewiseCollection(@CollectionID integer,@UserName nvarchar(50) = '',@CancelDate datetime = Null )  
AS  
Begin  
Declare @ColId as int  
Declare INVCOLLECTION_CURSOR CURSOR STATIC FOR    
Select DocumentID From InvoicewiseCollectionDetail Where CollectionID=@CollectionID  
Open INVCOLLECTION_CURSOR    
Fetch From INVCOLLECTION_CURSOR INTO @ColID  
While @@FETCH_STATUS = 0    
Begin    
 Exec sp_Cancel_Collection @ColID  
 FETCH NEXT FROM INVCOLLECTION_CURSOR INTO  @ColID  
End  
Update InvoicewiseCollectionAbstract Set Status = (IsNull(Status,0) | 64),CancelDate = @CancelDate ,CancelUser = @UserName Where CollectionID = @CollectionID  
Close INVCOLLECTION_CURSOR  
Deallocate INVCOLLECTION_CURSOR  
End  
