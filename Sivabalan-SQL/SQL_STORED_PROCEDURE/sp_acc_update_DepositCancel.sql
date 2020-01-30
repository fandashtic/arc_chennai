CREATE Procedure sp_acc_update_DepositCancel(@DepositID Int)    
AS
Begin
Declare @CollectionID Int
/*Update Deposits*/  
Update Deposits Set Status = (IsNULL(Status,0) | 192)     
Where DepositID = @DepositID    
/*Update Collections*/    
Update Collections Set Status = 2  
Where DepositID = @DepositID And IsNULL(Realised,0) In (0,4,5)

Select @CollectionID = DocumentID From Collections 
Where IsNull(DepositID, 0) = @DepositID And IsNULL(Realised,0) In (0,4,5)

If Exists(Select * From ChequeCollDetails Where IsNull(RepresentID,0) = @CollectionID)
	Update ChequeCollDetails Set ChqStatus = 0 Where RepresentID = @CollectionID
Else
	Update ChequeCollDetails Set ChqStatus = 0 Where CollectionID = @CollectionID
End
