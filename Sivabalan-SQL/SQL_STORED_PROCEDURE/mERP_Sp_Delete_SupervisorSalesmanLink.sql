Create Procedure mERP_Sp_Delete_SupervisorSalesmanLink(@SupervisorID Int)
as
Begin
  Declare @Cnt Int
  Select @Cnt = Count(*) From tbl_mERP_SupervisorSalesman Where SupervisorID = @SupervisorID
  If @Cnt > 0 
   Begin
    Delete From tbl_mERP_SupervisorSalesman Where SupervisorID = @SupervisorID
    Select @@ROWCOUNT
   End
  Else
   Begin
    Select 1
   End
End
