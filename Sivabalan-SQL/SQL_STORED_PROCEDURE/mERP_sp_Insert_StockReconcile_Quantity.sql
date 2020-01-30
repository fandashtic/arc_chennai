Create Procedure mERP_sp_Insert_StockReconcile_Quantity(@ReconcileID Int, @ItemCode nvarchar(50), @PhysicalQty as Decimal(18,6), @ActualQty as Decimal(18,6), @Diff as Decimal(18,6), @nReconciled as Int, @BatchCode as nVarchar(Max), @Reason nVarchar(Max))  
As  
Begin  
  /*To Update the StockReconciled Status for Zero Batch Code Entry before inserting new batch for the same product*/
  If Exists(Select Count(*) From ReconcileDetail Where ReconcileID = @ReconcileID And Product_code=@ItemCode And IsNull(Batch_code,'0') = '0' )
  Begin 
    Update ReconcileDetail Set StockReconciled = 1 Where ReconcileID = @ReconcileID And Product_code=@ItemCode And IsNull(Batch_code,'0') = '0'
  End 
  Insert into ReconcileDetail(ReconcileID,Product_code, PhysicalQuantity, ActualQuantity, [Difference],StockReconciled,Batch_code,Reason,NewBatch) values   
  (@ReconcileID, @ItemCode, @PhysicalQty, @ActualQty, @Diff, @nReconciled, @BatchCode, @Reason,1)  
  Select @@RowCount   
End
