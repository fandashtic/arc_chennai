CREATE Procedure sp_acc_CanAmendAPV (@APVDocumentID as Int)  
AS  
Declare @AmendedCount Int  
Declare @CancelledCount Int  
Declare @IsSameBalance Int  
Declare @CANNOTAMEND Int  
Declare @CANAMEND Int  
  
Set @CANAMEND = 1  
Set @CANNOTAMEND = 0  
  
Select @AmendedCount = Count(*) from APVAbstract Where DocumentID = @APVDocumentID  
And (IsNull(Status, 0) & 128) <> 0  
  
Select @CancelledCount = Count(*) from APVAbstract Where DocumentID = @APVDocumentID  
And (IsNull(Status, 0) & 192) <> 0  
  
If @AmendedCount > 0 Or @CancelledCount > 0  
 Begin  
  Select @CANNOTAMEND  
 End  
Else  
 Begin  
  Select @IsSameBalance = Count(*) From APVAbstract Where DocumentID = @APVDocumentID And AmountApproved = balance
  If @IsSameBalance > 0  
   Begin    
    Select @CANAMEND  
   End  
  Else  
   Begin     
    Select @CANNOTAMEND  
   End  
 End  


