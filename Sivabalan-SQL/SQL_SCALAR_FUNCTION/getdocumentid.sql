


create function getdocumentid(@documentid integer)
returns nvarchar(30)
as 
begin
declare @fulldocid nvarchar(30)
select @fulldocid = [FullDocID] from Payments where [DocumentID]= @documentid
return @fulldocid
end





