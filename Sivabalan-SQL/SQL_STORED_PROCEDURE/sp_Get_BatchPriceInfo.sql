CREATE Procedure sp_Get_BatchPriceInfo (@ItemCode nvarchar(20),@CustomerID nVarchar(15))      
As      
Declare @TaxType Int

SELECT @TaxType = Locality FROM Customer WHERE CustomerID =  @CustomerID   

If exists(Select Batch_Code From Batch_Products Where Product_Code = @ItemCode And IsNull(Free, 0) = 0)      
Begin      
	Select Top 1 BP.Batch_Number,IsNull(BP.PTR,0),
    "TaxSuffered" = IsNull(BP.TaxSuffered,0),
    "TaxSuffApplicableOn" = IsNull(BP.ApplicableOn,0) ,
    "TaxSuffPartOff" = IsNull(BP.PartofPercentage,0),
    "SaleTax" = (Select IsNull(Case @TaxType  WHEN 1 THEN Percentage ELSE CST_Percentage END,0) From Tax Where Tax_Code = Items.Sale_Tax),
    "TaxApplicableOn" = (Select IsNull(Case @TaxType  WHEN 1 THEN LSTAPPLICABLEON ELSE CSTAPPLICABLEON END,0) From Tax Where Tax_Code = Items.Sale_Tax),
    "TaxPartOff" = (Select IsNull(Case @TaxType  WHEN 1 THEN LSTPARTOFF ELSE CSTPARTOFF END,0) From Tax Where Tax_Code = Items.Sale_Tax),
    "VAT" = IsNull(Items.VAT,0),
	"Locality" = @TaxType
	From Batch_Products BP, Items 
	Where Items.Product_Code =  BP.Product_Code   
	and BP.Batch_Code in (Select Batch_Code From Batch_Products       
	Where Product_Code = @ItemCode And IsNull(Free, 0) = 0)       
	Order By  bp.Batch_Code Desc      
End      
Else      
Begin      
	Select Null, IsNull(PTR,0),
    "TaxSuffered" = (Select IsNull(Case @TaxType  WHEN 1 THEN Percentage ELSE CST_Percentage END,0) From Tax Where Tax_Code = Items.TaxSuffered),
    "TaxSuffApplicableOn" = (Select IsNull(Case @TaxType  WHEN 1 THEN LSTAPPLICABLEON ELSE CSTAPPLICABLEON END,0) From Tax Where Tax_Code = Items.TaxSuffered),
    "TaxSuffPartOff" = (Select IsNull(Case @TaxType  WHEN 1 THEN LSTPARTOFF ELSE CSTPARTOFF END,0) From Tax Where Tax_Code = Items.TaxSuffered),
    "SaleTax" = (Select IsNull(Case @TaxType  WHEN 1 THEN Percentage ELSE CST_Percentage END,0) From Tax Where Tax_Code = Items.Sale_Tax),
    "TaxApplicableOn" = (Select IsNull(Case @TaxType  WHEN 1 THEN LSTAPPLICABLEON ELSE CSTAPPLICABLEON END,0) From Tax Where Tax_Code = Items.Sale_Tax),
    "TaxPartOff" = (Select IsNull(Case @TaxType  WHEN 1 THEN LSTPARTOFF ELSE CSTPARTOFF END,0) From Tax Where Tax_Code = Items.Sale_Tax),
	"VAT" = IsNull(Items.VAT,0),
	"Locality" = @TaxType
	From Items
	Where Items.Product_Code = @ItemCode
End      


