CREATE Procedure sp_acc_List_BouncedNotes (@CollectionID INT)  
As  
If (Select IsNULL(DebitID,0) from Collections Where DocumentID=@CollectionID) = 0
 Begin
  Select DebitID,VoucherPrefix.Prefix + Cast(DocumentID As nVarChar),DocumentDate,Memo  
  From DebitNote,VoucherPrefix,BounceNote BN Where BN.CollectionID = @CollectionID  
  And BN.NoteID = DebitID And BN.Type = 1 And VoucherPrefix.TranID = N'DEBIT NOTE'  
  UNION  
  Select CreditID,VoucherPrefix.Prefix + Cast(DocumentID As nVarChar),DocumentDate,Memo  
  From CreditNote,VoucherPrefix,BounceNote BN Where BN.CollectionID = @CollectionID  
  And BN.NoteID = CreditID And BN.Type = 2 And VoucherPrefix.TranID = N'CREDIT NOTE'
 End
Else
 Begin
  Declare @DebitID INT
  Select @DebitID=DebitID from Collections Where DocumentID=@CollectionID
  Select DebitID,VoucherPrefix.Prefix + Cast(DocumentID as nVarChar),DocumentDate,Memo
  From DebitNote,VoucherPrefix Where DebitID=@DebitID And VoucherPrefix.TranID=N'DEBIT NOTE'
 End
