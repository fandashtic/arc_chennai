Create Procedure mERP_sp_save_SupervisorSalesmanLink(
    @SupervisorID Int, @SalesmanID Int)
As
Begin
   Insert into tbl_mERP_SupervisorSalesman(SupervisorId, SalesmanID) Values (@SupervisorID, @SalesmanID)
   Select @@ROWCOUNT
End
