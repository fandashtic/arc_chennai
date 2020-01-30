Create Procedure sp_update_Reconcile_Quantity (@ReconcileID Integer, @ItemCode nvarchar(50), @PhysicalQty as Decimal(18,6), @ActualQty as Decimal(18,6), @Diff as Decimal(18,6), @nReconciled as Int, @BatchCode as Int, @Reason nVarchar(Max))      
As      
Begin  
  Declare @UpdateSQL nvarchar(2000)   
  If (Select Count(ReconcileID) from ReconcileDetail Where ReconcileID = @ReconcileID And Product_Code = @ItemCode And Batch_code = Cast(@BatchCode as nVarchar)) = 0   
  Begin  
    Declare @BatchInfo nVarchar(Max)  
    Declare Cur_FindBatch Cursor For   
    Select Batch_Code From ReconcileDetail Where ReconcileID = @ReconcileID And Product_Code = @ItemCode  
    Open Cur_FindBatch  
    Fetch Next From Cur_FindBatch into @BatchInfo  
    While @@Fetch_Status = 0  
    Begin  
      If Exists(Select * from dbo.fn_SplitIn2Rows_Int(@BatchInfo, N',') Where ItemValue = @BatchCode)  
      Begin  
         Update ReconcileDetail Set PhysicalQuantity = IsNull(PhysicalQuantity,0) +  @PhysicalQty, ActualQuantity = IsNull(ActualQuantity,0) +  @ActualQty , [Difference] = IsNull([Difference],0) + @Diff, 
         StockReconciled = @nReconciled, Reason= @Reason  
         Where Current of Cur_FindBatch  
      End   
   Fetch Next From Cur_FindBatch into @BatchInfo     
    End   
    close Cur_FindBatch  
    Deallocate Cur_FindBatch   
  End   
  Else   
  Begin   
    Set @UpdateSQL = N'Update ReconcileDetail Set PhysicalQuantity = ' + Cast(@PhysicalQty as nvarchar) + N', ActualQuantity = ' + Cast(@ActualQty as nvarchar) +
                     N', Difference = ' + Cast(@Diff as nvarchar) + N', StockReconciled = ' +  Cast(@nReconciled as nvarchar) + N', Reason =''' + @Reason + 
                     ''' Where ReconcileID = ' + Cast(@ReconcileID as nvarchar) + N' And Product_Code = N''' + @ItemCode + ''' And Batch_code =N''' + Cast(@BatchCode as nVarchar)+ ''''        
    exec sp_executesql @UpdateSQL  
  End   
End
