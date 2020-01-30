


CREATE procedure sp_acc_updateapvdetail(@documentid integer,@type integer,
@accountid integer,@amount decimal(18,6),@particular ntext)
as

insert APVDetail(DocumentID,
		 Type,
		 AccountID,
		 Amount,
		 Particular)
	  values(@documentid,
		 @type,
		 @accountid,
		 @amount,
		 @particular)		



