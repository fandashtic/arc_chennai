Create Procedure mERP_sp_Get_SalesmanSupervisorLink(@SupervisorID Int)
As
Begin
  Select SM.SalesmanId, SM.Salesman_Name From Salesman SM, tbl_mERP_SupervisorSalesman SPRLnk
  Where SPRLnk.SupervisorID = @SupervisorID and SPRLnk.SalesmanId = SM.SalesmanId
  Order by 1
End 
