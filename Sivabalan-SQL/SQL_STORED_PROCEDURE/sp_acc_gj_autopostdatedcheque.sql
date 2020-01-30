CREATE procedure sp_acc_gj_autopostdatedcheque
as
Set IMPLICIT_TRANSACTIONS OFF
declare @npaymentid integer,@dpaymentdate datetime,@nvalue decimal(18,6)
declare @accountid integer,@npaymentmode integer
declare @documentid integer,@nvendorid nvarchar(15),@ndoctype integer,@postdatedcheque integer
declare @chequedate datetime,@bankid integer,@bankaccount integer 
declare @currentdate datetime,@LastUpdated datetime
declare @uniqueid integer

set @ndoctype=19          /* Constant to store the Document Type*/	
set @accountid=0         /* variable to store the Vendor's AccountID*/	
set @postdatedcheque =8  /* Constant to store the Post Dated Cheque AccountID*/	          
set @bankaccount =0	 /* variable to store the BankAccounts AccountID*/ 

/* search for all the transaction*/
SET DATEFORMAT DMY
--Get the server date
-- -- set @CurrentDate = dbo.StripDateFromTime(getdate())
set @CurrentDate = dbo.stripdatefromtime(dbo.Sp_Acc_GetOperatingDate(getdate()))
--Get the Last updated date from the setup table
Select @LastUpdated=dbo.stripdatefromtime(LastPDCAutoEntryDate) from SetUp
--Select @LastUpdated=dbo.stripdatefromtime(max(OpeningDate)) from AccountOpeningBalance
If @LastUpdated is null 
Begin
	Select @LastUpdated=dbo.stripdatefromtime(OpeningDate) from SetUp
End
Else
Begin
	Set @LastUpdated=DateAdd(day,1,@LastUpdated) 
End

If @LastUpdated>@CurrentDate
Begin
	Delete GeneralJournal Where dbo.stripdatefromtime(TransactionDate) > @CurrentDate and DocumentType=19--Auto Entry
End

--loop continues until current date matched with lastupdated date
While @LastUpdated<=@CurrentDate
Begin
Begin Tran	
DECLARE scancheques CURSOR KEYSET FOR                                   

 select [DocumentID],[DocumentDate],[Value],[VendorID],[BankID],[Cheque_Date] from Payments
 where dbo.stripdatefromtime([Cheque_Date]) = dbo.stripdatefromtime(@LastUpdated) and 
 dbo.stripdatefromtime([DocumentDate]) < dbo.stripdatefromtime(cheque_date) and
 [PaymentMode]=1 and (IsNull(Status,0)& 64) = 0 and (IsNull(Status,0)& 128) = 0

OPEN scancheques

FETCH FROM scancheques into @npaymentid, @dpaymentdate, @nvalue, @nvendorid, @bankid,@chequedate
WHILE @@FETCH_STATUS = 0
 BEGIN 
    select @accountid=ISNULL([AccountID],0)
    from [Vendors]
    where [VendorID]=@nvendorid   
   
    select @bankaccount = ISNULL([AccountID],0) from bank
    where [BankID]=@bankid
    
    begin tran
     update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 24
     select @documentid = DocumentID - 1 from DocumentNumbers where DocType = 24
    commit tran
    
    begin tran
     update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 51
     select @uniqueid = DocumentID - 1 from DocumentNumbers where DocType = 51
    commit tran

if @nvalue <> 0
begin 
    insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
    [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])
    Values(@documentid,@postdatedcheque,@chequedate,@nvalue,0,@npaymentid,@ndoctype,'Auto Entry On Postdated Cheque',@uniqueid)  

    insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
    [Debit],[Credit],[DocumentReference],[DocumentType],[Remarks],[DocumentNumber])
    Values(@documentid,@bankaccount,@chequedate,0,@nvalue,@npaymentid,@ndoctype,'Auto Entry On Postdated Cheque',@uniqueid)  
end
   
   FETCH NEXT FROM scancheques into @npaymentid, @dpaymentdate, @nvalue, @nvendorid, @bankid,@chequedate 
 end
 CLOSE scancheques
 DEALLOCATE scancheques

Update Setup Set LastPDCAutoEntryDate=@LastUpdated
--Next day of the LastUpdated date
Set @LastUpdated=DateAdd(day,1,@LastUpdated) 

Commit Tran
End
Set IMPLICIT_TRANSACTIONS ON

