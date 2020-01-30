Create Procedure mERP_sp_Update_AEActivity_LogReference(@TransType nVarchar(250), @BaseTransID Int, @LogID Int, @BaseTransDocRef nVarchar(50) = NULL)                
As                
Begin                
  If @TransType = 'AELOGIN'                
  Begin                
      Update tbl_mERP_AEActivity Set AEAuditLogID = @LogID Where ID  = @BaseTransID                
  End                
  Else If @TransType = 'OUTLET CLASSIFICATION'                
  Begin                
      Update tbl_mERP_OLClassMapping Set AEAuditLogID = @LogID Where CustomerID  = @BaseTransDocRef And ID = @BaseTransID   And Active = 1               
  End          
  Else IF @TransType = 'DISPLAY SCHEME BUDGET ALLOCATION'                
  Begin                
      Update tbl_mERP_DispSchBudgetPayout Set AEAuditLogID = @LogID Where PayoutPeriodID  = @BaseTransID          
  End            
  Else IF @TransType = 'Customer Active/Deactive'                
  Begin                
      Update tbl_mERP_CustActiveDeactive Set AEAuditLogID = @LogID Where ID  = @BaseTransID And CustomerID  = @BaseTransDocRef          
  End                
  Else IF @TransType = 'Customer Category Handler'                
  Begin        
    If @BaseTransID = 999999        
 Begin         
  Update CustomerProductCategory Set AEAuditLogID = @LogID Where CustomerID  = @BaseTransDocRef And IsNull(AEAuditLogID,N'') = N''        
 End          
    Else            
 Begin        
      Update CustomerProductCategory Set AEAuditLogID = @LogID Where CategoryID  = @BaseTransID And CustomerID  = @BaseTransDocRef        
 End          
  End                
  ELSE IF @TransType = 'ADD NEW CUSTOMER'        
  BEGIN      
 Update tbl_mERP_AEActivity Set AEAuditLogID = @LogID Where ID  = @BaseTransID      
 Update Customer_Type_Log Set Active = 0 Where CustomerID = @BaseTransDocRef And Active = 1
 insert into Customer_Type_Log (AEAuditLogID,CustomerID,Active) Values (@LogID,@BaseTransDocRef,1)      
  END      
  ELSE IF @TransType = 'Modify CUSTOMER'        
  BEGIN      
 Update tbl_mERP_AEActivity Set AEAuditLogID = @LogID Where ID  = @BaseTransID
 Update Customer_Type_Log Set Active = 0 Where CustomerID = @BaseTransDocRef And Active = 1        
 insert into Customer_Type_Log (AEAuditLogID,CustomerID,Active) Values (@LogID,@BaseTransDocRef,1)      
  END      
  ELSE IF @TransType = 'OUTLET CLASSIFICATION CHANGED'        
  BEGIN      
 Update tbl_mERP_AEActivity Set AEAuditLogID = @LogID Where ID  = @BaseTransID          
  END      
  
End 
