


CREATE Procedure sp_acc_insertGJ ( @TRANSACTIONID INT,
				   @ACCOUNTID INT,
				   @TRANSACTIONDATE DATETIME,
				   @DEBIT FLOAT,
				   @CREDIT FLOAT,
				   @DOCREF INT,
				   @DOCTYPE INT,
		 		   @REMARKS NVARCHAR(300),
				   @DOCUMENTNUMBER INT)	
as
Insert into GeneralJournal ( TransactionID,
			     AccountId,
			     TransactionDate,
			     Debit,
			     Credit,
			     DocumentReference,
			     DocumentType,
			     Remarks,
			     DocumentNumber)	
Values	( @TRANSACTIONID,
	  @ACCOUNTID,
	  @TRANSACTIONDATE,
	  @DEBIT,
	  @CREDIT,
	  @DOCREF,
	  @DOCTYPE,
	  @REMARKS,
	  @DOCUMENTNUMBER)









