Create Procedure Sp_InsertRecd_WDStateCode(@RecID int,@GSTIN Nvarchar(15), @CS_StateID int,
				 @StateCode nVarChar(20),@StateName Nvarchar(255),@Doc_TrackID int)
As
Begin
	Set DateFormat DMY
	Insert Into Recd_WDStateCode (RecID,GSTIN,CS_StateID,StateCode,StateName,Doc_TrackID,Status)
	Select @RecID,@GSTIN,@CS_StateID,@StateCode,@StateName,@Doc_TrackID,0
	
End
