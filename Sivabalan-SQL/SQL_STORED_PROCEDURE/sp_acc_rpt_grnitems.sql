CREATE PROCEDURE sp_acc_rpt_grnitems(@GRNID int)
AS
Declare @Start1 Int
Declare @Start2 Int
Declare @Version nVarchar(255)

Select @Version = dbo.sp_acc_getversion()    

Declare @SPECIALCASE Int
Set @SPECIALCASE = 5

If @Version = 2 or @Version = 3 or @Version = 6 or @Version = 16
Begin
	Execute sp_acc_rpt_grnitemswholesale @GRNID
End
Else If @Version = 1 or @Version = 4 or @Version = 7 or @Version = 17
Begin
	Execute sp_acc_rpt_grnitemsfmcg @GRNID
End
Else If @Version = 5 or @Version = 18 or @Version = 11
Begin
	Execute	sp_acc_rpt_grnitemswholesaleuom @GRNID
End
Else If @Version = 8 or @Version = 19
Begin
	Execute	sp_acc_rpt_grnitemsfmcguom @GRNID
End
Else If @Version = 9
Begin
	Execute sp_acc_rpt_grnitemswholesaleSerial @GRNID
End
Else If @Version = 10
Begin
	Execute sp_acc_rpt_grnitemsfmcgSerial @GRNID
End




