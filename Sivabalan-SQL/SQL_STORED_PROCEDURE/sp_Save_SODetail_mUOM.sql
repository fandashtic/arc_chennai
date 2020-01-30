CREATE Procedure sp_Save_SODetail_mUOM(@SONumber int,    
     @ItemCode nvarchar(15),    
     @BatchNumber nvarchar(255),     
     @SalePrice Decimal(18,6),     
     @RequiredQuantity Decimal(18,6),    
     @SaleTax Decimal(18,6),    
     @Discount Decimal(18,6),    
     @TAXCODE2 float,    
     @TAXSUFFERED Decimal(18,6) = 0,  
  @UOM int,  
     @UOMQty Decimal(18,6),  
     @UOMPrice Decimal(18,6),  
     @SerialNo Int=0,  
 @VAT int = 0 ,  
 @TaxApplicableOn int = 0,  
 @TaxPartOff decimal(18,6) =0,  
 @TaxSuffApplicableOn int =0,  
 @TaxSuffPartOff decimal(18,6)=0,
 @MRPPerPACK decimal(18,6)=0,
 @TaxOnQty as int = 0,
 @TaxID int,
 @GSTFlag int,
 @GSTCSTaxCode int
)  
AS    

Declare @HSNNumber nvarchar(15)
Declare @CategorizationID int

Select @HSNNumber = isnull(HSNNumber,0), @CategorizationID = isnull(CategorizationID,0) From Items Where Product_Code = @ItemCode

IF Exists(Select 'x' From SOAbstract Where SONumber = @SONumber and isnull(ForumSC, 0) = 0)
Begin
	Select Top 1 @BatchNumber = isnull(Batch_Number, '') From Batch_Products
	Where Quantity > 0 and IsNull(Damage, 0) = 0
		And IsNull(Expiry, getdate()) >= getdate()
		And Product_Code = @ItemCode
	Order By IsNull(Free, 0), Batch_Code
End

INSERT INTO SODetail(SONumber,    
       Product_Code,    
       Batch_Number,    
       Quantity,    
       Pending,    
       SalePrice,    
       SaleTax,    
       Discount,    
       TaxCode2,    
       TaxSuffered,  
       UOM,   
       UOMQty,   
       UOMPrice,  
      Serial,  
  VAT,  
 TaxApplicableOn,  
 TaxPartOff,  
 TaxSuffApplicableOn,  
 TaxSuffPartOff,MRPPerPACK,TAXONQTY,TaxID,GSTFlag,GSTCSTaxCode,HSNNumber,CategorizationID)  
    
VALUES (@SONumber,     
  @ItemCode,    
  @BatchNumber,     
  @RequiredQuantity,     
  @RequiredQuantity,     
  @SalePrice,     
  @SaleTax,     
  @Discount,    
  @TAXCODE2,    
  @TAXSUFFERED,  
  @UOM ,  
  @UOMQty ,  
  @UOMPrice,  
  @SerialNo,  
  @VAT,  
  @TaxApplicableOn,  
  @TaxPartOff,  
  @TaxSuffApplicableOn,  
  @TaxSuffPartOff,@MRPPerPACK,@TaxOnQty,@TaxID,@GSTFlag,@GSTCSTaxCode,@HSNNumber,@CategorizationID)  
Select 1  
