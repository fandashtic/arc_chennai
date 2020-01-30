CREATE Procedure sp_ChangeStatus_AdjRef_BillCancel (@BillID Int)
As
if exists(Select ReferenceID From AdjustmentReference Where InvoiceID = @BillID and TransactionType = 1)    
 Begin    
  Update DebitNote Set Status = 192, Balance = 0    
  Where DebitID In (Select ReferenceID From AdjustmentReference    
  Where InvoiceID = @BillID And DocumentType = 2 and TransactionType = 1)       
  Update CreditNote Set Status = 192, Balance = 0    
  Where CreditID In (Select ReferenceID From AdjustmentReference    
  Where InvoiceID = @BillID And DocumentType = 5  and TransactionType = 1)       
  Update AdjustmentReference Set Status = 128 Where InvoiceID = @billID  and TransactionType = 1 
 End    

