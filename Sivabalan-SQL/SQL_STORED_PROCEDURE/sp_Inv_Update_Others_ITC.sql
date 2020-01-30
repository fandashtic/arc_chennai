Create PROCEDURE sp_Inv_Update_Others_ITC(@RowNo int, @InvoiceID int,                 
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
   @TaxCode int = 0,
   @SplCatCode nVarchar(50) ='',
   @MultipleSchemeID nVarchar(500) = '',	
   @OldFunctionality Int = 1, 
   @MultiSplSchIDAndCost as nVarchar(2500) = N'',
   @TaxBeforDiscount as Int = 0)  
As                  
                   
-- This is to Identify the Rows of the invoice w.r.t the grid.                  
              
DECLARE @SECONDARY_SCHEME int                  
DECLARE @COST Decimal(18,6)                
DECLARE @InvType int            
SET @COST = 0                
              


--To Recalculate TaxAmount
DECLARE @LOCALITY int  
--DECLARE @TaxPer as Decimal(18,6)
DECLARE @TaxInvPer as Decimal(18,6)
DECLARE @UOMQty as Decimal(18,6)
DECLARE @UOMPrice as Decimal(18,6)
DECLARE @DiscountVal as Decimal(18,6)
DECLARE @TaxID Int
DECLARE @TaxAmt as Decimal(18,6)


Select @LOCALITY = IsNull(Locality, 0) From InvoiceAbstract, Customer Where InvoiceAbstract.CustomerID = Customer.CustomerID And InvoiceID = @InvoiceID  




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
 SPLCATCODE = @SplCatCode ,
 TaxSuffApplicableOn = @TaxSuffApplicableOn,          
 TaxSuffPartOff = @TaxSuffPartOff,          
 Vat = @Vat,          
 CollectTaxSuffered= @CollectTaxSuffered,        
 TaxAmount = @TaxAmount,         
 TaxSuffAmount = @TaxSuffAmount,      
 STCredit = @STCredit,        
 TaxApplicableOn = @TaxApplicableOn,    
 TaxPartOff  = @TaxPartOff ,
 MultipleSplCatSchemeID =  @MultipleSchemeID ,
 MultipleSplCategorySchDetail = @MultiSplSchIDAndCost
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

--Get the Tax Percentage from Invoice
Select Top 1 @TaxInvPer = Case @LOCALITY When 1 Then isNull(TaxCode,0) Else isNull(TaxCode2,0) End ,
@UOMQty = isNull(UOMQty,0),@UOMPrice = isNull(UOMPrice,0),@DiscountVal = isNull(DiscountValue,0),
@TaxID = isNull(TaxID,0),@TaxAmt = isNull(TaxAmount,0)
From InvoiceDetail Where InvoiceID = @InvoiceID  And isnull(Serial,0) = @RowNo 
And isNull(UOMQty,0) > 0 And isNull(UOMPrice,0) > 0

--Get the TaxPercentage for the passed TaxID 
--Select @TaxPer = Case @LOCALITY 
--When 1 Then (Percentage * LSTPartOff) / 100 
--Else (CST_Percentage * CSTPartOff) / 100 End
--From Tax Where Tax_Code = @TaxID



--In some Rare Scenarios TaxCode and TaxPercentage has Value but the Taxamount does not 
--have any values.Hence change made to calculate the taxamount only for such rows.
If isNull(@TaxID,0) > 0 And isNull(@TaxInvPer,0) > 0 And isNull(@TaxAmt,0) = 0  And isNull(@FLAGWORD,0) = 0
Begin
	If @TaxBeforDiscount = 0 
		Select @TaxAmount = ((@UOMQty * @UOMPrice) - @DiscountVal) * (@TaxInvPer /100)
	Else
		Select @TaxAmount = ((@UOMQty * @UOMPrice) ) * (@TaxInvPer/100)
	
	If @Locality = 1  
		UPDATE Invoicedetail SET TaxAmount = @TaxAmount,STPayable =  @TaxAmount 
		WHERE  Invoiceid = @InvoiceID and isnull(Serial,0) = @RowNo  and isNull(taxid,0) > 0 and 
		((Case @LOCALITY When 1 Then isNull(TaxCode,0) Else isNull(TaxCode2,0) End) > 0) 
	Else
		UPDATE Invoicedetail SET TaxAmount = @TaxAmount,CSTPayable =  @TaxAmount 
		WHERE  Invoiceid = @InvoiceID and isnull(Serial,0) = @RowNo  and isNull(taxid,0) > 0 and 
		((Case @LOCALITY When 1 Then isNull(TaxCode,0) Else isNull(TaxCode2,0) End) > 0) 
End

                
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
If @OldFunctionality = 0 
	Update tbl_mERP_SchemeSale                
	Set SpecialCategory = 0, Serial = @RowNo                
	Where IsNull(Serial,0) = 0 and InvoiceId = @InvoiceID                		
else          
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
		If @OldFunctionality = 0 
		Begin
			--Add Data to new scheme Table 
--			Insert Into tbl_mERP_SchemeSale(Product_Code, Quantity, Free, Value, Cost, Type, InvoiceID, Claimed, Pending, Flags, SpecialCategory, Serial)                   
--			Values(@ITEM_CODE, 0, @ORIGINAL_QTY, @SALE_PRICE * @ORIGINAL_QTY, @SCHEME_COST, @SPLCATSCHEMEID, @INVOICEID, 0, @ORIGINAL_QTY, @SECONDARY_SCHEME, 1, @RowNo)                  	
			Exec mERP_sp_Insert_SchemeSale @ITEM_CODE,0,@ORIGINAL_QTY,@SALE_PRICE,@INVOICEID,@MultiSplSchIDAndCost,1,@RowNo
		End
		Else
		Begin
			Select @SECONDARY_SCHEME = IsNull(SecondaryScheme,0) from Schemes Where SchemeID = @SPLCATSCHEMEID                  
			Insert Into SchemeSale(Product_Code, Quantity, Free, Value, Cost, Type, InvoiceID, Claimed, Pending, Flags, SpecialCategory, Serial)                   
			Values(@ITEM_CODE, 0, @ORIGINAL_QTY, @SALE_PRICE * @ORIGINAL_QTY, @SCHEME_COST, @SPLCATSCHEMEID, @INVOICEID, 0, @ORIGINAL_QTY, @SECONDARY_SCHEME, 1, @RowNo)                  
		End
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

--	Update Invoiceabstract Set TaxDiscountFlag = @TaxBeforDiscount where InvoiceID = @InvoiceID
      
