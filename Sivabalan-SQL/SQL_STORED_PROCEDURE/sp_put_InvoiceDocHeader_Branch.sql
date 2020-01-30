CREATE PROCEDURE [sp_put_InvoiceDocHeader_Branch]          
 (        
  @InvoiceDate  [datetime],          
  @CustomerID  [nvarchar](15),          
  @GrossValue  Decimal(18,6),          
  @DiscountPercentage  Decimal(18,6),          
  @AdditionalDiscount  Decimal(18,6),          
  @DiscountValue  Decimal(18,6),          
  @NetValue  Decimal(18,6),          
--  @CreditTerm [int],          
  @TaxLocation  [nvarchar](50),          
  @Freight Decimal(18,6),          
  @BillingAddress nvarchar(255),          
  @ShippingAddress nvarchar(255),          
  @Flags int,           
  @AdjustedAmount Decimal(18, 6),          
  @PaymentDate datetime,        
  @Status int,        
  @InvoiceReference nvarchar(50),        
  @ReferenceNumber nvarchar(255),        
  @CreditDesc nvarchar(255),      
  @creditType int,      
  @creditValue Decimal(18,6),      
  @Memo1 nvarchar(255),        
  @Memo2 nvarchar(255),        
  @Memo3 nvarchar(255),        
  @MemoLabel1 nvarchar(255),        
  @MemoLabel2 nvarchar(255),        
  @MemoLabel3 nvarchar(255),        
  @Balance Decimal(18, 6),          
  @DocReference nvarchar(255),        
  @GoodsValue Decimal(18, 6),          
  @AdditionalDiscountValue Decimal(18, 6),          
  @TotalTaxSuffered Decimal(18, 6),          
  @TotalTaxApplicable Decimal(18, 6),          
  @ProductDiscount Decimal(18, 6),          
  @RoundOffAmount Decimal(18, 6),        
  @BranchCode nvarchar(255)  ,        
  @OrgInvID nvarchar(255),  
  @AdjustmentDocReference nvarchar(255)  
 )          
          
AS           
DECLARE @Corrected_Code nvarchar(20)          
DECLARE @OriginalID nvarchar(20)          
DECLARE @DocumentID  nvarchar(50)        
DECLARE @CreditTerm  int        
DECLARE @TempCreditTerm  int        
DECLARE @tempCreditDesc nvarchar(50)      
DECLARE @UserName nvarchar(255)      
      
-- Get Document Number      
BEGIN TRAN          
UPDATE DocumentNumbers SET DocumentID = DocumentID + 1 WHERE DocType = 4          
SELECT @DocumentID = DocumentID - 1 FROM DocumentNumbers WHERE DocType = 4          
COMMIT TRAN          
      
-- Get Customer ID using Forum Code      
select @OriginalID = CustomerID FROM Customer WHERE AlternateCode = @CustomerID          
SET @Corrected_Code = ISNULL(@OriginalID, @CustomerID)          
     
    
--Get Credit Term ID      
IF((@CreditType<>0) And (@CreditValue<>0))       
Begin      
 IF Not exists(Select CreditID From CreditTerm Where Type=@CreditType And Value=@CreditValue)      
 Begin      
  If Not Exists(Select Description From CreditTerm Where Description=@CreditDesc)       
      Begin      
    Exec Sp_Insert_CreditTerm @CreditDesc,@CreditType,@CreditValue, 1      
	-- Tha Last Variable @DontReturnRS (1) is Used to Return 
	-- the Result Set (Open Statements Like "Select") of the Sp_Insert_CreditTerm 
	-- If and Only if @DontReturnRS is Set to 0
    Select @CreditTerm=CreditID From CreditTerm Where Type=@CreditType And Value=@CreditValue And Description=@CreditDesc      
   End      
  Else      
   Begin      
    
    Select @TempCreditTerm=ISnull(Max(Cast(Substring(Description,Len(@CreditDesc)+1,Len(Description)) as int))+1,1) From CreditTerm       
    Where Description like @CreditDesc + '%' + '[0-9]'      
    And ISnumeric(Substring(Description,Len(@CreditDesc)+1,Len(Description)))<>0         
    And CharIndex('.',Substring(Description,Len(@CreditDesc)+1,Len(Description))) = 0    
    And Substring(Description,Len(@CreditDesc)+1,1) not in ('-','.')    
    Set @tempCreditDesc=@CreditDesc + @TempCreditTerm       
    Exec Sp_Insert_CreditTerm @tempCreditDesc,@CreditType,@CreditValue      
    Select @CreditTerm=CreditID From CreditTerm Where Type=@CreditType And Value=@CreditValue And Description=@tempCreditDesc         
   End      
 End        
 Else      
 Begin      
  Select @CreditTerm=CreditID From CreditTerm Where Type=@CreditType And Value=@CreditValue      
 End      
End     
Else      
Begin      
 Set @CreditTerm=0       
End      
     
-- Get User Name      
select @UserName = registeredowner+'ad' from setup      
  
-- Insert into Invoice Abstract      
INSERT INTO [InvoiceAbstract]           
  (          
  [InvoiceDate],          
  [CustomerID],          
  [GrossValue],          
  [DiscountPercentage],          
 [AdditionalDiscount],      
  [DiscountValue],          
  [NetValue],          
  [CreditTerm],          
  [CreationTime],          
  [TaxLocation],          
 [Freight],          
 [DocumentID],          
 [BillingAddress],          
 [ShippingAddress],          
 InvoiceType,          
AdjustedAmount,          
 PaymentDate,            
 Status,        
 InvoiceReference,        
 ReferenceNumber,        
 Memo1 ,        
 Memo2 ,        
 Memo3 ,        
 MemoLabel1 ,        
 MemoLabel2 ,        
 MemoLabel3 ,        
 Balance ,          
 DocReference ,        
 GoodsValue ,          
 AddlDiscountValue ,          
 TotalTaxSuffered ,          
 TotalTaxApplicable ,          
 ProductDiscount ,          
 RoundOffAmount   ,        
 BranchCode,        
 OriginalInvoice  ,      
 UserName,  
 PaymentDetails,  
 PaymentMode      
 )           
           
VALUES           
 (          
 @InvoiceDate,          
 @Corrected_Code,           
 @GrossValue,          
 @DiscountPercentage,          
 @AdditionalDiscount,          
 @DiscountValue,          
 @netvalue,          
 @CreditTerm,          
 getdate(),          
 @TaxLocation,          
 @freight,          
 @DocumentID,          
 @BillingAddress,          
 @ShippingAddress,          
 @Flags,          
 @AdjustedAmount,          
 @PaymentDate,           
 512,        
 @InvoiceReference ,        
 @ReferenceNumber ,        
 @Memo1 ,        
 @Memo2 ,        
 @Memo3 ,        
 @MemoLabel1 ,        
 @MemoLabel2 ,        
 @MemoLabel3 ,        
 @Balance ,          
 @DocumentID ,        
 @GoodsValue ,          
 @AdditionalDiscountValue ,          
 @TotalTaxSuffered ,          
 @TotalTaxApplicable ,          
 @ProductDiscount ,          
 @RoundOffAmount ,        
 @BranchCode,        
 @OrgInvID,        
 @UserName,  
 @AdjustmentDocReference,  
 0      
 )          
  
--to get the identity value  
DECLARE @TempID as int  
SET @TempID = 0  
IF @@ROWCOUNT > 0   
BEGIN  
select @TempID = max(Invoiceid) from invoiceabstract       
END  
       
SELECT @TempID, @DocumentID        
        
        
        
        
      
    
    
    
  
  
  
  


