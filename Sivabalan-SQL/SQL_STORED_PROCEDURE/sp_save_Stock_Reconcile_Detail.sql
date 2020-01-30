Create Procedure sp_save_Stock_Reconcile_Detail(@ReconcileID Integer, @Product_Code nvarchar(50), @BatchCode Varchar(max) = NULL)     
As  
Begin    
Insert Into ReconcileDetail(ReconcileID, Product_Code, Batch_code)    
Values  (@ReconcileID, @Product_Code,@BatchCode)  
End  
