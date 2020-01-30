

CREATE procedure sp_acc_con_loadcompanylist(@FromDate DateTime,@ToDate DateTime,@Mode Int)
as
If @Mode =1
Begin
	Select Distinct(CompanyID) From ReceiveAccount Where Date = @ToDate
End
Else If @Mode =2
Begin
	Select Distinct(A.CompanyID) From ReceiveAccount A, ReceiveAccount B  Where A.Date = @FromDate and  B.Date = @ToDate
End



