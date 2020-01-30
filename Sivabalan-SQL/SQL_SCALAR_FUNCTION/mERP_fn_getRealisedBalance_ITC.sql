CREATE Function mERP_fn_getRealisedBalance_ITC(@CollectionID Int)  
Returns Decimal(18,6)  
AS  
BEGIN  
	Declare @retvalue decimal(18,6), @DebitID Int, @Realised Int, @CollID Int  
	Declare @tmpC  Table (CollectionID int, Status Int, FlagBalance Decimal(18,6))  

	Insert into @tmpC   
	Select CCd.CollectionID, 1, 0 from ChequeColldetails CCD,DebitNote DN Where CCD.CollectionID = @CollectionID 
	And isnull(CCD.debitid,0) = DN.DebitID And DN.Balance = 0 And isnull(CCD.DebitID,0) <> 0  

	Set @retvalue = 0	
	Declare CurColl cursor For  
	Select IsNull(DebitID, 0) From ChequeCollDetails Where CollectionID In (Select CollectionID From @tmpC Where 
FlagBalance = 0)
  
	Open CurColl  
	Fetch From CurColl Into @DebitID  
	While @@Fetch_Status = 0  
	Begin  
		Select @Realised=IsNull(Realised, 0) From Collections Where DocumentID In   
		(Select CollectionID From ChequeCollDetails Where DocumentID = @DebitID And DocumentType = 5)  

		If @Realised = 1   
		Select @retvalue = @retvalue + Sum(Value) From Collections Where DocumentID In 
		(Select CollectionID From ChequeCollDetails Where DocumentID = @DebitID And DocumentType = 5)
	
		Fetch Next From CurColl Into @DebitID  
	End  
	Close CurColl  
	Deallocate CurColl  

	return @retvalue  
END
