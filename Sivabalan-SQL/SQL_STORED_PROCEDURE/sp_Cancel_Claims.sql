CREATE Procedure sp_Cancel_Claims  (@ClaimID int,       
         @Remarks nvarchar(100)= N'',       
         @UserName nvarchar(10)= N'',       
         @CancelDate datetime = Null )      
As      
Declare @ItemCode nvarchar(15)      
Declare @Quantity Decimal(18,6)      
Declare @Batch nvarchar(255)      
Declare @Expiry datetime      
Declare @Price Decimal(18,6)      
Declare @SchemeType int      
Declare @ClaimType int      
Declare @BatchCode int      
Declare @ClaimAmt Decimal(18,6)      
Declare @InvID Integer      
Declare @InvClaimAmt Decimal(18,6)      
Declare @NewClaimAlready Integer      
Declare @InvoiceID Int       
Declare @ClaimProdCode nvarchar(15)     
Declare @ClaimInvoiceID Integer    
Declare @ClaimQty Decimal(18,6)      
Declare @Sno Int    
    
Select @ClaimType = ClaimType From ClaimsNote Where ClaimID = @ClaimID      
If @ClaimType = 5      
Begin      
 Declare @AdjRefID Int      
 Declare @AdjustedValue Decimal(18,6)      
 Declare CancelDoc Cursor Static For      
 Select AdjRefID, AdjustedValue From AdjClaimReference       
 Where ClaimID = @ClaimID      
 Open CancelDoc      
 Fetch From CancelDoc Into @AdjRefID, @AdjustedValue      
  While @@Fetch_Status = 0      
  Begin      
   Update AdjustmentReference Set Balance = Balance + @AdjustedValue      
   Where AdjRefID = @AdjRefID And IsNull(Status, 0) & 128 = 0      
   Fetch Next From CancelDoc Into @AdjRefID, @AdjustedValue      
  End      
 Close CancelDoc      
 DeAllocate CancelDoc      
End      
Else If @ClaimType = 6      
Begin      
 Declare AdjAmt Cursor For      
 Select InvoiceID, ClaimAmount From ClaimsDetail Where ClaimID = @ClaimID      
 Open AdjAmt      
 Fetch From AdjAmt Into @InvID, @ClaimAmt       
  While @@Fetch_Status = 0      
  Begin      
   Set @InvClaimAmt = (Select ClaimedAmount - @ClaimAmt from InvoiceAbstract Where InvoiceID = @InvID)      
   if Isnull(@InvClaimAmt, 0) = 0        
    Set @NewClaimAlready = 0         
   Else      
    Set @NewClaimAlready = 1      
   Update InvoiceAbstract Set ClaimedAmount = Isnull(ClaimedAmount, 0) - @ClaimAmt, ClaimedAlready = @NewClaimAlready Where InvoiceID = @InvID      
   Fetch Next From AdjAmt Into @InvID, @ClaimAmt       
  End      
 Close AdjAmt        
 DeAllocate AdjAmt      
End      
Else      
Begin      
 Declare CancelDoc Cursor Static For      
 Select Product_Code, Quantity, Batch, Expiry, PurchasePrice, SchemeType, Batch_Code     
 From ClaimsDetail    
 Where ClaimID = @ClaimID    
      
 Open CancelDoc      
 Fetch From CancelDoc Into @ItemCode, @Quantity, @Batch, @Expiry, @Price,     
  @SchemeType, @BatchCode    
  While @@Fetch_Status = 0      
  Begin      
   If (@ClaimType = 1)      
   Begin      
   Update Batch_Products Set Flags = 0,       
   ClaimedAlready = IsNull(ClaimedAlready, 0) - @Quantity      
   Where Batch_Code = @BatchCode      
   End      
   Fetch Next From CancelDoc Into @ItemCode, @Quantity, @Batch, @Expiry, @Price,     
   @SchemeType, @BatchCode       
  End      
 Close CancelDoc      
 DeAllocate CancelDoc      
    
 Declare CancelSchemeClaim Cursor Static For     
 Select ClaimSchemes.Product_Code, ClaimSchemes.Quantity, SchemeSale.InvoiceID, SchemeType,SchemeSale.SERIAL,IsNull(SchemeSale.sno,0)    
 From SchemeSale, ClaimSchemes    
 Where ClaimID = @ClaimID    
 And  SchemeSale.product_Code = ClaimSchemes.Product_Code    
 And SchemeSale.InvoiceID = ClaimSchemes.InvoiceID    
 And ClaimSchemes.SchemeType = SchemeSale.Type    
 and ClaimSchemes.serial = SchemeSale.Serial    
 and IsNull(ClaimSchemes.Sno,0)=IsNull(SchemeSale.Sno,0)    
 group by ClaimSchemes.Quantity,SchemeType,ClaimSchemes.Product_Code,SchemeSale.SERIAL,SchemeSale.InvoiceID,SchemeSale.sno    
  
     
 Declare @ClaimedAlready as int    
 --To update pending quantity peoperly serial column also taken.     
 --New filed serial is introduced in schemeclaim table and respective serial is stored    
 Declare @Serial int    
 Open CancelSchemeClaim    
  Fetch From CancelSchemeClaim Into @ClaimProdCode, @ClaimQty, @ClaimInvoiceID, @SchemeType,@Serial,@Sno    
 While @@Fetch_Status = 0      
  Begin     
   If @ClaimType = 4       
   Begin      
    Update SchemeSale Set Pending = IsNull(Pending, 0) + @ClaimQty, Claimed = 0       
    Where Product_Code = @ClaimProdCode And Type = @SchemeType and InvoiceID = @ClaimInvoiceID      
    and serial = @Serial and IsNull(Sno,0)=@Sno    
    -- Update ClaimedAlready in InvoiceAbstract Table      
    If exists (Select * from SchemeSale Where free <> Pending and InvoiceID = @ClaimInvoiceID)      
     Set @ClaimedAlready = 1     
    Else      
     Set @ClaimedAlready = 0     
  
    Update InvoiceAbstract Set ClaimedAlready = @ClaimedAlready Where InvoiceID = @ClaimInvoiceID     
   End      
   Fetch Next From CancelSchemeClaim Into @ClaimProdCode, @ClaimQty, @ClaimInvoiceID, @SchemeType,@Serial,@Sno  
  End    
 Close CancelSchemeClaim      
 DeAllocate CancelSchemeClaim     
End      
    
Update ClaimsNote Set Status = IsNull(Status, 0) | 192, Balance = 0,      
Remarks = @Remarks, CancelUserName = @UserName, CancelDate = @CancelDate      
Where ClaimID = @ClaimID      
    
    
  


