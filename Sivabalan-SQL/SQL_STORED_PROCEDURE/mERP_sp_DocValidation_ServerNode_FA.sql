CREATE procedure mERP_sp_DocValidation_ServerNode_FA
(
@DocNumber int,
@TransactionType Int
)
As
--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--
--$$                        Transaction List                                     $$--
--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--
--$$ Validate a document it may be processed by another user trhough Server/Node $$--
--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--
--$$ 01. ARV
--$$ 02. Receipts
--$$ 03. 
--$$ 04.
--$$ 05.
--$$ 06.
--$$ 07.
--$$ 08.
--$$ 09.
--$$ 10.
--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--
--$$           'Unable to save. This document already processed.'                $$--
--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--

Declare @Status Int
Set @Status = 0
If @TransactionType = 1
Begin
	Select @Status = status from ARVAbstract 
		Where DocumentID = @DocNumber 
	If IsNull(@Status,0) & 192 <> 0
		Select 1
	Else
		Select 0

	GoTo Done
End
If @TransactionType = 2
Begin
	Select @Status = Status from COLLECTIONS Where DocumentID = @DocNumber
	If IsNull(@Status,0) & 192 <> 0
		Select 1
	Else
		Select 0

	GoTo Done
End


-- For unknown Transaction Type
Select 0
Done:
