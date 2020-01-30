CREATE procedure Sp_Save_WcpAbstract( @WeekDate datetime, @SalesmanId nvarchar(30), @docref nvarchar(510),         
@DocSeriesType nvarchar(510),@DocumentDate datetime, @Status int,@CreationDate datetime, @Reference int =0,@Remarks nvarchar(100)='',      
@CancelDate datetime= null, @CancelUser nvarchar(50)='')        
as        
Declare @DocumentID bigint    
Begin Tran        
 select @DocumentId=DocumentId from DocumentNumbers where DocType=61        
 update DocumentNumbers set DocumentId=DocumentId+1 where Doctype=61        
     
Commit Tran        
  
Insert into WcpAbstract( WeekDate,SalesmanId, DocRef, DocSeriesType, DocumentId,DocumentDate,      
Status,Reference,Remarks,CreationDate,CancelDate,CancelUser)        
Values(@WeekDate,@SalesmanId, @DocRef, @DocSeriesType, @DocumentId,@DocumentDate, @Status,      
@Reference,@Remarks,@CreationDate,@CancelDate,@CancelUser      
)        
  
select @@identity,@documentID         

