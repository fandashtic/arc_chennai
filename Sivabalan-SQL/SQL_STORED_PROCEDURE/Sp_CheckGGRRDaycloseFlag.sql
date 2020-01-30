Create Procedure dbo.Sp_CheckGGRRDaycloseFlag
As
Begin
	select isnull(GGRRDaycloseFlag,0) from SetUp
End
