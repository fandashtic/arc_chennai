CREATE Procedure sp_acc_gj_paymentexist(@paymentid integer,@BackDate DATETIME=Null)
as
declare @npaymentid integer,@dpaymentdate datetime,@nvalue decimal(18,6),@dapaymentdates datetime
declare @accountid integer,@npaymentmode integer,@cash integer
declare @documentid integer,@nvendorid nvarchar(15),@ndoctype integer,@postdatedcheque integer
declare @chequedate datetime,@bankid integer,@bankaccount integer,@extracol decimal(18,6),@adjamt decimal(18,6) 
declare @discount integer,@othercharges integer,@currentdate datetime
set @cash =3		 /* Constant to store the Cash AccountID*/	
set @ndoctype=17          /* Constant to store the Document Type*/	
set @accountid=0         /* variable to store the Vendor's AccountID*/	
set @postdatedcheque =8  /* Constant to store the Post Dated Cheque AccountID*/	          
set @discount =13	 /* Constant to store the Discount AccountID*/
set @othercharges=14  	 /* Constanat to store the OtherCharges AccountID*/
set @bankaccount =0	 /* variable to store the BankAccounts AccountID*/ 

Create Table #TempBackdatedpaymentexists(AccountID Int) --for backdated operation
                                   
select @npaymentid = [DocumentID],@dpaymentdate = [DocumentDate],@nvalue = ISNULL(Value,0),@nvendorid=ISNULL([VendorID],0),@npaymentmode = [PaymentMode],@bankid = [BankID],@chequeDate = [Cheque_Date] from Payments
where [DocumentID]=@Paymentid

select @accountid=ISNULL([AccountID],0)
from [Vendors]
where [VendorID]=@nvendorid  

/* if paymentmode is 0 then CASH payment*/
/* if paymentmode is 1 then CHEQUE payment*/
/* if paymentmode is 2 then DD payment*/


if @accountid <> 0 and @npaymentmode = 0
begin
	begin tran
  		update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 24
  		select @documentid = DocumentID - 1 from DocumentNumbers where DocType = 24
	commit tran
 
	insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
 	[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks])
 	Values(@documentid,@accountid,@dpaymentdate,@nvalue,0,@npaymentid,@ndoctype,'Cash Payment')  
	Insert Into #TempBackdatedpaymentexists(AccountID) Values(@accountid)

 	insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
 	[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks])
 	Values(@documentid,@cash,@dpaymentdate,0,@nvalue,@npaymentid,@ndoctype,'Cash Payment')  
	Insert Into #TempBackdatedpaymentexists(AccountID) Values(@cash)
end  
else if @accountid <> 0 and @npaymentmode =1 or @npaymentmode =2 
begin
  	begin tran
   		update DocumentNumbers set DocumentID = DocumentID + 1 where DocType = 24
   		select @documentid = DocumentID - 1 from DocumentNumbers where DocType = 24
  	commit tran
  
  	select @bankaccount = ISNULL([AccountID],0) from bank where [BankID]=@bankid

  	set dateformat dmy 
  	set @dpaymentdate = dbo.StripDateFromTime(@dpaymentDate)  
  	set @chequedate =   dbo.stripDateFromTime(@chequeDate)  
  
	/*to check whether the cheque is a current date cheque or postdated cheque*/ 
      
  	if @dpaymentdate = @chequedate
   	begin
    		insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
    		[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks])
    		Values(@documentid,@accountid,@dpaymentdate,@nvalue,0,@npaymentid,@ndoctype,'Current Date Cheque Payment')
		Insert Into #TempBackdatedpaymentexists(AccountID) Values(@accountid)

    		insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
    		[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks])
    		Values(@documentid,@bankaccount,@dpaymentdate,0,@nvalue,@npaymentid,@ndoctype,'Current Date Cheque Payment')
		Insert Into #TempBackdatedpaymentexists(AccountID) Values(@bankaccount)
   	end
  	else if @chequedate > @dpaymentdate
    	begin
     		insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
     		[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks])
     		Values(@documentid,@accountid,@dpaymentdate,@nvalue,0,@npaymentid,@ndoctype,'Post Dated Cheque Payment')
		Insert Into #TempBackdatedpaymentexists(AccountID) Values(@accountid)
    
     		insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
     		[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks])
     		Values(@documentid,@postdatedcheque,@dpaymentdate,0,@nvalue,@npaymentid,@ndoctype,'Post Dated Cheque Payment')
		Insert Into #TempBackdatedpaymentexists(AccountID) Values(@postdatedcheque)
     
-- --      		set @currentdate = dbo.StripDateFromTime(getdate())  	
     		set @currentdate = dbo.stripdatefromtime(dbo.Sp_Acc_GetOperatingDate(getdate()))

     		if @chequedate < @currentdate
      		begin

		        insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
        		[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks])
        		Values(@documentid,@postdatedcheque,@chequedate,@nvalue,0,@npaymentid,@ndoctype,'Auto Entry On Postdated Cheque')  
			Insert Into #TempBackdatedpaymentexists(AccountID) Values(@postdatedcheque)

		        insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
        		[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks])
        		Values(@documentid,@bankaccount,@chequedate,0,@nvalue,@npaymentid,@ndoctype,'Auto Entry On Postdated Cheque')         
			Insert Into #TempBackdatedpaymentexists(AccountID) Values(@bankaccount)
      		end 
    	end
     
end

select @extracol= sum([ExtraCol]),@adjamt = sum([Adjustment]) from paymentdetail 
where [PaymentID]=@Paymentid 
  

if @extracol > 0
begin

    	insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
    	[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks])
    	Values(@documentid,@accountid,@dpaymentdate,@extracol,0,@npaymentid,@ndoctype,'Extra Amount Collected')   
	Insert Into #TempBackdatedpaymentexists(AccountID) Values(@accountid)
    
    	insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
    	[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks])
    	Values(@documentid,@othercharges,@dpaymentdate,0,@extracol,@npaymentid,@ndoctype,'Extra Amount Collected')
	Insert Into #TempBackdatedpaymentexists(AccountID) Values(@othercharges)
end
  
if @adjamt > 0 
begin

	insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
    	[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks])
    	Values(@documentid,@accountid,@dpaymentdate,@adjamt,0,@npaymentid,@ndoctype,'Adjusted with Shortage Collected')   
	Insert Into #TempBackdatedpaymentexists(AccountID) Values(@accountid)
    
    	insert GeneralJournal ([TransactionID],[AccountID],[TransactionDate],
    	[Debit],[Credit],[DocumentReference],[DocumentType],[Remarks])
    	Values(@documentid,@discount,@dpaymentdate,0,@adjamt,@npaymentid,@ndoctype,'Adjusted with Shortage Collected')
	Insert Into #TempBackdatedpaymentexists(AccountID) Values(@discount)
end

If @BackDate Is Not Null  
Begin
	Declare @TempAccountID Int
	DECLARE scantempbackdatedaccounts CURSOR KEYSET FOR
	Select AccountID From #TempBackdatedpaymentexists
	OPEN scantempbackdatedaccounts
	FETCH FROM scantempbackdatedaccounts INTO @TempAccountID
	WHILE @@FETCH_STATUS =0
	Begin
		Exec sp_acc_backdatedaccountopeningbalance @BackDate,@TempAccountID
		FETCH NEXT FROM scantempbackdatedaccounts INTO @TempAccountID
	End
	CLOSE scantempbackdatedaccounts
	DEALLOCATE scantempbackdatedaccounts
End
Drop Table #TempBackdatedpaymentexists



