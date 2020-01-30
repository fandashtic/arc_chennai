CREATE procedure Sp_update_WcpAbstract(@Code Bigint, @WeekDate datetime, @SalesmanId nVarchar(15), @docref nvarchar(510),                 
@DocSeriesType nvarchar(255),@DocumentDate datetime, @Status int)                
as                
Declare @DocumentID bigint          
      
select @DocumentID=documentid from wcpabstract where code=@Code          
      
update wcpabstract set status=status|32  where code=@code          
      
Insert into WcpAbstract      
(WeekDate,       
SalesmanId,       
DocRef,       
DocumentId,      
DocumentDate,DocSeriesType,              
Status,Reference,CreationDate)                
Values(@WeekDate,@SalesmanId, @DocRef, @DocumentId,@DocumentDate,@DocSeriesType, @Status,              
@DocumentID,getdate())             
select @@identity,@documentID          


