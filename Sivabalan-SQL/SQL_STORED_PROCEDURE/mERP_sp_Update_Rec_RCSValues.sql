CREATE Procedure mERP_sp_Update_Rec_RCSValues  
(@RCSHead nVarchar(50),@RCSValue nVarChar(50),@RCSPos Integer)  
AS  
Begin  


	If @RCSPos = 4 --Zone
	Begin
		IF Not exists(Select ZoneID From tbl_mERP_Zone Where ZoneName = @RCSValue)                          
		Begin                          
			insert into tbl_mERP_Zone (ZoneName) values(@RCSValue)                              
		End
	End
	Else If @RCSPos = 3 --Active In RCS
	Begin
		If (Select COUNT(*) from Cust_TMD_Master Where TMDValue = @RCSValue and TMDCtlPos = @RCSPos and TMDName = @RCSHead)> 0
		Begin 
		  Goto skip
		End

		If ( Select COUNT(*) from Cust_TMD_Master Where TMDValue = @RCSValue and TMDCtlPos = @RCSPos and TMDName <> @RCSHead) > 0
		Begin
  			Update Cust_TMD_Master Set TMDName = @RCSHead Where TMDCtlPos = @RCSPos
		End
		Else if (Select COUNT(*) from Cust_TMD_Master Where  TMDValue <> @RCSValue and TMDCtlPos = @RCSPos) > 0
		Begin 
 			Insert Into Cust_TMD_Master (TMDName,TMDValue,TMDCtlPos,Active) values (@RCSHead,@RCSValue,@RCSPos,1)
			If ( Select COUNT(*) from Cust_TMD_Master Where  TMDName = @RCSHead ) >= 1
			Begin
				Update Cust_TMD_Master Set TMDName = @RCSHead Where TMDCtlPos = @RCSPos
			End
		End
		Else if (Select COUNT(*) from Cust_TMD_Master Where  TMDName <> @RCSHead and TMDCtlPos = @RCSPos) = 0
		Begin
			Insert Into Cust_TMD_Master (TMDName,TMDValue,TMDCtlPos,Active) values (@RCSHead,@RCSValue,@RCSPos,1) 
		End
	End  
End

skip:

