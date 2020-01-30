CREATE Procedure mERP_sp_Save_Reconcile_ReasonForBatch(@ReconcileID Int, @Batch_Code Int, @Reason nVarchar(Max))
As
Begin
  If Exists(Select * from tbl_merp_ReconcileBatchReason Where ReconcileID = @ReconcileID And Batch_Code = @Batch_Code)
    Begin
    Update tbl_merp_ReconcileBatchReason Set Reason = @Reason Where ReconcileID = @ReconcileID And Batch_Code = @Batch_Code
    End
  Else
    Begin
    Insert into tbl_merp_ReconcileBatchReason(ReconcileID, Batch_Code, Reason) Values(@ReconcileID, @Batch_Code, @Reason)
    End 
End
