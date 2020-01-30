Create PROCEDURE spr_List_QuotationDetail(@QuotationID INT)
AS
DECLARE @QuotationType INT
DECLARE @MfrCatType INT
Declare @YES As NVarchar(50)
Declare @NO As NVarchar(50)
Declare @CATEGORY As NVarchar(50)
Declare @MANUFACTURER As NVarchar(50)
Declare @ECP As NVarchar(50)
Declare @PURCHASE  As NVarchar(50)
Declare @MRP As NVarchar(50)
Declare @SALEPRICE As NVarchar(50)

Set @YES = dbo.LookupDictionaryItem(N'Yes', Default)
Set @NO = dbo.LookupDictionaryItem(N'No', Default)
Set @CATEGORY = dbo.LookupDictionaryItem(N'Category', Default)
Set @MANUFACTURER = dbo.LookupDictionaryItem(N'Manufacturer', Default)
Set @ECP = dbo.LookupDictionaryItem(N'ECP', Default)
Set @PURCHASE = dbo.LookupDictionaryItem(N'Purchase', Default)
Set @MRP = dbo.LookupDictionaryItem(N'MRP', Default)
Set @SALEPRICE = dbo.LookupDictionaryItem(N'SALEPRICE', Default)

SELECT @QuotationType = QuotationLevel FROM QuotationAbstract WHERE QuotationID = @QuotationID

IF @QuotationType = 1
	BEGIN
		SELECT 
			"Quotation ID" = QuotationID, "Item Code" = QuotationItems.Product_Code,
		 "Item Name" = Items.ProductName, "Purchase Price" = PurchasePrice,
			"Sale Price" = SalePrice, 
			"Variance On" = 
				CASE MarginOn
					WHEN 1 THEN	@ECP
					WHEN 2 THEN	@PURCHASE
					WHEN 3 THEN	@MRP				
					When	4 Then @SALEPRICE
				END,
		 "Variance Percentage" = MarginPercentage, 
			"Rate Quoted" = RateQuoted, "LST_Percentage" = Tax.Percentage,
		 "CST_Percentage" = Tax.CST_Percentage,"Discount" = Discount,
			"Allow Scheme" = 
				CASE AllowScheme
					WHEN 1 THEN		@YES
					ELSE	@NO
				END
		FROM 
			QuotationItems
			Inner Join Items On Items.Product_Code = QuotationItems.Product_Code
			Left Outer Join  Tax On QuotationItems.QuotedTax = Tax.Tax_Code 
		WHERE  QuotationID = @QuotationID 
	END
ELSE IF @QuotationType = 2
	BEGIN
		SELECT 
			"Quotation ID" = QuotationID,Category_Name,
		 "Variance On" = 
				Case MarginOn		
					WHEN 1 THEN	@ECP
					WHEN 2 THEN	@PURCHASE
					WHEN 3 THEN	@MRP				
					When	4 Then @SALEPRICE
				END,
		 "Variance Percentage" = MarginPercentage,"LST_Percentage" = Percentage,
		 "CST_Percentage" = CST_Percentage, "Discount" =  Discount,
			"Allow Scheme" = 
				CASE AllowScheme
					WHEN 1 THEN	@YES
					ELSE	@NO
				END,
		 "Quotation Type" = @CATEGORY
		FROM 
			QuotationMfrCategory
			Inner Join ItemCategories On ItemCategories.CategoryID = QuotationMfrCategory.MfrCategoryID
			Right Outer Join Tax On Tax.Tax_Code = QuotationMfrCategory.Tax
		WHERE 
			QuotationMfrCategory.QuotationID = @QuotationID 
			And QuotationType = 2 
	END
ELSE IF @QuotationType = 3
	BEGIN
		SELECT 
			"Quotation ID" = QuotationID, "Manufacturer Name" = Manufacturer_Name, 
			"Variance On" = 
				Case MarginOn
					WHEN 1 THEN	@ECP
					WHEN 2 THEN	@PURCHASE
					WHEN 3 THEN	@MRP				
					When	4 Then @SALEPRICE
				END,
		 "Variance Percentage" = MarginPercentage, "LST_Percentage" = Percentage,
		 "CST_Percentage" = CST_Percentage,"Discount" =  Discount,
		 "Allow Scheme" =
			 CASE AllowScheme
					WHEN 1 THEN	@YES
					ELSE @NO
				END,
		 "Quotation Type" = @MANUFACTURER
		FROM 
			QuotationMfrCategory
			Inner Join  Manufacturer On QuotationMFrCategory.MfrCategoryID = Manufacturer.ManufacturerID
			Right Outer Join Tax On  Tax.Tax_Code = QuotationMfrCategory.Tax
		WHERE QuotationMFrCategory.QuotationID = @QuotationID 
			And QuotationType = 1 
	END
ELSE
BEGIN
	SELECT 
		"Quotation ID" = QuotationID, "Variance From" = MarginFrom, "Variance To" = MarginTo, 
		"Discount" = Discount 
	FROM 
		QuotationUniversal
	WHERE 
		QuotationUniversal.QuotationID = @QuotationID
END
