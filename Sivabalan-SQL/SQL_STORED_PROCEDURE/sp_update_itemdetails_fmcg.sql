CREATE procedure sp_update_itemdetails_fmcg (@product_code as nvarchar(150), @productname as nvarchar(150),             
@pur_cst as decimal(18,6), @pur_lst as decimal(18,6), @sal_cst as decimal(18,6), @sal_lst as decimal(18,6), @purchaseprice as decimal(18,6), @saleprice as decimal(18,6) ,@Flag as int = 0            
)            
as            
Declare @SaleTaxCode as int            
Declare @PurTaxCode as int            
Declare @PurTaxDesc as nvarchar(20)            
Declare @SaleTaxDesc as nvarchar(20)            
            
--Purchase Tax             
If exists(Select tax_code From tax Where percentage = @pur_lst and cst_percentage = @pur_cst)            
 Begin            
  Select @PurTaxCode = tax_code From tax Where percentage = @pur_lst and cst_percentage = @pur_cst            
 End            
Else            
 Begin            
  set @PurTaxDesc = convert(nvarchar, @pur_lst) + '% + ' + convert(nvarchar, @pur_cst) + '%'            
  Insert Into Tax(Tax_Description,percentage,cst_percentage) Values(@PurTaxDesc , @pur_lst , @pur_cst)            
  Select @PurTaxCode = tax_code From tax Where percentage = @pur_lst and cst_percentage = @pur_cst               
 End            
            
--Sale Tax            
If exists(Select tax_code From tax Where percentage = @sal_lst and cst_percentage = @sal_cst)            
 Begin            
  Select @SaleTaxCode = tax_code From tax Where percentage = @sal_lst and cst_percentage = @sal_cst            
 End            
Else            
 Begin            
  set @SaleTaxDesc = convert(nvarchar, @sal_lst) + '% + ' + convert(nvarchar, @sal_cst) + '%'              
  Insert Into Tax(Tax_Description,percentage,cst_percentage) Values(@SaleTaxDesc , @sal_lst , @sal_cst)            
  Select @SaleTaxCode = tax_code From tax Where percentage = @sal_lst and cst_percentage = @sal_cst            
 End            
-- Update Items            
Update Items Set TaxSuffered = @PurTaxCode , Sale_Tax = @SaleTaxCode            
, Purchase_price = @purchaseprice , Sale_Price = @Saleprice     
Where Product_Code = @product_code          
          
-- Update Batch Products          
If @Flag = 1    
Begin    
 Update Batch_Products     
 Set Saleprice = @saleprice    
 Where Product_Code = @product_code and Saleprice <> 0
End        
      
    
    
  


