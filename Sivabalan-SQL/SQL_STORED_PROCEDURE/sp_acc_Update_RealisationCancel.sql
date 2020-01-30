CREATE Procedure sp_acc_Update_RealisationCancel(@CollectionID Int)    
As
Begin
	Declare @DebitNoteID Int    
	Declare @BouncedDebitID Int    
	/*Update Collections Table*/    
	Update Collections Set    
	Realised = Realised + 3 /*Means 4 = Realisation Cancel ; 5 = Bounced Cancel*/    
	Where DocumentID = @CollectionID And IsNULL(Realised,0) In (1,2)    
	/*Update DebitNote Table*/    
	Select @DebitNoteID = IsNULL(BankChargesDebitID,0), @BouncedDebitID = IsNULL(DebitID,0) from Collections Where DocumentID = @CollectionID    
	Update DebitNote Set    
	Status = (IsNULL(Status,0) | 192), Balance = 0    
	Where DebitID In(@DebitNoteID,@BouncedDebitID)/*This Part will cancel both Debit Notes*/  
	/*New Implementation (Multiple Debit/Credit Notes)*/  
	Update DebitNote Set   
	Status = (IsNULL(Status,0) | 192), Balance = 0    
	Where DebitID In(Select NoteID from BounceNote Where CollectionID=@CollectionID And Type=1)  
	/*Also Update CreditNote Table if any?*/  
	Update CreditNote Set   
	Status = (IsNULL(Status,0) | 192), Balance = 0    
	Where CreditID In(Select NoteID from BounceNote Where CollectionID=@CollectionID And Type=2)

	If Exists(Select * From ChequeCollDetails Where IsNull(RepresentID,0) = @CollectionID)
		Update ChequeCollDetails Set ChqStatus = IsNull(ChqStatus, 0) + 3 Where RepresentID = @CollectionID
	Else
		Update ChequeCollDetails Set ChqStatus = IsNull(ChqStatus, 0) + 3 Where CollectionID = @CollectionID
End
