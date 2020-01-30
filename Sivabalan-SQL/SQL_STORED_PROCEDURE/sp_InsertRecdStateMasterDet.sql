Create Procedure sp_InsertRecdStateMasterDet
				(@RecID Int, 
				@CS_StateID Int,
				@StateCode Nvarchar(5),
				@StateName Nvarchar(255)
				)
As
	Begin
		
		INSERT INTO Recd_StateMasterDet (RecID,StateID,StateCode,StateName,Status)
		Select @RecID, @CS_StateID ,@StateCode ,@StateName,0
						
	End
