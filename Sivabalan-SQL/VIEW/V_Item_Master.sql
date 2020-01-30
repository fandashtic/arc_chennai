Create VIEW  [dbo].[V_Item_Master]
([Seq_No],[Item_Code],[Item_Name],[Item_Description],[Parent_categoryID],[Base_UOM],[UOM_1],[UOM_2],[UOM1_Conversion],
[UOM2_Conversion],[Default_Sales_UOM],[Tax],[PTR_exclusive_of_Tax_On_Base_UOM],
[PTR_inclusive_Tax_On_Base_UOM],[PTR_exclusive_of_Tax_On_UOM1],[PTR_inclusive_Tax_On_UOM1],
[PTR_exclusive_of_Tax_On_UOM2],[PTR_inclusive_Tax_On_UOM2],[MRP],[Available_Stock_in_Base_UOM],[Available_Stock_in_UOM1],
[Available_Stock_in_UOM2],[Active],[Creation_Date],[Modified_Date],OCG_ID,CG_ID,[HealthCare_Item])
AS

SELECT
ROW_NUMBER() OVER (order by isnull(Seq_No,'zzzzzzzzzz')) [Seq_No],
I.Product_code, I.ProductName,
Case When IsNull(RTrim(LTrim(IProperty.HHDesc)), '') <> '' then IProperty.HHDesc
When Isnull(I.Description, '') <> '' then I.Description
else I.ProductName end,
I.CategoryId, I.UOM, I.UOM1, I.UOM2, I.UOM1_Conversion, I.UOM2_Conversion,
'DefaultUOM' = I.UOM2,
--  'DefaultUOM' = Case IsNull(I.[DefaultUOM] & 7,0)
--                 when 1 then Case IsNull(I.[UOM1],0) when 0 then IsNull(I.[UOM],0) else IsNull(I.[UOM1],0) end
--                 when 2 then Case IsNull(I.[UOM2],0) when 0 then IsNull(I.[UOM],0) else IsNull(I.[UOM2],0) end
--                 else IsNull(I.[UOM],0) end,

Sale_Tax, PTR AS PTR_exclusive_of_Tax_On_Base_UOM,
--(PTR * isnull(Tax.Percentage, 0) / 100) + PTR AS PTR_inclusive_Tax_On_Base_UOM ,

--Fritfitc-825 - GST changes for PTR_inclusive_Tax_On_Base_UOM
Case When isnull(Tax.CS_TaxCode, 0) > 0 Then dbo.Fn_openingbal_TaxCompCalc(I.Product_code,Tax.Tax_Code, 1, PTR, 1, 1, 0) + PTR
Else
(Case When isnull(TOQ_Sales, 0) = 1 Then isnull(Tax.Percentage, 0) + PTR
Else(PTR * isnull(Tax.Percentage, 0) / 100) + PTR End)  End AS PTR_inclusive_Tax_On_Base_UOM ,

PTR * isnull(UOM1_Conversion, 0) as PTR_exclusive_of_Tax_On_UOM1,
--((PTR * isnull(Tax.Percentage, 0) / 100) + PTR) * isnull(UOM1_Conversion,0) as PTR_Inclusive_of_Tax_On_UOM1,

--Fritfitc-825 - GST changes for PTR_Inclusive_of_Tax_On_UOM1
Case When isnull(Tax.CS_TaxCode, 0) > 0 Then (dbo.Fn_openingbal_TaxCompCalc(I.Product_code,Tax.Tax_Code, 1, PTR, 1, 1, 0) + PTR) * isnull(UOM1_Conversion,0)
Else
(Case When isnull(TOQ_Sales, 0) = 1 Then (isnull(Tax.Percentage, 0) + PTR) * isnull(UOM1_Conversion,0)
Else ((PTR * isnull(Tax.Percentage, 0) / 100) + PTR) * isnull(UOM1_Conversion,0) End)
End AS PTR_Inclusive_of_Tax_On_UOM1,

PTR * isnull(UOM2_Conversion, 0) as PTR_exclusive_of_Tax_On_UOM2,
--((PTR * isnull(Tax.Percentage, 0) / 100) + PTR) * isnull(UOM2_Conversion,0) as PTR_Inclusive_of_Tax_On_UOM2,

--Fritfitc-825 - GST changes for PTR_Inclusive_of_Tax_On_UOM2
Case When isnull(Tax.CS_TaxCode, 0) > 0 Then (dbo.Fn_openingbal_TaxCompCalc(I.Product_code,Tax.Tax_Code, 1, PTR, 1, 1, 0) + PTR) * isnull(UOM2_Conversion,0)
Else
(Case When isnull(TOQ_Sales, 0) = 1 Then (isnull(Tax.Percentage, 0) + PTR) * isnull(UOM2_Conversion,0)
Else ((PTR * isnull(Tax.Percentage, 0) / 100) + PTR) * isnull(UOM2_Conversion,0) End)
End AS PTR_Inclusive_of_Tax_On_UOM2,

--MRP,
MRPPerPack,
'Available_Stock_in_Base_UOM'= isnull((select sum(isnull(Quantity,0)) from Batch_Products  where Product_code = I.Product_Code and (damage = 0  or damage is null)  and (expiry > getdate() or expiry is null)),0),
'Available_Stock_in_UOM1'= isnull((case  when Isnull(UOM1_Conversion,0) = 0 then 0 else (select sum(isnull(Quantity,0)) from Batch_Products  where Product_code = I.Product_Code and (damage = 0  or damage is null)
and (expiry > getdate() or expiry is null))/UOM1_Conversion end),0) ,
'Available_Stock_in_UOM2'= isnull((case  when Isnull(UOM2_Conversion,0) = 0 then 0 else (select sum(isnull(Quantity,0)) from Batch_Products  where Product_code = I.Product_Code and (damage = 0  or damage is null)
and (expiry > getdate() or expiry is null))/UOM2_Conversion end),0),
I.Active, I.CreationDate, ModifiedDate,Case When (Select top 1 flag from tbl_merp_configabstract where screencode='OCGDS')= 0 then CG.GroupName else Isnull(OCG.GroupName,CG.GroupName) end,CG.GroupName,
(Case IsNull(I.ASL,0) When 0 Then 'No' Else 'Yes' End) as [HealthCare_Item]
From Items I
Inner Join
(/*To Filter the Products having UOM2 Qty >= 10*/
Select BP.Product_Code as Product_Code From Items I Inner Join Batch_Products BP On I.Product_Code = BP.Product_Code
Where BP.Quantity > 0
And (BP.Damage = 0  or BP.Damage is null)
And (BP.Expiry > GetDate() or BP.Expiry is null)
Group By BP.Product_Code, IsNull(I.UOM2_Conversion,0)
Having Case IsNull(I.UOM2_Conversion,0) When 0 Then 0 Else Sum(BP.Quantity /IsNull(I.UOM2_Conversion,0) ) End >= 10
Union
/*To Filter Products Purchased with in 90 Days */
Select BD.Product_Code as Product_Code From BillAbstract BA Inner Join BillDetail BD On BA.BillID = BD.BillID
Where BA.Status & 192 = 0
And BD.Quantity > 0
And DateDiff(Day, BA.BillDate, GetDate()) <= 90

/* To Get Launch Items */
Union
Select Distinct ItemCode From LaunchItems LI, Items Where dbo.StripTimeFromDate(GetDate()) Between dbo.StripTimeFromDate(LaunchStartDate)
and dbo.StripTimeFromDate(LaunchEndDate) and LI.ItemCode = Items.Product_Code and isnull(LI.Active,0) = 1 and isnull(Items.Active,0) = 1

/*Add Aditional Items From SKUOptimitation*/
Union
Select Distinct SysSKUCode From V_DailySKU Where SysSKUCode Not In (
Select BP.Product_Code as Product_Code From Items I Inner Join Batch_Products BP On I.Product_Code = BP.Product_Code
Where BP.Quantity > 0
And (BP.Damage = 0  or BP.Damage is null)
And (BP.Expiry > GetDate() or BP.Expiry is null)
Group By BP.Product_Code, IsNull(I.UOM2_Conversion,0)
Having Case IsNull(I.UOM2_Conversion,0) When 0 Then 0 Else Sum(BP.Quantity /IsNull(I.UOM2_Conversion,0) ) End >= 10
Union

/*To Filter Products Purchased with in 90 Days */
Select BD.Product_Code as Product_Code From BillAbstract BA Inner Join BillDetail BD On BA.BillID = BD.BillID
Where BA.Status & 192 = 0
And BD.Quantity > 0
And DateDiff(Day, BA.BillDate, GetDate()) <= 90 )) vProducts On vProducts.Product_Code = I.Product_Code

Left Outer Join Tax  On I.Sale_Tax = Tax.Tax_code
Left Outer Join (Select Distinct Product_Code, Isnull(Value, '') [HHDesc] from Item_Properties IP
Inner Join Properties P on P.PropertyID = IP.PropertyID
where P.Property_Name = 'HH_Item_Desc') IProperty On IProperty.Product_Code = I.Product_Code
Left Outer Join (Select Distinct Product_Code, Isnull(Value, '') [Seq_No] from Item_Properties IP1
Inner Join Properties P1 on P1.PropertyID = IP1.PropertyID
where P1.Property_Name = 'Item_Seq') IProperty1 On IProperty1.Product_Code = I.Product_Code
Left Outer Join
(select distinct P.GroupName,Temp.Product_code from ProductCategoryGroupAbstract P,ItemCategories IC4,ItemCategories IC3,ItemCategories IC2,dbo.Fn_GetOCGSKU('%') Temp, Items ITE
where
P.GroupID = Temp.GroupID and
Temp.CategoryID = IC4.CategoryID and
isnull(OCGType,0)=1 and
Temp.CategoryID=IC4.CategoryID
And IC4.Parentid=IC3.CategoryID
And IC3.ParentID=IC2.CategoryID
And ITE.Product_code=Temp.Product_code) OCG
ON I.Product_code = OCG.Product_code
Left Outer Join
(Select PCGA.GroupName, I.CategoryID, I.Product_Code, I.ProductName
From ItemCategories IC1, ItemCategories IC2, ItemCategories IC3,ProductCategoryGroupAbstract PCGA,
Items I,tblCGDivMapping CGDIV
Where
CGDIV.Division = IC3.Category_Name
And IC3.CategoryID = IC2.ParentID
And IC2.CategoryID = IC1.ParentID
And IC1.CategoryID = I.CategoryID
And I.Active = 1
And CGDIV.CategoryGroup = PCGA.GroupName) CG
ON I.Product_code = CG.Product_code

--where I.CategoryID not in (select CatID from dbo.fn_GetCatFromCatGroup_Level('GR4',4,','))
where I.Product_Code not in (select Product_Code from dbo.fn_GetProductFromCatGroup_Level_Launch('GR4',4,','))
--		and Left(Upper(LTRIM (I.Product_Code)),2) <> 'FR' and  Left(Upper(LTRIM(I.Product_Code)),3) <> 'NFR'
And I.Product_Code Not In (Select Product_Code From tbl_merp_ItemCodeRestricted Where Active = 1)
--and (isnull(I.PTR,0) > 0.50  or isnull(I.PTR,0) = 0 )
and ((isnull(I.PTR,0) * IsNull(I.UOM2_Conversion,0)) > 0.50  or (isnull(I.PTR,0)*IsNull(I.UOM2_Conversion,0)) = 0 )

