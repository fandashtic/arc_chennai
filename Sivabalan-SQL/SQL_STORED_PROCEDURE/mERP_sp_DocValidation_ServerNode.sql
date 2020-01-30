CREATE procedure mERP_sp_DocValidation_ServerNode
(
@DocNumber nVarChar(255),
@TransactionType Int,
@Flag1 Int = 0,
@Flag2 nVarchar(1000) = Null
)
As
--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$-- 
--$$                        Transaction List                                     $$--
--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--
--$$ Validate a document it may be processed by another user trhough Server/Node $$--
--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--
--$$ 01. Sales Return [Received from Handheld] - HHSR
--$$ 02. Invoice From SC [SC Document Validation]
--$$ 03. Invoice From Dispatch [Dispatch document Validation]
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
--$$ @Flag1 and @Flag2 are added for transaction type 1
--$$ ie. [Sales Return [Received from Handheld] - HHSR]
--$$ @Flag1 for Return Type and @Flag2 for CategoryGroupID
--$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$--



Declare @Status Int
Set @Status = 0
If @TransactionType = 1
Begin
	Create table #temp(GrpID int)
	Insert Into #temp
	Select * from dbo.sp_splitin2Rows(@Flag2, ',')

	Select @Status = Max(Processed) from Stock_Return 
		Where ReturnNumber = @DocNumber And ReturnType = @Flag1 -- And CategoryGroupID = @Flag2
		And CategoryGroupID in (Select GrpID from #temp)
			  And Processed <> 2

	If IsNull(@Status,0) = 1
		Select 1
	Else
		Select 0

	Drop table #temp	
	GoTo Done
End
If @TransactionType = 2
Begin
	Select @Status = Status from SOAbstract Where SONumber = Cast(@DocNumber as Integer)
	If IsNull(@Status,0) & 128 <> 0
		Select 1
	Else
		Select 0

	GoTo Done
End
If @TransactionType = 3
Begin
	Select @Status = Status from DispatchAbstract Where DispatchID = Cast(@DocNumber as Integer)
	If IsNull(@Status,0) & 128 <> 0
		Select 1
	Else
		Select 0

	GoTo Done
End

-- For unknown Transactin Type
Select 0

Done:
