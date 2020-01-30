Create Procedure sp_Update_ReconcileDate (@ReconcileID Integer, @ReconcileDate DateTime, @Status Integer)
As
Update ReconcileAbstract Set ReconcileDate = @ReconcileDate, 
Status = @Status 
Where ReconcileID = @ReconcileID

