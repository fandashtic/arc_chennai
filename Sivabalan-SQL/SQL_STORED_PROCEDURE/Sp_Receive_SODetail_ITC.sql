Create Procedure Sp_Receive_SODetail_ITC(    
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
@Serial  int=0,
@Custom12 NVarchar(255)=N'',	--UOMDescription
@Custom13 Int = 0,				--UOMID
@Custom14 Decimal(18,6) = 0,	--UOMQty
@Custom15 Decimal(18,6)= 0	--UOMPrice
)    
as    

If @Custom5 <> 1 
Begin
Declare @UOM int
Declare @UOM1 nvarchar(255),@UOM2 nvarchar(255),@UOM3 nvarchar(255)
Declare @ConvFact Decimal(18,6)        

Set @UOM = 0        
if @Custom14 > 0 
	Set @ConvFact = @ItemQty / @Custom14
else
	Set @ConvFact = 1

/*
1.	When the received UOM Description of the item already exists then “check for UOM Conversion Unit” 
	otherwise “Display Base UOM”.

2.	Compare the received conversion unit with the master conversion unit, 
	if it matches display the received uom description and uom quantity otherwise “Display Base UOM”.
*/

If (Select UOM.description From Items,UOM Where Items.UOM=UOM.UOM And Items.Product_Code=@ItemID and @ConvFact = 1)= @Custom12
	Select @UOM=Items.UOM From Items,UOM Where Items.UOM=UOM.UOM And Items.Product_Code=@ItemID

If (Select UOM.description From Items,UOM Where Items.UOM1=UOM.UOM And Items.Product_Code=@ItemID and @ConvFact = Items.UOM1_Conversion )= @Custom12
	Select @UOM=Items.UOM From Items,UOM Where Items.UOM1=UOM.UOM And Items.Product_Code=@ItemID

If (Select UOM.description From Items,UOM Where Items.UOM2=UOM.UOM And Items.Product_Code=@ItemID and @ConvFact = Items.UOM2_Conversion)= @Custom12
	Select @UOM=Items.UOM From Items,UOM Where Items.UOM2=UOM.UOM And Items.Product_Code=@ItemID

if @UOM  = 0 
begin
	Select @UOM=Items.UOM,@Custom12=UOM.Description From Items,UOM 
	Where Items.UOM=UOM.UOM and Items.Product_Code=@ItemID
	Set @Custom14=@ItemQty
	Set @Custom15=@ItemRate
End

End

   
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
[TaxPartOff] ,
[UOMDescription],
[UOM],
[UOMQty],
[UOMPrice]
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
@TaxPartOff,
@Custom12,
@UOM,
@Custom14,
@Custom15
)      
    
end    
