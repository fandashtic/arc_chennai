CREATE Function sp_acc_IsAlreadyAdjustedNote(@CollectionID INT)      
Returns INT
As      
Begin      
 Declare @NoteID INT,@Type INT      
 Declare @RetValue INT
 Declare @Count INT
 Set @RetValue = 1
 Declare ScanBounceNote Cursor Keyset For      
  Select NoteID,Type from BounceNote Where CollectionID = @CollectionID      
 Open ScanBounceNote      
 Fetch From ScanBounceNote Into @NoteID,@Type      
 While @@Fetch_Status = 0      
  Begin      
   If @Type = 1  
    Begin
     Select @Count = Count(*) From DebitNote Where DebitID = @NoteID And NoteValue = Balance
     If @Count = 0 
      GOTO StopLooping
    End
   Else If @Type = 2  
    Begin
     Select @Count = Count(*) From CreditNote Where CreditID = @NoteID And NoteValue = Balance
     If @Count = 0 
      GOTO StopLooping
    End
   Fetch Next From ScanBounceNote Into @NoteID,@Type      
  End      
 Set @RetValue = 0
StopLooping:  
 Close ScanBounceNote      
 DeAllocate ScanBounceNote      

 Return @RetValue      
End
