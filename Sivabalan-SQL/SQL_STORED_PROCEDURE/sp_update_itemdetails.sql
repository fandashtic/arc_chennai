CREATE procedure sp_update_itemdetails
(
	@product_code as nvarchar(150), 
	@productname as nvarchar(150),             
	@pur_cst as decimal(18,6), 
	@pur_lst as decimal(18,6), 
	@sal_cst as decimal(18,6), 
	@sal_lst as decimal(18,6), 
	@pts as decimal(18,6), 
	@ptr as decimal(18,6), 
	@ecp as decimal(18,6),
	@SplPrice as decimal(18,6),
	@Flag as int = 0            
)            
as            
Declare @SaleTaxCode as int            
Declare @PurTaxCode as int            
Declare @PurTaxDesc as nvarchar(20)            
Declare @SaleTaxDesc as nvarchar(20)            
Declare @SaleType as int    
    

            
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
 Select @SaleType = isnull(Purchased_At,0) from Items Where Product_Code = @product_code    
 If @SaleType = 1     
	Update Items 
	Set TaxSuffered = @PurTaxCode , Sale_Tax = @SaleTaxCode            
	, PTS = @pts , PTR = @ptr , ECP = @ecp , Purchase_Price = @pts , Company_Price = @SplPrice
	Where Product_Code = @product_code          
Else
	Update Items 
	Set TaxSuffered = @PurTaxCode , Sale_Tax = @SaleTaxCode            
	, PTS = @pts , PTR = @ptr , ECP = @ecp , Purchase_Price = @ptr , Company_Price = @SplPrice
	Where Product_Code = @product_code          

-- Update Batch Products          
If @Flag = 1    
Begin        
  Update Batch_Products     
  Set  PTS = @pts , PTR = @ptr , ECP = @ecp , Company_Price = @SplPrice
  Where Product_Code = @product_code and not (PTS = 0 and PTR = 0 and ECP = 0 and Company_Price = 0)
End        
      


