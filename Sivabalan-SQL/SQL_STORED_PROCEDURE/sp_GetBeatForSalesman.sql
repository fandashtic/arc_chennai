
Create Procedure sp_GetBeatForSalesman(@SalesmanID as int)
As
	Select Distinct(Beat_Salesman.BeatID), Beat.Description From Beat, Beat_Salesman 
		Where	Beat_Salesman.BeatID = Beat.BeatID
		And SalesmanID = @SalesmanID   	 
		And Beat.Active = 1


