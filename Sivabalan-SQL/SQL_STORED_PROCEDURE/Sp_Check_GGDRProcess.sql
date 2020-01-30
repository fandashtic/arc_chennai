Create Procedure Sp_Check_GGDRProcess
As
Begin
	select Count(*) NoOFGGDR From GGDROutlet where Isreceived=1
End
