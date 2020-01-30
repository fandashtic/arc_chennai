
Create Procedure sp_Validate_SalesmanBeat(@SalesmanID int, @BeatID int)    
As    
Begin    
	Select Count(*) From Beat_Salesman Where SalesmanID=@SalesmanID And BeatID=@BeatID    
End   

SET QUOTED_IDENTIFIER OFF 
