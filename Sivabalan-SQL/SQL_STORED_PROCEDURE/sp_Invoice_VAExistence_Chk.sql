Create Procedure sp_Invoice_VAExistence_Chk
(
	@GSTFullID nVarChar(255)
)
As
Begin

Select STUFF(
(Select ',' + VAA.FullDocID + Case When VAA.ShipmentNo > 0 Then '(' + CAST(VAA.ShipmentNo As nVarChar) + ')' Else '' End 
From VAllocAbstract VAA Join VAllocDetail VAD On VAD.VAllocID = VAA.ID 
Where VAD.GSTFullDocID = VD.GSTFullDocID And VAA.Status & 64 = 0 And VAD.GSTFullDocID = @GSTFullID For XML PATH('')),1,1,'') As VASlips
From VAllocAbstract VA Join VAllocDetail VD On VD.VAllocID = VA.ID And VA.Status & 64 = 0 And VD.GSTFullDocID = @GSTFullID 


END
