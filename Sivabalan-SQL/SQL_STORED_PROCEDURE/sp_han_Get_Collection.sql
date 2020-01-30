Create Procedure sp_han_Get_Collection    
AS    
  
Select    
"SerialNO" = IsNull(COLD.[Collection_Serial],'')    
,"DocumentID" = IsNull(COLD.[AgainstBillNo],0)    
,"CollectionDate" = COLD.[CollectionDate]    
,"AmtCollected" = IsNull(COLD.[AmountCollected],0)    
,"PaymentMode" = IsNull(COLD.[CollectionType],0)    
,"ChequeNumber" = IsNull(COLD.[CheqNo_DDNo],'')    
,"ChequeDate" = COLD.[CheqDate_DDDate]    
,"CustomerID" = IsNull(COLD.[CustomerID],'')    
,"SalesManID"=  IsNull(COLD.[SalesManID],0)    
,"BeatID"=  IsNull(COLD.[BeatID],0)    
,"BankCode" = IsNull(COLD.[BankCode],'')    
,"BranchCode" = IsNull(COLD.[BranchCode],'')    
,"CollectionFlag" = IsNull(COLD.[CollectionFlag],0)    
,"Discount" = IsNull(COLD.[DisCount],0)    
,"SerialNoCount" = (Select Count(Collection_Serial) From Collection_Details Where Collection_Serial = COLD.[Collection_Serial])  
From Collection_Details COLD WITH (NOLOCK)   
Where IsNull(COLD.[Processed],0) = 0    

