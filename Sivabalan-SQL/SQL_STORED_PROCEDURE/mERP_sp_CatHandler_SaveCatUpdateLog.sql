Create Procedure mERP_sp_CatHandler_SaveCatUpdateLog(@AEAuditLogID Int, @CustomerCode nVarchar(50))  
as  
Begin  
  Insert into tbl_mERP_CatHandler_Log(AEAuditLogID, CustomerID) Values (@AEAuditLogID, @CustomerCode)  
   Select @@RowCount  
End  
