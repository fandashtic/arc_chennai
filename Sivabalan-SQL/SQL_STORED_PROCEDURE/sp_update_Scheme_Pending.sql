Create Procedure sp_update_Scheme_Pending(            
 @ITEM_CODE nvarchar(15),             
 @TYPE INT,             
 @QTY Decimal(18,6),            
 @STO Integer = 0,             
 @ClaimID Integer = 0)      
AS              
 declare @PENDING Decimal(18,6)              
 declare @InvoiceID INT              
 declare @ExistQty Decimal(18,6)            
 declare @ClaimedQty Decimal(18,6)     
 declare @Sno int  
 declare @Value Decimal(18,6)     
 --To update pending quantity properly serial number also used.             
 declare @Serial int            
--cursor to fetch all unclaimed invoices, to claim FIFO basis              
 If @STO = 1            
 Begin            
  Declare curSchemePending Cursor              
  for              
  select  pending,  InvoiceID, Quantity  ,IsNull(Serial,0),IsNull(Sno,0), IsNull(Value,0)              
  FROM  schemesale               
  where  Product_Code = @ITEM_CODE              
  AND [Type] = @TYPE              
  and IsNull(claimed,0) = 0              
  And IsNull(SaleType,0) = 1            
  And Isnull(Flags, 0) = 1            
  order by invoiceid              
 End            
 Else            
 Begin            
  Declare curSchemePending Cursor              
  for              
  select pending,  InvoiceID,Quantity,IsNull(Serial,0),IsNull(Sno,0), IsNull(Value,0)            
  FROM  schemesale             
  where      
  SchemeSale.Product_Code = @ITEM_CODE          
  And [Type] = @TYPE          
  And claimed = 0              
  And IsNull(SaleType,0) = 0            
  And Isnull(Flags, 0) = 1            
  order by schemesale.invoiceid           
 End            
 open  curSchemePending              
 fetch next from curSchemePending into @PENDING, @InvoiceID, @ExistQty,@serial,@Sno, @Value
 while @@FETCH_STATUS=0                
 begin              
  if @Qty > 0  --untill claimed quantity > 0              
  begin              
   if @QTY < @PENDING        
   --for current invoice, if pending is less then claimed qty              
   begin            
    If @STO = 1             
     Update SchemeSale SET Pending = (@PENDING - @QTY)               
     WHERE  Product_Code = @ITEM_CODE AND               
     TYPE = @TYPE and               
     InvoiceID = @InvoiceID and               
     IsNull(Claimed,0) = 0  And IsNull(SaleType,0) = 1            
     And IsNull(Serial,0) = @serial            
     And Isnull(Sno,0)=@Sno
    Else           
     Update SchemeSale SET Pending = (@PENDING - @QTY)               
     WHERE  Product_Code = @ITEM_CODE AND               
     TYPE = @TYPE and               
     InvoiceID = @InvoiceID and               
     Claimed = 0 And IsNull(SaleType,0) = 0            
     And IsNull(Serial,0) = @serial            
     And Isnull(Sno,0)=@Sno 
     And Isnull(Value,0) = @Value
    end              
   else              
    --if claimed qty = current invoice pending qty               
   begin              
    If @STO = 1             
     Update SchemeSale SET Pending = 0, Claimed = 1               
     WHERE  Product_Code = @ITEM_CODE AND               
     TYPE = @TYPE and               
     InvoiceID = @InvoiceID and               
     IsNull(Claimed,0) = 0 and            
     IsNull(SaleType,0) = 1              
     And IsNull(Serial,0) = @serial            
     And Isnull(Sno,0)=@Sno
    Else            
     Update SchemeSale SET Pending = 0, Claimed = 1               
     WHERE  Product_Code = @ITEM_CODE AND               
     TYPE = @TYPE and               
     InvoiceID = @InvoiceID and               
     Claimed = 0 and            
     IsNull(SaleType,0) = 0            
     And IsNull(Serial,0) = @serial            
     And Isnull(Sno,0)=@Sno 
     And Isnull(Value,0) = @Value
    end              
            
    if @QTY < @PENDING             
     Set @ClaimedQty = @Qty            
    Else 
     Set @ClaimedQty = @Pending            
                
    set @Qty = @Qty - @Pending -- reduce claimed qty              
    
   EXEC dbo.sp_insert_SchemeClaims @ClaimID, @InvoiceID, @ITEM_CODE, @ClaimedQty, @TYPE ,@serial,@Sno            
            
   end              
  Update InvoiceAbstract Set ClaimedAlready = 1 Where InvoiceID = @InvoiceID            
  fetch next from curSchemePending into @PENDING, @InvoiceID, @ExistQty, @Serial, @Sno, @Value
 end              
close curSchemePending              
deallocate curSchemePending         
