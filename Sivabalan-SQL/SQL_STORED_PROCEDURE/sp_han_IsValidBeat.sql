CREATE  Procedure sp_han_IsValidBeat(@BeatID Integer)      
As     
Select  BeatId from Beat Where BeatId = @BeatID  
