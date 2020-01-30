Create Procedure mERP_sp_ValidSlsManBeat(@SlsManID Int,@BeatID Int)
As
Begin
	Declare @SlsManActive Int
	Declare @BeatActive Int
	Declare @ValidMap Int

	Set @SlsManActive = 0
	Set @BeatActive = 0
	Set @ValidMap = 0


	If (Select Count(*) From Salesman Where Active = 1 And SalesmanID = @SlsManID) >= 1 
	Set @SlsManActive = 1
	
	If (Select Count(*) From Beat Where Active = 1 And BeatID = @BeatID) >= 1 
	Set @BeatActive = 1

	If (Select Count(*)  From Beat_Salesman Where SalesmanID = @SlsManID And BeatID = @BeatID) >= 1
	Set @ValidMap = 1

	Select  @SlsManActive 'Active Salesman',@BeatActive 'Active Beat', @ValidMap 'Valid Mapping'
	

End

