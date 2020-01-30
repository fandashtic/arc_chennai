Create Procedure sp_save_Stock_Reconcile_Abstract(@CreationDate DateTime, @Damage Decimal(18,6), @Status Int, @StockStatus Int, @DisplayUOM int, @DocDesc nVarchar(1100),@RecDocID Int)  
As  
Begin
Insert Into ReconcileAbstract(CreationDate, DamageStock, Status, StockStatus, UOM, Description,DocID)  
Values  (@CreationDate, @Damage, @Status, @StockStatus, @DisplayUOM,@DocDesc,@RecDocID)  
  
Update DocumentNumbers Set DocumentID = DocumentID + 1 Where DocType = 60  
Select @@Identity
End
