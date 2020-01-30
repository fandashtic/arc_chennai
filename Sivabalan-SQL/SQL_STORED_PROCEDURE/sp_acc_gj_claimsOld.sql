


CREATE procedure sp_acc_gj_claimsOld(@claimid integer)
as
DECLARE @nclaimid integer,@dclaimdate datetime,@nvendorid nvarchar(15)
DECLARE @nclaimvalue decimal (18,6),@claimsreceivable integer,@breakageexp integer,@documentid integer
DECLARE @ndoctype integer
declare @uniqueid integer

set @claimsreceivable =10  /*constant to store claimsreceivable Account*/ 
set @breakageexp=12	   /*constant to store breakageexpenses Account*/ 	
set @ndoctype=22		   /*constant to store the Document Type */ 	

select @nclaimid =[ClaimID],@dclaimdate =[ClaimDate],@nclaimvalue =[ClaimValue]
from claimsnote
 begin tran
  update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 24
  select @documentid = DocumentID - 1 from DocumentNumbers where DocType = 24
 commit tran

 begin tran
  update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 51
  select @uniqueid = DocumentID - 1 from DocumentNumbers where DocType = 51
 commit tran

if @nclaimvalue <> 0
begin
 insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
 [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])
 Values(@documentid,@claimsreceivable,@dclaimdate,@nclaimvalue,0,@nclaimid,@ndoctype,'Claims to Vendor',@uniqueid)  
end

if @nclaimvalue <> 0
begin		
 insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
 [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])
 Values(@documentid,@breakageexp,@dclaimdate,0,@nclaimvalue,@nclaimid,@ndoctype,'Claims to Vendor',@uniqueid)
end









