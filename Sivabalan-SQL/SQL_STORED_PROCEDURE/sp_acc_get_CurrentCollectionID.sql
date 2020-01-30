CREATE Procedure sp_acc_get_CurrentCollectionID (@Position Int,@CurCollectionID int = 0)
As
If @Position = 1 /* Last FA CollectionID */
Begin
	Select Top 1 DocumentID From 
	Collections where ISNULL(status,0) & 32 = 0  
	and (isnull(others,0) <> 0 or Isnull(ExpenseAccount,0) <> 0)
	Order By DocumentID Desc
End
Else if @Position = 2 /* Previous FA CollectionID */
Begin
	Select Top 1 DocumentID From Collections Where DocumentID < @CurCollectionID  
	and ISNULL(status,0) & 32 = 0 and (isnull(others,0) <> 0 or Isnull(ExpenseAccount,0) <> 0)
	Order By DocumentID Desc  
End
Else if @Position = 3 /* Next FA CollectionID */
Begin
   Select Top 1 DocumentID From Collections Where DocumentID > @CurCollectionID  
   and ISNULL(status,0) & 32 = 0 and (isnull(others,0) <> 0 or Isnull(ExpenseAccount,0) <> 0)
   Order By DocumentID  
End

