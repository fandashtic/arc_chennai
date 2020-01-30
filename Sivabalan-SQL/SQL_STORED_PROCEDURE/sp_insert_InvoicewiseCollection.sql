
CREATE Procedure dbo.sp_insert_InvoicewiseCollection (          
@CollectionDate datetime,          
@DocReference nvarchar(255) = N'',          
@DocSerialType nvarchar(100) = N'',          
@DocType integer,          
@ReferenceNumber nvarchar(255) = N'',          
@TotalValue decimal(18,6) = 0,          
@CancelDate datetime,          
@Status integer,          
@UserName nvarchar(50),          
@CreationTime datetime,          
@AmendmentFlag integer = 0,          
@AmendmentDocID integer = 0,          
@DocPrefix nvarchar(50),  
@SalesmanID integer)    
As           
BEGIN          
Declare @szFullDocID nvarchar(50),@nDocID integer        
If @AmendmentFlag = 0            
Begin            
 Begin Tran          
 select @nDocID = DocumentID from DocumentNumbers where Doctype = 64          
 update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 64          
 Commit Tran            
 SET @szFullDocID = @DocPrefix + Convert(Nvarchar,@nDocID)      
End            
Else            
Begin            
 Select @nDocID=DocumentID From InvoicewiseCollectionAbstract Where CollectionID=@AmendmentDocID      
 SET @szFullDocID = @DocPrefix + Convert(Nvarchar,@nDocID)      
End            
insert into InvoiceWiseCollectionAbstract(          
CollectionDate,          
DocumentID,          
DocReference,          
DocSerialType,          
DocType,          
ReferenceNumber,          
TotalValue,          
CancelDate,          
Status,          
UserName,          
CreationTime,  
DocRefID,  
SalesmanID)            
values (          
@CollectionDate,          
@nDocID,          
@DocReference,          
@DocSerialType,          
@DocType,          
@ReferenceNumber,          
@TotalValue,          
@CancelDate,          
@Status,          
@UserName,          
@CreationTime,  
@AmendmentDocID,  
@SalesmanID)          
          
select @@IDENTITY, @szFullDocID          
          
END          

