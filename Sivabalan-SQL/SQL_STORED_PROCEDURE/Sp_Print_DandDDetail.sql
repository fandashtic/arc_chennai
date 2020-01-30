  
Create Procedure Sp_Print_DandDDetail(@ID Int)  
AS  
Declare @ClaimStatus	int

Select @ClaimStatus = ClaimStatus From DandDAbstract Where ID = @ID
 
Create Table #temp(Product_Code nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,  
     Category nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,  
     Sub_Category nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,  
     Market_SKU nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS)  
  
Insert Into #temp(Product_Code, Category, Sub_Category, Market_SKU)  
Select  
 Distinct I.Product_Code, IC1.Category_Name,  
 IC2.Category_Name, IC3.Category_Name    
From  
 ItemCategories IC1, ItemCategories IC2, ItemCategories IC3, Items I  
Where  
 IC1.CategoryID = IC2.ParentID  
 And IC2.CategoryID = IC3.ParentID   
 And IC1.Level = 2  
 And I.CategoryID = IC3.CategoryID  
Order By  
 I.Product_Code, IC1.Category_Name, IC2.Category_Name, IC3.Category_Name  
  
  
Create Table #DandDTemp(Category nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,  
      Sub_Category nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,  
      Market_SKU nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,  
      Item_Code nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,  
      Item_Name nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,  
      UOM nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS,  
      Total_Qty Decimal(18, 6),  
      Rate Decimal(18, 6),  
      Tax Decimal(18, 6),
      Physical_RFA_Qty Decimal(18, 6),  
      Salvage_Qty Decimal(18, 6),  
      Salvage_Rate Decimal(18, 6),  
      Salvage_Value Decimal(18, 6),  
      Salvage_UOM nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS
       --- BUOMQty
      ,BUOMQty Decimal(18,6))  
   

If @ClaimStatus = 1
Begin
	Insert Into #DandDTemp(Category, Sub_Category, Market_SKU, Item_Code, Item_Name
							,UOM, Total_Qty, Rate, Tax,BUOMQty)  
	Select  
	 t.Category,  
	 t.Sub_Category,  
	 t.Market_SKU,  
	 Items.Product_Code,  
	 Items.ProductName,  
	 UOM.Description,  
	 Sum(IsNull(DandDDetail.UOMTotalQty, 0)),  
	 Max(IsNull(DandDDetail.UOMPTS, 0)),  
	 Max(IsNull(DandDDetail.TaxSuffered, 0))
	 --BUOMQty
	 ,SUM(ISNULL(DandDDetail.TotalQuantity,0))
	   
	From  
	 DandDDetail, Items, UOM, #temp t
	Where  
	 DandDDetail.ID = @ID  
	 And DandDDetail.Product_Code = Items.Product_Code  
	 And DandDDetail.Product_Code = t.Product_Code  	 
	 And DandDDetail.UOM = UOM.UOM  	 
	Group By  
	 T.Category, t.Sub_Category, t.Market_SKU,  
	 Items.Product_Code, Items.ProductName, UOM.Description	 
	Order By  
	 T.Category, t.Sub_Category, t.Market_SKU, Items.Product_Code, Items.ProductName  

End
Else
Begin

	Insert Into #DandDTemp  
	Select  
	 t.Category,  
	 t.Sub_Category,  
	 t.Market_SKU,  
	 Items.Product_Code,  
	 Items.ProductName,  
	 UOM.Description,  
	 Sum(IsNull(DandDDetail.UOMTotalQty, 0)),  
	 Max(IsNull(DandDDetail.UOMPTS, 0)),  
	 Max(IsNull(DandDDetail.TaxSuffered, 0)),   
	 Sum(IsNull(DandDDetail.UOMRFAQty, 0)),  
	 0 As SalvageQty,  
	 Max(IsNull(DandDDetail.SalvageUOMRate, 0)),  
	 0 As SalvageValue,  
	 UOM1.Description
	 --- BUOMQty
	 ,SUM(ISNULL(DandDDetail.TotalQuantity,0))
	From  
	 DandDDetail
	 Inner Join Items On DandDDetail.Product_Code = Items.Product_Code  
	 Inner Join  #temp t On DandDDetail.Product_Code = t.Product_Code  	 
	 Inner Join  UOM On DandDDetail.UOM = UOM.UOM  
	 Left Outer Join  UOM Uom1 On DandDDetail.SalvageUOM = UOM1.UOM   
	Where  
	 DandDDetail.ID = @ID  
	Group By  
	 T.Category, t.Sub_Category, t.Market_SKU,  
	 Items.Product_Code, Items.ProductName, UOM.Description, UOM1.Description  
	Order By  
	 T.Category, t.Sub_Category, t.Market_SKU, Items.Product_Code, Items.ProductName  

	Update  DD
	Set DD.Salvage_Qty = (A.SalvQty / A.TotRFAQty) *  DD.Physical_RFA_Qty
	From #DandDTemp DD, (Select Product_Code, Sum(IsNull(UOMRFAQty, 0)) As TotRFAQty, Max(IsNull(SalvageUOMQuantity, 0)) As SalvQty From DandDDetail Where ID = @ID Group By Product_code ) A
	Where DD.Item_Code = A.Product_Code
	and IsNull(DD.Physical_RFA_Qty, 0) > 0
End
 

Select  
 "Category" = Category,  
 "Item Code" = Item_Code,  
 "Item Name" = Item_Name,  
 "UOM" = UOM,  
 "Total Qty" = Total_Qty,   
 "Physical RFA Qty" = Physical_RFA_Qty,  
 "Salvage Qty" = Salvage_Qty,  
 "salvage UOM" = Salvage_UOM,  
 "Salvage Rate" = Salvage_Rate,  
 "Salvage Value" = Salvage_Qty * Salvage_Rate,   
 "Rate" = Rate,  
 "Tax%" = Tax 
 ,"BUOMQty" = BUOMQty  
From #DandDTemp  
  
Drop Table #temp  
Drop Table #DandDTemp 
 
