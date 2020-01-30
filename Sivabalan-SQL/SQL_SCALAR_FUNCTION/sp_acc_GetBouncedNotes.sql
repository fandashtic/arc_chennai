CREATE Function sp_acc_GetBouncedNotes(@CollectionID INT)      
Returns VarChar(8000)      
As      
Begin      
 Declare @NoteID INT,@Type INT      
 Declare @AdjustedAmt Decimal(18,6)  
 Declare @DocDate DateTime  
 Declare @FullDocID VarChar(20)  
 Declare @ReturnStr VarChar(8000)      
 Set @ReturnStr = IsNULL(@ReturnStr,'')      
 If (Select IsNULL(DebitID,0) from Collections Where DocumentID=@CollectionID) <> 0
  Begin
   Select @NoteID = DebitID from Collections Where DocumentID=@CollectionID
   Set @Type = 1 /*Debit Note*/
   Select @AdjustedAmt=NoteValue,@FullDocID=VoucherPrefix.Prefix + Cast(DocumentID as VarChar),@DocDate=DocumentDate from DebitNote,VoucherPrefix Where DebitID=@NoteID And VoucherPrefix.TranID='DEBIT NOTE'  
   Set @ReturnStr = @ReturnStr + Char(2) + CAST(@NoteID As VarChar) + Char(1) + CAST(@Type As VarChar) + Char(1) + CAST(@AdjustedAmt As VarChar) + Char(1) + CAST(@FullDocID As VarChar) + Char(1) + CAST(@DocDate As VarChar)  
  End
 Else
  Begin
   Declare ScanBounceNote Cursor Keyset For      
    Select NoteID,Type from BounceNote Where CollectionID = @CollectionID      
   Open ScanBounceNote      
   Fetch From ScanBounceNote Into @NoteID,@Type      
   While @@Fetch_Status = 0      
    Begin      
     If @Type = 1  
      Select @AdjustedAmt=NoteValue,@FullDocID=VoucherPrefix.Prefix + Cast(DocumentID as VarChar),@DocDate=DocumentDate from DebitNote,VoucherPrefix Where DebitID=@NoteID And VoucherPrefix.TranID='DEBIT NOTE'  
     Else If @Type = 2  
      Select @AdjustedAmt=NoteValue,@FullDocID=VoucherPrefix.Prefix + Cast(DocumentID as VarChar),@DocDate=DocumentDate from CreditNote,VoucherPrefix Where CreditID=@NoteID And VoucherPrefix.TranID='CREDIT NOTE'  
    
     Set @ReturnStr = @ReturnStr + Char(2) + CAST(@NoteID As VarChar) + Char(1) + CAST(@Type As VarChar) + Char(1) + CAST(@AdjustedAmt As VarChar) + Char(1) + CAST(@FullDocID As VarChar) + Char(1) + CAST(@DocDate As VarChar)  
     Fetch Next From ScanBounceNote Into @NoteID,@Type      
    End      
   Close ScanBounceNote      
   DeAllocate ScanBounceNote      
  End
 If @ReturnStr <> ''       
  Set @ReturnStr = Right(@ReturnStr,Len(@ReturnStr)-1)      
 Return @ReturnStr      
End
