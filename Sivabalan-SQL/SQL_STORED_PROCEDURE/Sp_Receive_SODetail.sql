CREATE Procedure Sp_Receive_SODetail(  
@Soid Int, --This Variable Need Not To DeClare in XMLColumnamp Table
@ItemId nvarchar(20), 
@ItemQty Decimal(18,6),
@ItemRate Decimal(18,6),
@DutyTaxRate Decimal(18,6),
@Custom1 Decimal(18,6),-- Discount 
@Custom5 int, --Brancg Tag
@TaxSuffered Decimal(18,6)=0.0,
@TaxSuffApplicableOn Int=0, 
@TaxSuffPartOff Decimal(18,6)=0.0,
@TaxApplicableOn Int=0,
@TaxPartOff Decimal(18,6)=0.0, 
@Serial  int=0

)  
as  
 
if @Custom5 =1  
 BEGIN        

  
 INSERT INTO [PODetailReceived]         
  ([PONumber],        
  [Product_Code],        
  [Quantity],        
  [PurchasePrice],    
  [Serial])       
 VALUES         
 (  
  @soid,  
  @Itemid,  
  @ItemQty,        
  @ItemRate,    
  @Serial)    
 END       
  
else  
  
begin  

 INSERT INTO [SODetailReceived](     
[Product_Code],    
[Quantity],    
[SalePrice],    
[SaleTax],    
[Discount],    
[SONumber],    
[TaxSuffered],    
[TaxSuffApplicableOn],    
[TaxSuffPartOff],    
[TaxApplicableOn],    
[TaxPartOff]    
    
)     
     
VALUES (    
@ItemID,   
@ItemQTY,    
@Itemrate,  
@DutyTaxRate,    
@Custom1,  
@SOID,    
@TaxSuffered,    
@TaxSuffApplicableOn,    
@TaxSuffPartOff,    
@TaxApplicableOn,    
@TaxPartOff    
)    
  
end  
  
  
  



