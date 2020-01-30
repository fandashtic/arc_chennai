create procedure sp_acc_insertmanualjournalnewreference(@ReferenceNo nVarchar(15),
@Amount Decimal(18,6),@PrefixType Int ,@Remarks nvarchar(255),@TransactionID Int,
@DocumentID Int,@AccountID Int,@DocumentDate DateTime,@RefID Int = 0)
as
Insert ManualJournal(ReferenceNo,
		     Amount,
		     Balance,	
                     PrefixType,
		     Remarks,
		     TransactionID,
		     DocumentID,
		     AccountID,
		     DocumentDate,
		     ReferenceID)
Values 		    (@ReferenceNo,
		     @Amount,
		     @Amount,	
                     @PrefixType,
		     @Remarks,
		     @TransactionID,
		     @DocumentID,
		     @AccountID,
		     @DocumentDate,
		     @RefID)
Select @@Identity



