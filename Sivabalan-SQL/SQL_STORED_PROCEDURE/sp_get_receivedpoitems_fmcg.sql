CREATE procedure [dbo].[sp_get_receivedpoitems_fmcg](@PRODUCT_CODE nvarchar(15),    
@Customer nvarchar(20) = N'')    
AS    
If @Customer = N''     
Begin    
	SELECT  Items.ProductName, Items.Sale_Price,     
	Items.Track_Batches, Tax.Percentage, ItemCategories.Price_Option,    
	ItemCategories.Track_Inventory,   
	--If CustomerId is empty then locality will be considered as Local
	cast(ISNULL(Tax.Percentage, 0) as nvarchar) ,
	cast(ISNULL(a.Percentage, 0) as nvarchar), 
	Tax.Tax_code as SalesTaxCode, A.Tax_code as TaxSufferedCode  ,  
	Cast (ISNULL(Tax.LSTApplicableOn, 0) as nvarchar) 'TaxApplicableOn',      
	Cast (ISNULL(Tax.LSTPartOff, 0) as nvarchar) 'TaxPartOff',        
	Cast (ISNULL(a.LSTApplicableOn, 0) as nvarchar) 'TaxSuffApplicableOn',      
	Cast (ISNULL(a.LSTPartOff, 0) as nvarchar) 'TaxSuffPartOff'  
	FROM Items, ItemCategories, Tax, Tax a    
	WHERE   Items.Product_Code = @PRODUCT_CODE AND     
	Items.CategoryID *= ItemCategories.CategoryID AND    
	Items.Sale_Tax *= Tax.Tax_Code AND Items.TaxSuffered *= a.Tax_Code    
End    
Else    
Begin    
	Declare @Locality int    
	Select @Locality = IsNull(Locality, 1) From Customer Where CustomerID = @Customer    
	SELECT  Items.ProductName, Items.Sale_Price,     
	Items.Track_Batches, Tax.Percentage, ItemCategories.Price_Option,    
	ItemCategories.Track_Inventory,     
	Case @Locality When 1 then ISNULL(Tax.Percentage, 0)  
	Else    
	ISNULL(Tax.CST_Percentage, 0)    
	End,    
	Case @Locality    
	When 1 then    
	ISNULL(a.Percentage, 0)    
	Else    
	ISNULL(a.CST_Percentage, 0)    
	End,Tax.Tax_code as SalesTaxCode, A.Tax_code as TaxSufferedCode ,   
	Case @Locality When 1 then  ISNULL(Tax.LSTApplicableOn, 0) Else ISNULL(Tax.CSTApplicableOn, 0) End 'TaxApplicableOn',      
	Case @Locality When 1 then  ISNULL(Tax.LSTPartOff, 0) Else ISNULL(Tax.CSTPartOff, 0) End 'TaxPartOff',        
	Case @Locality When 1 then  ISNULL(a.LSTApplicableOn, 0) Else ISNULL(a.CSTApplicableOn, 0) End 'TaxSuffApplicableOn',      
	Case @Locality When 1 then  ISNULL(a.LSTPartOff, 0) Else ISNULL(a.CSTPartOff, 0) End 'TaxSuffPartOff'  
	
	FROM Items, ItemCategories, Tax, Tax a    
	WHERE   Items.Product_Code = @PRODUCT_CODE AND     
	Items.CategoryID *= ItemCategories.CategoryID AND    
	Items.Sale_Tax *= Tax.Tax_Code AND Items.TaxSuffered *= a.Tax_Code    
End
