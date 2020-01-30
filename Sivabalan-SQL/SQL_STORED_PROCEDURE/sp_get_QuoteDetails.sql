Create Procedure sp_get_QuoteDetails
@ItemCode   nVarchar(30),
@PurchasePrice decimal(18,6),
@ECPMRP   decimal(18,6),
@SalePrice  decimal(18,6),
@QuotationId int    ,
@CustomerID nVarchar(500),
@RegisterStatus int  = 0
As

Declare @QuotationType  int
Declare @tempCategory Table(Categoryid int)
declare @catid as int
Declare @ParentCatId int
Declare @TopLevelCatID int
Declare @mfrID int
Declare @RateQuoted decimal(18,6)
Declare @Tax Decimal(18,6)
Declare @CategoryID Int, @ItemCategoryID Int, @TmpItemCategoryID Int, @TmpFlag as Int

Declare @GSTFlag int
Select @GSTFlag = isnull(Flag,0) From tbl_merp_ConfigAbstract Where ScreenCode = 'GSTaxEnabled'

Set @TmpFlag = 0
Create Table #Temp(CategoryId int)

Select @QuotationType = QuotationLevel
From QuotationAbstract
Where QuotationId = @QuotationId

If @QuotationType = 2
Begin

Select @catid = CategoryID From Items Where Product_Code = @ItemCode
Select @TopLevelCatID = CategoryID From ItemCategories Where Category_Name In(Select dbo.fn_FirstLevelCategory(@catid))
Select @ParentCatId  = @catid

--This is to include 4th level category group of given item
Insert Into #Temp Values (@ParentCatId)

While @ParentCatId<>@TopLevelCatID
Begin
Select @ParentCatId = ParentID From ItemCategories Where CategoryID = @ParentCatId
Insert Into #Temp Values (@ParentCatId)
End

If (Select Distinct QuotationType From QuotationMfrCategory Where QuotationID = @QuotationId) = 2
BEGIN
--To check whether the Quotation is defined on Leaf Level
IF Exists(Select Top 1 MfrCategoryID From Items Items, QuotationMfrCategory QMfrCat
Where Items.Product_Code = @ItemCode
and Isnull(Items.CategoryID,0) = QMfrCat.MfrCategoryID
and  QMfrCat.QuotationType = 2
and  QMfrCat.QuotationId = @QuotationId)
BEGIN
Insert Into @tempcategory
Select MfrCategoryID From Items Items, QuotationMfrCategory QMfrCat
Where Items.Product_Code = @ItemCode
and Isnull(Items.CategoryID,0) = QMfrCat.MfrCategoryID
and  QMfrCat.QuotationType = 2
and  QMfrCat.QuotationId = @QuotationId
END
ELSE
BEGIN
Select @ItemCategoryID = CategoryID From Items Where Product_Code = @ItemCode And Active = 1
Set @TmpItemCategoryID = @ItemCategoryID
Set @CategoryID = @ItemCategoryID
While @CategoryID <> 0
Begin
Set @CategoryID = 0
If @TmpFlag = 0
Set @CategoryID = @ItemCategoryID
Else
Select @CategoryID = IsNull(ParentID, 0) From ItemCategories Where CategoryID = (@ItemCategoryID)
If Exists(Select MfrCategoryID From QuotationMfrCategory Where QuotationID = @QuotationID And MfrCategoryID = @CategoryID And QuotationType = 2)
Begin
Insert Into @tempCategory
Select @TmpItemCategoryID
Break
End
Set @ItemCategoryID = @CategoryID
Set @TmpFlag = 1
End
END
END
End

If @QuotationType = 3
Begin
Select @mfrID = Isnull(ManufacturerID,0) from Items Where Product_Code  = @ItemCode
Insert into #temp Values (@mfrID)
End

If @QuotationType = 1 -- Items
Begin
IF @GSTFlag = 1
Begin
Select Case isNull(SpecialTaxApplicable,0) When 0 Then RateQuoted Else
(Case When isnull(CS_TaxCode,0) > 0 Then
(RateQuoted - isnull(dbo.Fn_Quotation_TaxCompCalc(Product_Code,Tax_Code,TaxType,1,@RegisterStatus),0))
/ (1 + ( isnull(dbo.Fn_Quotation_TaxCompCalc(Product_Code,Tax_Code,TaxType,0,@RegisterStatus),0) /100))
Else (Case TOQ When 1 then (RateQuoted - TAX) Else (RateQuoted / (1 + (Tax/100))) End) End) End 'RateQuoted' ,

TaxPercentage 'Tax',Discount,AllowScheme,Tax_Code , RateQuoted 'NetRate' , isNull(SpecialTaxApplicable,0) 'SpecialTaxApp'
From
(Select RateQuoted,
(Case isNull(SpecialTaxApplicable,0)
When 0 Then (Case dbo.FN_Get_GST_CustomerLocality(Customer.CustomerID) When 1 Then Isnull(Tax.Percentage,0) When 2 Then Isnull(Tax.CST_Percentage,0) End)
Else
(Case dbo.FN_Get_GST_CustomerLocality(Customer.CustomerID) When 1 Then Isnull(LSTTax.Percentage,0) When 2 Then Isnull(CSTTax.CST_Percentage,0) End)
End )'Tax',
(Case isNull(SpecialTaxApplicable,0)
When 0 Then (Case dbo.FN_Get_GST_CustomerLocality(Customer.CustomerID) When 1 Then Isnull(Tax.Percentage,0) When 2 Then Isnull(Tax.CST_Percentage,0) End)
Else (Case dbo.FN_Get_GST_CustomerLocality(Customer.CustomerID) When 1 Then Isnull(LSTTax.Percentage,0) When 2 Then Isnull(CSTTax.CST_Percentage,0) End)
End ) 'TaxPercentage',
QItems.Discount , AllowScheme ,
(Case isNull(SpecialTaxApplicable,0)
When 0 Then Tax.Tax_Code Else (Case Locality When 1 Then LSTTax.Tax_Code When 2 Then CSTTax.Tax_Code  End) End)  'Tax_Code',IsNull(TOQ_Sales,0) as TOQ
,dbo.FN_Get_GST_CustomerLocality(Customer.CustomerID) 'TaxType', Items.Product_Code,

(Case isNull(SpecialTaxApplicable,0)
When 0 Then Tax.CS_TaxCode Else (Case dbo.FN_Get_GST_CustomerLocality(Customer.CustomerID) When 1 Then LSTTax.CS_TaxCode When 2 Then CSTTax.CS_TaxCode  End)
End)  'CS_TaxCode'
,isNull(SpecialTaxApplicable,0) 'SpecialTaxApplicable'
From QuotationItems QItems
Inner Join QuotationCustomers QCust On 	QItems.QuotationId = QCust.QuotationID
Inner Join Customer On QCust.CustomerID = Customer.CustomerID
Left Outer Join  Tax On Tax.Tax_Code = QItems.QuotedTax
Left Outer Join Tax LSTTax On LSTTax.Tax_Code = QItems.Quoted_LSTTax
Left Outer Join Tax CSTTax On 	CSTTax.Tax_Code = QItems.Quoted_CSTTax
Inner Join Items On 	QItems.Product_Code = Items.Product_Code
Where QItems.QuotationId = @QuotationId and QCust.CustomerID = @CustomerID and QItems.Product_Code = @ItemCode
) as A
End
Else
Begin
Select (Case TOQ When 1 then (RateQuoted - TAX) Else (RateQuoted / (1 + (Tax/100))) End) 'RateQuoted' ,
TaxPercentage 'Tax',Discount,AllowScheme,Tax_Code , RateQuoted 'NetRate', isNull(SpecialTaxApplicable,0) 'SpecialTaxApp'
From
(Select RateQuoted,
(Case isNull(SpecialTaxApplicable,0)
When 0 Then
(Case Locality When 1 Then Isnull(Tax.Percentage,0) When 2 Then Isnull(Tax.CST_Percentage,0) End)
Else
(Case Locality When 1 Then Isnull(LSTTax.Percentage,0) When 2 Then Isnull(CSTTax.CST_Percentage,0) End)
End )'Tax',
(Case isNull(SpecialTaxApplicable,0)
When 0 Then
(Case Locality When 1 Then Isnull(Tax.Percentage,0) When 2 Then Isnull(Tax.CST_Percentage,0) End)
Else
(Case Locality When 1 Then Isnull(LSTTax.Percentage,0) When 2 Then Isnull(CSTTax.CST_Percentage,0) End)
End ) 'TaxPercentage',
QItems.Discount , AllowScheme ,
(Case isNull(SpecialTaxApplicable,0)
When 0 Then Tax.Tax_Code
Else (Case Locality When 1 Then LSTTax.Tax_Code When 2 Then CSTTax.Tax_Code  End)
End)  'Tax_Code',IsNull(TOQ_Sales,0) as TOQ
,isNull(SpecialTaxApplicable,0) 'SpecialTaxApplicable'
From QuotationItems QItems
Inner Join  QuotationCustomers QCust On QItems.QuotationId = QCust.QuotationID
Inner Join Customer On QCust.CustomerID = Customer.CustomerID
Left Outer Join  Tax On Tax.Tax_Code = QItems.QuotedTax
Left Outer Join Tax LSTTax On LSTTax.Tax_Code = QItems.Quoted_LSTTax
Left Outer Join Tax CSTTax On CSTTax.Tax_Code = QItems.Quoted_CSTTax
Inner Join Items On QItems.Product_Code = Items.Product_Code
Where QItems.QuotationId = @QuotationId and
QCust.CustomerID = @CustomerID and
QItems.Product_Code = @ItemCode
) as A
End
End

Else
IF @QuotationType = 2 or @QuotationType = 3   -- Cat/Mrp
Begin
IF @GSTFlag = 1
Begin
Select RateQuoted 'RateQuoted' ,Tax,Discount,AllowScheme,Tax_Code , RateQuoted 'NetRate', isNull(SpecialTaxApplicable,0) 'SpecialTaxApp'
From(
Select 'RateQuoted' = (Case MarginOn When 2 Then @PurchasePrice * (1 + MarginPercentage / 100)
Else @EcpMrp * (1 - MarginPercentage / 100) End),
(Case isNull(SpecialTaxApplicable,0)
When 0 Then (Case dbo.FN_Get_GST_CustomerLocality(Customer.CustomerID) When 1 Then Isnull(Tax.Percentage,0) When 2 Then Isnull(Tax.CST_Percentage,0) End)
Else (Case dbo.FN_Get_GST_CustomerLocality(Customer.CustomerID) When 1 Then Isnull(LSTTax.Percentage,0) When 2 Then Isnull(CSTTax.CST_Percentage,0) End)

End) 'Tax',
QMfr.Discount, AllowScheme,
(Case isNull(SpecialTaxApplicable,0)
When 0 Then Tax.Tax_Code Else (Case dbo.FN_Get_GST_CustomerLocality(Customer.CustomerID) When 1 Then LSTTax.Tax_Code When 2 Then CSTTax.Tax_Code  End)
End) 'Tax_Code'
,isNull(SpecialTaxApplicable,0) 'SpecialTaxApplicable'
From QuotationMfrCategory QMfr
Inner Join QuotationCustomers QCust On QMfr.QuotationId = QCust.QuotationId
Inner Join Items On Items.Product_Code = @ItemCode
Inner Join  Customer On QCust.CustomerID = Customer.CustomerID
Left Outer Join Tax  On Tax.Tax_Code = Case When Tax = -1 then items.sale_tax Else Tax  End
Left Outer Join Tax LSTTax On 	LSTTax.Tax_Code = QMfr.Quoted_LSTTax
Left Outer Join Tax CSTTax On CSTTax.Tax_Code = QMfr.Quoted_CSTTax
Where QMfr.QuotationId = @QuotationId and
QCust.CustomerID = @CustomerID and
QMfr.MfrCategoryID In (Select CategoryID From #Temp) And
((ManufacturerId = MfrCategoryID and QuotationType = 1) Or
--(CategoryID = MfrCategoryID and QuotationType = 2)
(CategoryID IN (SELECT * FROM @tempCategory) AND QuotationType = 2))
) as B
End
Else
Begin
Select RateQuoted 'RateQuoted' ,Tax,Discount,AllowScheme,Tax_Code , RateQuoted 'NetRate' , isNull(SpecialTaxApplicable,0) 'SpecialTaxApp'
From(
Select 'RateQuoted' =
(Case MarginOn
When 2 Then
@PurchasePrice * (1 + MarginPercentage / 100)
Else
@EcpMrp * (1 - MarginPercentage / 100)
End),
(Case isNull(SpecialTaxApplicable,0)
When 0 Then
(Case Locality When 1 Then Isnull(Tax.Percentage,0) When 2 Then Isnull(Tax.CST_Percentage,0) End)
Else
(Case Locality When 1 Then Isnull(LSTTax.Percentage,0) When 2 Then Isnull(CSTTax.CST_Percentage,0) End)
End) 'Tax', QMfr.Discount, AllowScheme,
(Case isNull(SpecialTaxApplicable,0)
When 0 Then Tax.Tax_Code
Else (Case Locality When 1 Then LSTTax.Tax_Code When 2 Then CSTTax.Tax_Code  End)
End) 'Tax_Code'
,isNull(SpecialTaxApplicable,0) 'SpecialTaxApplicable'
From QuotationMfrCategory QMfr
Inner Join QuotationCustomers QCust On QMfr.QuotationId = QCust.QuotationId
Inner Join  Items On Items.Product_Code = @ItemCode
Inner Join  Customer On QCust.CustomerID = Customer.CustomerID
Left Outer Join  Tax  On Tax.Tax_Code = Case When Tax = -1 then items.sale_tax Else Tax  End
Left Outer Join Tax LSTTax On LSTTax.Tax_Code = QMfr.Quoted_LSTTax
Left Outer Join Tax CSTTax On CSTTax.Tax_Code = QMfr.Quoted_CSTTax
Where QMfr.QuotationId = @QuotationId and
QCust.CustomerID = @CustomerID and
QMfr.MfrCategoryID In (Select CategoryID From #Temp) And
((ManufacturerId = MfrCategoryID and QuotationType = 1) Or
--(CategoryID = MfrCategoryID and QuotationType = 2)
(CategoryID IN (SELECT * FROM @tempCategory) AND QuotationType = 2))) as B
End
End
Else
IF @QuotationType = 4
Begin
Declare @MarginPer decimal(18,6)
Set @MarginPer = 0
IF Isnull(@PurchasePrice,0) > 0
Set @MarginPer = ((Isnull(@SalePrice,0) - @PurchasePrice) / @PurchasePrice) * 100

-- Universal Discount
Select 'RateQuoted' = NULL, 'QuotedTax' = NULL, Discount, 'AllowScheme' = 1, 'tax_code' = Null ,'NetRate'=NULL,'SpecialTaxApp' = 0
From QuotationUniversal
Where QuotationId = @QuotationId and
@MarginPer between MarginFrom and MarginTo
End

Drop Table #Temp
