CREATE PROCEDURE sp_Inv_Update_Others(@RowNo int, @InvoiceID int,                 
   @ITEM_CODE nvarchar(15),                
   @ORIGINAL_QTY Decimal(18,6),                
   @SALE_PRICE Decimal(18,6),                
   @SCHEME_COST Decimal(18,6),                
   @FREESERIAL nvarchar(255) = N'',                 
   @SPLCATSERIAL nvarchar(255) = N'',                 
   @SpecialCategoryScheme int = 0 ,                 
   @SCHEMEID int = 0,                 
   @SPLCATSCHEMEID int = 0,                 
   @SCHEMEDISCPERCENT Decimal(18,6) = 0,                 
   @SCHEMEDISCAMOUNT Decimal(18,6) = 0,                
   @SPLCATDISCPERCENT Decimal(18,6) = 0,                
   @SPLCATDISCAMOUNT Decimal(18,6) = 0,                
   @SAVESCHEMESALE int = 0,              
   @ExciseDuty Decimal(18,6)=0,              
   @SalePriceBED Decimal(18,6)=0,              
   @ExciseDutyID Integer=0,            
   @SaleStaffID int=0,           
   @TaxSuffApplicableOn int=1,          
   @TaxSuffPartOff Decimal(18,6) =100,          
   @Vat int = 0,          
   @CollectTaxSuffered int = 0,        
   @TaxSuffAmount Decimal(18,6)=0,    
   @TaxAmount  Decimal(18,6)=0,          
   @STCredit  Decimal(18,6)=0,      
   @TaxApplicableOn int=1,          
   @TaxPartOff Decimal(18,6) =100,          
   @FLAGWORD Int = 0,  
   @TaxCode int = 0  
) As                  
                   
-- This is to Identify the Rows of the invoice w.r.t the grid.                  
              
DECLARE @SECONDARY_SCHEME int                  
DECLARE @COST Decimal(18,6)                
DECLARE @InvType int            
SET @COST = 0                
              
--update salesstaffid              
update InvoiceDetail set SalesStaffID=@SaleStaffID              
where  Invoiceid = @InvoiceID and isnull(Serial,0) = @RowNo              
      
UPDATE Invoicedetail SET                 
 FREESERIAL = @FREESERIAL,                 
 SPLCATSERIAL = @SPLCATSERIAL,                 
 SpecialCategoryScheme = @SpecialCategoryScheme,                 
 SCHEMEID = @SCHEMEID,                 
 SPLCATSCHEMEID = @SPLCATSCHEMEID,                 
 SCHEMEDISCPERCENT = @SCHEMEDISCPERCENT,                 
 SPLCATDISCPERCENT = @SPLCATDISCPERCENT,          
 TaxSuffApplicableOn = @TaxSuffApplicableOn,          
 TaxSuffPartOff = @TaxSuffPartOff,          
 Vat = @Vat,          
 CollectTaxSuffered= @CollectTaxSuffered,        
 TaxAmount = @TaxAmount,         
 TaxSuffAmount = @TaxSuffAmount,      
 STCredit = @STCredit,        
 TaxApplicableOn = @TaxApplicableOn,    
 TaxPartOff  = @TaxPartOff   
WHERE                 
 Invoiceid = @InvoiceID and                 
 isnull(Serial,0) = @RowNo                

--Update the taxcode based on applicableon and Partoff
--In Save procedure minimum taxid is stored if there is multiple tax in same percentage
--So it is updated again
if @taxcode <> 0   
begin  
 UPDATE Invoicedetail SET taxid = @taxcode   
 WHERE  Invoiceid = @InvoiceID and isnull(Serial,0) = @RowNo                
end  
                
--Update Only the Batch which has Discount Value                 
--The below code is written seperately because amount should be reflected                
--only in one row and all other's of the same batch and same serial number should be zero                
                
Update InvoiceDetail Set           
 SCHEMEDISCAMOUNT = @SCHEMEDISCAMOUNT,                 
 SPLCATDISCAMOUNT = @SPLCATDISCAMOUNT                
Where                
 Invoiceid = @InvoiceID and                 
 isnull(Serial,0) = @RowNo and                
 Isnull(DiscountValue,0) <> 0                
              
-- Update all Schemes which are inserted already and are not Special Category Scheme's                
Update SchemeSale                
Set SpecialCategory = 0, Serial = @RowNo                
Where IsNull(Serial,0) = 0 and InvoiceId = @InvoiceID                
   
-- Update SchemeSale for Special Category Scheme                
IF @SAVESCHEMESALE = 1                 
BEGIN                  
                
 -- Primary Quantity is Zero by Default for Special Category                 
    -- Since it can have more than One Primary Item               
 SELECT @COST = Purchase_Price FROM Items WHERE Product_Code = @ITEM_CODE                    
 IF @SCHEME_COST = -1 SET @SCHEME_COST = @COST * @ORIGINAL_QTY                
             
 select @InvType=InvoiceType from InvoiceAbstract where InvoiceId= @InvoiceId            
 if @InvType=5 or @InvType=6             
 begin          
 set @SCHEME_COST = -1 * @SCHEME_COST            
 end         
Select @SECONDARY_SCHEME = IsNull(SecondaryScheme,0) from Schemes Where SchemeID = @SPLCATSCHEMEID                  
 Insert Into SchemeSale(Product_Code, Quantity, Free, Value, Cost, Type, InvoiceID, Claimed, Pending, Flags, SpecialCategory, Serial)                   
 Values(@ITEM_CODE, 0, @ORIGINAL_QTY, @SALE_PRICE * @ORIGINAL_QTY, @SCHEME_COST, @SPLCATSCHEMEID, @INVOICEID, 0, @ORIGINAL_QTY, @SECONDARY_SCHEME, 1, @RowNo)                  
END                  
--To Save the FlagWord in Invoicedetail for samefreeitem - amend invoice    
 Select @InvType=InvoiceType from InvoiceAbstract where InvoiceId= @InvoiceId            
 If @InvType = 3    
 Begin    
  UPDATE InvoiceDetail    
  SET FlagWord = @FLAGWORD    
  WHERE Invoiceid = @InvoiceID     
  And isnull(Serial,0) = @RowNo      
 End                      
Update InvoiceDetail               
Set ExciseDuty = @ExciseDuty,              
    SalePriceBeforeExciseAmount = @SalePriceBED,              
ExciseID = @ExciseDutyID               
Where                
 Invoiceid = @InvoiceID and                 
 isnull(Serial,0) = @RowNo                 
           
    
    
  


