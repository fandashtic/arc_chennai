
Create Procedure [dbo].[sp_Insert_RecdTaxMapping] (
					 @CS_PurchaseTaxCode int,
					 @CS_SalesTaxCode int,
					 @ProdcutCode nVarChar(18) ,
					 @Active int,
					 @xmlDocNumber int 
				     )
As
Begin
	Insert Into Recd_ItemTaxMapping (CS_PurcahseTaxCode,CS_SalesTaxCode, ProductCode, Active,xmlDocNumber,AlertCount) 
	Values (@CS_PurchaseTaxCode, @CS_SalesTaxCode, @ProdcutCode, @Active,@xmlDocNumber,0)
	
	select @@Identity
End
