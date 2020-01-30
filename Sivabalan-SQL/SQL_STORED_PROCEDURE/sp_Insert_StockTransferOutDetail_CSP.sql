Create Procedure sp_Insert_StockTransferOutDetail_CSP ( @DocumentID int,            
 @ItemCode nvarchar(15),            
 @BatchNumber nvarchar(255),            
 @Rate Decimal(18,6),            
 @ReqQuantity Decimal(18,6),            
 @TrackBatches int,            
 @TrackInventory int,            
 @Amount Decimal(18,6),            
 @FreeRow int,            
 @TaxSuffered Decimal(18,6),            
 @TaxAmount Decimal(18,6),            
 @Total Decimal(18,6),              
 @OpeningDate datetime = Null,              
 @BackDatedTransaction int = 0,          
 @SchemeID Int = 0,          
 @Serial Int = 0,          
 @FreeSerial nvarchar(100) = Null,          
 @SchemeFree Int = 0,@TaxSuffApplicableOn Int = 0, @TaxSuffPartOff Decimal(18,6) =0, @VAT int =0 )            
As            
Declare @BatchCode int            
Declare @Quantity Decimal(18,6)            
Declare @RetVal Decimal(18,6)            
Declare @TotalQuantity Decimal(18,6)            
Declare @PTS Decimal(18,6)            
Declare @PTR Decimal(18,6)            
Declare @ECP Decimal(18,6)            
Declare @SpecialPrice Decimal(18,6)            
Declare @DIFF Decimal(18,6)            
            
Select @PTS = PTS, @PTR = PTR, @ECP = ECP, @SpecialPrice = Company_Price  
From Items, ItemCategories            
Where Product_Code = @ItemCode And Items.CategoryID = ItemCategories.CategoryID            
  
If @TrackInventory = 0            
Begin            
 Set @RetVal = 1            
 Insert into StockTransferOutDetail(DocSerial, Product_Code, Batch_Code,            
 Batch_Number, PTS, PTR, ECP, SpecialPrice, Rate, Quantity, Amount, Free,            
 TaxSuffered, TaxAmount, TotalAmount, SchemeId , Serial , FreeSerial,SchemeFree,        
 TaxSuffApplicableOn,TaxSuffPartOff,VAT)            
 Values (@DocumentID, @ItemCode, 0, @BatchNumber, @PTS, @PTR, @ECP, @SpecialPrice,            
 @Rate, @ReqQuantity, @Amount, @FreeRow, @TaxSuffered, @TaxAmount, @Total , @SchemeID , @Serial , @FreeSerial,@SchemeFree,        
 @TaxSuffApplicableOn,@TaxSuffPartOff,@VAT)            
 Goto All_Said_And_Done            
End            
  
If @TrackBatches = 1            
Begin            
 Select @TotalQuantity = IsNull(Sum(Quantity), 0) From Batch_Products            
 Where Product_Code = @ItemCode And IsNull(Batch_Number, N'') = @BatchNumber            
 And IsNull(PurchasePrice, 0) = @Rate And (Expiry >= GetDate() Or Expiry is Null)            
 And IsNull(Damage, 0) = 0  And IsNull(Free, 0) = @FreeRow            
 And IsNull(TaxSuffered, 0) = @TaxSuffered    
 And IsNull(ApplicableOn,0) = @TaxSuffApplicableOn    
 And IsNull(PartOfPercentage,0) = @TaxSuffPartOff    
 Declare ReleaseStocks Cursor Keyset For            
 Select Batch_Number, Batch_Code, Quantity,            
 PTS, PTR, ECP, Company_Price  
 From Batch_Products            
 Where Product_Code = @ItemCode And IsNull(Batch_Number, N'') = @BatchNumber            
 And IsNull(PurchasePrice, 0) = @Rate And IsNull(Quantity, 0) > 0            
 And IsNull(Damage, 0) = 0 And IsNull(Free, 0) = @FreeRow             
 And IsNull(TaxSuffered, 0) = @TaxSuffered            
 And IsNull(ApplicableOn,0) = @TaxSuffApplicableOn    
 And IsNull(PartOfPercentage,0) = @TaxSuffPartOff    
End            
Else            
Begin            
 Select @TotalQuantity = IsNull(Sum(Quantity), 0) From Batch_Products            
 Where Product_Code = @ItemCode And IsNull(PurchasePrice, 0) = @Rate             
 And IsNull(Damage, 0) = 0 And IsNull(Free, 0) = @FreeRow            
 And IsNull(TaxSuffered, 0) = @TaxSuffered            
 And IsNull(ApplicableOn,0) = @TaxSuffApplicableOn    
 And IsNull(PartOfPercentage,0) = @TaxSuffPartOff    
            
 Declare ReleaseStocks Cursor Keyset For            
 Select Batch_Number, Batch_Code, Quantity,             
 PTS, PTR, ECP, Company_Price  
 From Batch_Products            
 Where Product_Code = @ItemCode And IsNull(PurchasePrice, 0) = @Rate            
 And IsNull(Quantity, 0) > 0 And IsNull(Damage, 0) = 0 And IsNull(Free, 0) = @FreeRow            
 And IsNull(TaxSuffered, 0) = @TaxSuffered    
 And IsNull(ApplicableOn,0) = @TaxSuffApplicableOn    
 And IsNull(PartOfPercentage,0) = @TaxSuffPartOff    
            
End            
Open ReleaseStocks            
If @TotalQuantity < @ReqQuantity            
Begin            
 Set @RetVal = 0            
 Goto OvernOut            
End            
Else            
Begin            
 Set @RetVal = 1            
End            
Fetch From ReleaseStocks into @BatchNumber, @BatchCode, @Quantity, @PTS, @PTR, @ECP,             
@SpecialPrice            
While @@Fetch_Status = 0            
Begin            
 If @Quantity >= @ReqQuantity            
 Begin            
  Update Batch_Products Set Quantity = Quantity - @ReqQuantity            
  Where Batch_Code = @BatchCode            
IF @@RowCount = 0            
  Begin            
   Set @RetVal = 1            
   Goto OvernOut            
  End            
  Insert into StockTransferOutDetail(DocSerial, Product_Code, Batch_Code,            
  Batch_Number, PTS, PTR, ECP, SpecialPrice, Rate, Quantity, Amount, Free,            
  TaxSuffered, TaxAmount, TotalAmount , SchemeId , Serial , FreeSerial,SchemeFree,        
  TaxSuffApplicableOn,TaxSuffPartOff,VAT)                
  Values (@DocumentID, @ItemCode, @BatchCode, @BatchNumber, @PTS, @PTR, @ECP,            
  @SpecialPrice, @Rate, @ReqQuantity, @Amount, @FreeRow, @TaxSuffered,             
  @TaxAmount, @Total , @SchemeID , @Serial , @FreeSerial,@SchemeFree,        
  @TaxSuffApplicableOn,@TaxSuffPartOff,@VAT)                
  If @BackDatedTransaction = 1            
  Begin             
     Set @DIFF = 0 - @ReqQuantity            
     exec sp_update_opening_stock @ItemCode, @OpeningDate, @DIFF, @FreeRow, @Rate            
  End            
            
  GoTo OvernOut            
 End            
 Else            
 Begin            
  Set @ReqQuantity = @ReqQuantity - @Quantity            
  Update Batch_Products Set Quantity = 0 Where Batch_Code = @BatchCode            
  If @@RowCount = 0            
  Begin            
   Set @RetVal = 1            
   Goto OvernOut            
  End            
  Insert into StockTransferOutDetail(DocSerial, Product_Code, Batch_Code,            
  Batch_Number, PTS, PTR, ECP, SpecialPrice, Rate, Quantity, Amount, Free,            
  TaxSuffered, TaxAmount, TotalAmount, SchemeId , Serial , FreeSerial,SchemeFree,        
  TaxSuffApplicableOn,TaxSuffPartOff,VAT)                
  Values (@DocumentID, @ItemCode, @BatchCode, @BatchNumber, @PTS, @PTR, @ECP,            
  @SpecialPrice, @Rate, @Quantity, @Amount, @FreeRow, @TaxSuffered, @TaxAmount,             
  @Total, @SchemeID , @Serial , @FreeSerial,@SchemeFree,        
  @TaxSuffApplicableOn,@TaxSuffPartOff,@VAT)                  
  Set @Amount = 0            
  Set @TaxSuffered = 0            
  Set @TaxAmount = 0            
  Set @Total = 0            
            
  If @BackDatedTransaction = 1            
  Begin             
     Set @DIFF = 0 - @Quantity            
     exec sp_update_opening_stock @ItemCode, @OpeningDate, @DIFF, @FreeRow, @Rate            
  End            
 End            
 Fetch Next From ReleaseStocks into @BatchNumber, @BatchCode, @Quantity, @PTS, @PTR,             
 @ECP, @SpecialPrice            
End            
OvernOut:            
Close ReleaseStocks            
Deallocate ReleaseStocks            
            
All_Said_And_Done:            
Select @RetVal            
                 
    
  


