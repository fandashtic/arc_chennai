CREATE PROCEDURE [dbo].[spr_Price_List]   
As    
Begin  
 select  Distinct 1,GR.Categorygroup [Group] ,  
 GR.Division Category,  
 IC3.Category_Name [Sub Category] ,  
 IC4.Category_Name [MARKET SKU],   
 I.Product_code [Item Code],  
 I.ProductName [Item Name],  
 Cast((I.PTS * Isnull((Case I.UOM2_Conversion When 0 Then 1 Else I.UOM2_Conversion End),1)) as Decimal(18,6)) [PTS in Packs],  
 Cast((I.PTR * Isnull((Case I.UOM2_Conversion When 0 Then 1 Else I.UOM2_Conversion End),1)) as Decimal(18,6)) [PTR in Packs],  
 Cast((T.Percentage) as Decimal (18,6)) [Tax %],  
 Cast((Cast((I.PTR * Isnull((Case I.UOM2_Conversion When 0 Then 1 Else I.UOM2_Conversion End),1)) as Decimal(18,6))  * (Cast((T.Percentage) as Decimal (18,6)) / 100)) as Decimal(18,6)) TaxAmount ,  
 Cast((Cast((I.PTR * Isnull((Case I.UOM2_Conversion When 0 Then 1 Else I.UOM2_Conversion End),1)) as Decimal(18,6)) +   
 Cast((Cast((I.PTR * Isnull((Case I.UOM2_Conversion When 0 Then 1 Else I.UOM2_Conversion End),1)) as Decimal(18,6))  * (Cast((T.Percentage) as Decimal (18,6)) / 100)) as Decimal(18,6))  
 ) as Decimal(18,6)) [Net Price],  
 Cast((I.ECP * Isnull((Case I.UOM2_Conversion When 0 Then 1 Else I.UOM2_Conversion End),1)) as Decimal(18,6)) [MRP in Packs],  
 Cast((I.UOM1_Conversion / (Case I.UOM2_Conversion When 0 Then 1 Else I.UOM2_Conversion End)) as Decimal(18,6)) [Packs For CFC]  
 from items I , tblCGDivMapping GR, ItemCategories IC4 , ItemCategories IC3 , ItemCategories IC2 ,Tax T  
 where IC4.categoryid = i.categoryid   
 and IC4.ParentId = IC3.categoryid   
 and IC3.ParentId = IC2.categoryid   
 and IC2.Category_Name = GR.Division   
 And T.Tax_Code = I.Taxsuffered  
 Order by 1,2,3,4 Asc  
End
