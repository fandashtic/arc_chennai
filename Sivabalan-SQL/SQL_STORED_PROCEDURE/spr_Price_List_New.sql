CREATE procedure [dbo].[spr_Price_List_New]
As        
Begin      

DECLARE @CGST AS INT = (SELECT  TOP 1 ISNULL(TaxComponent_code, 0) FROM TaxComponentDetail WHERE TaxComponent_desc = 'CGST')
DECLARE @SGST AS INT= (SELECT  TOP 1 ISNULL(TaxComponent_code, 0) FROM TaxComponentDetail WHERE TaxComponent_desc = 'SGST')
DECLARE @IGST AS INT= (SELECT  TOP 1 ISNULL(TaxComponent_code, 0) FROM TaxComponentDetail WHERE TaxComponent_desc = 'IGST')
DECLARE @CESS AS INT= (SELECT  TOP 1 ISNULL(TaxComponent_code, 0) FROM TaxComponentDetail WHERE TaxComponent_desc = 'CESS')
DECLARE @ADDLCESS AS INT= (SELECT  TOP 1 ISNULL(TaxComponent_code, 0) FROM TaxComponentDetail WHERE TaxComponent_desc = 'ADDL CESS')

 select  Distinct 1,
 I.Product_code [Item Code],      
 I.ProductName [Item Name],      
GR.Categorygroup [Group] ,      
 GR.Division Category,      
 IC3.Category_Name [Sub Category] ,      
 IC4.Category_Name [MARKET SKU],       
I.HSNNumber,
 Cast((I.PTS * Isnull((Case I.UOM2_Conversion When 0 Then 1 Else I.UOM2_Conversion End),1)) as Decimal(18,6)) [PTS in Packs],      
 Cast((I.PTR * Isnull((Case I.UOM2_Conversion When 0 Then 1 Else I.UOM2_Conversion End),1)) as Decimal(18,6)) [PTR in Packs],      
 --Cast((T.Percentage) as Decimal (18,6)) [Tax %],      
 --Cast((Cast((I.PTR * Isnull((Case I.UOM2_Conversion When 0 Then 1 Else I.UOM2_Conversion End),1)) as Decimal(18,6))  * (Cast((T.Percentage) as Decimal (18,6)) / 100)) as Decimal(18,6)) TaxAmount ,      
 
 Cast((I.ECP * Isnull((Case I.UOM2_Conversion When 0 Then 1 Else I.UOM2_Conversion End),1)) as Decimal(18,6)) [MRP in Packs],      
 Cast((I.UOM1_Conversion / (Case I.UOM2_Conversion When 0 Then 1 Else I.UOM2_Conversion End)) as Decimal(18,6)) [Packs For CFC]      
,dbo.fn_GetTaxValueByComponent(I.Taxsuffered,@CGST) [CGST%]  
,cast((case when dbo.fn_GetTaxValueByComponent(I.Taxsuffered,@CGST) <> 0 then dbo.fn_GetTaxValueByComponent(I.Taxsuffered,@CGST) / 100 else 0 end)* (Cast((I.PTR * Isnull((Case I.UOM2_Conversion When 0 Then 1 Else I.UOM2_Conversion End),1)) as Decimal(18,6))) as decimal

(18,6)) [CGST]  
,dbo.fn_GetTaxValueByComponent(I.Taxsuffered,@SGST) [SGST%]  
,cast((case when dbo.fn_GetTaxValueByComponent(I.Taxsuffered,@SGST) <> 0 then dbo.fn_GetTaxValueByComponent(I.Taxsuffered,@SGST) / 100 else 0 end)* (Cast((I.PTR * Isnull((Case I.UOM2_Conversion When 0 Then 1 Else I.UOM2_Conversion End),1)) as Decimal(18,6))) as decimal

(18,6)) [SGST]  
,dbo.fn_GetTaxValueByComponent(I.Taxsuffered,@IGST) [IGST%]  
,cast((case when dbo.fn_GetTaxValueByComponent(I.Taxsuffered,@IGST) <> 0 then dbo.fn_GetTaxValueByComponent(I.Taxsuffered,@IGST) / 100 else 0 end)* (Cast((I.PTR * Isnull((Case I.UOM2_Conversion When 0 Then 1 Else I.UOM2_Conversion End),1)) as Decimal(18,6))) as decimal

(18,6)) [IGST]  
,dbo.fn_GetTaxValueByComponent(I.Taxsuffered,@CESS) [CESS%]  
,cast((case when dbo.fn_GetTaxValueByComponent(I.Taxsuffered,@CESS) <> 0 then dbo.fn_GetTaxValueByComponent(I.Taxsuffered,@CESS) / 100 else 0 end)* (Cast((I.PTR * Isnull((Case I.UOM2_Conversion When 0 Then 1 Else I.UOM2_Conversion End),1)) as Decimal(18,6))) as decimal

(18,6)) [CESS]  
,dbo.fn_GetTaxValueByComponent(I.Taxsuffered,@ADDLCESS) * Isnull((Case I.UOM2_Conversion When 0 Then 1 Else I.UOM2_Conversion End),1) [ADDL CESS]  

,cast((case when dbo.fn_GetTaxValueByComponent(I.Taxsuffered,@CGST) <> 0 then dbo.fn_GetTaxValueByComponent(I.Taxsuffered,@CGST) / 100 else 0 end)* (Cast((I.PTR * Isnull((Case I.UOM2_Conversion When 0 Then 1 Else I.UOM2_Conversion End),1)) as Decimal(18,6))) as decimal

(18,6)) +

cast((case when dbo.fn_GetTaxValueByComponent(I.Taxsuffered,@SGST) <> 0 then dbo.fn_GetTaxValueByComponent(I.Taxsuffered,@SGST) / 100 else 0 end)* (Cast((I.PTR * Isnull((Case I.UOM2_Conversion When 0 Then 1 Else I.UOM2_Conversion End),1)) as Decimal(18,6))) as decimal


(18,6)) +
cast((case when dbo.fn_GetTaxValueByComponent(I.Taxsuffered,@CESS) <> 0 then dbo.fn_GetTaxValueByComponent(I.Taxsuffered,@IGST) / 100 else 0 end)* (Cast((I.PTR * Isnull((Case I.UOM2_Conversion When 0 Then 1 Else I.UOM2_Conversion End),1)) as Decimal(18,6))) as decimal(18,6)) +
case when dbo.fn_GetTaxValueByComponent(I.Taxsuffered, @ADDLCESS) > 0 then dbo.fn_GetTaxValueByComponent(I.Taxsuffered, @ADDLCESS) 
 * Isnull((Case I.UOM2_Conversion When 0 Then 1 Else I.UOM2_Conversion End),1)
else 0 end [Total Tax Value]  
,Cast((I.PTR * Isnull((Case I.UOM2_Conversion When 0 Then 1 Else I.UOM2_Conversion End),1)) as Decimal(18,6)) +     
(cast((case when dbo.fn_GetTaxValueByComponent(I.Taxsuffered,@CGST) <> 0 then dbo.fn_GetTaxValueByComponent(I.Taxsuffered,@CGST) / 100 else 0 end)* (Cast((I.PTR * Isnull((Case I.UOM2_Conversion When 0 Then 1 Else I.UOM2_Conversion End),1)) as Decimal(18,6))) as decimal
(18,6)) +
cast((case when dbo.fn_GetTaxValueByComponent(I.Taxsuffered,@CESS) <> 0 then dbo.fn_GetTaxValueByComponent(I.Taxsuffered,@CESS) / 100 else 0 end)* (Cast((I.PTR * Isnull((Case I.UOM2_Conversion When 0 Then 1 Else I.UOM2_Conversion End),1)) as Decimal(18,6))) as decimal(18,6)) +
cast((case when dbo.fn_GetTaxValueByComponent(I.Taxsuffered,@CESS) <> 0 then dbo.fn_GetTaxValueByComponent(I.Taxsuffered,@IGST) / 100 else 0 end)* (Cast((I.PTR * Isnull((Case I.UOM2_Conversion When 0 Then 1 Else I.UOM2_Conversion End),1)) as Decimal(18,6))) as decimal(18,6)) +
case when dbo.fn_GetTaxValueByComponent(I.Taxsuffered, @ADDLCESS) > 0 then dbo.fn_GetTaxValueByComponent(I.Taxsuffered, @ADDLCESS) 
 * Isnull((Case I.UOM2_Conversion When 0 Then 1 Else I.UOM2_Conversion End),1)
else 0 end) [Net Price]
  
 from items I with (nolock)  
, tblCGDivMapping GR with (nolock)  
, ItemCategories IC4  with (nolock)  
, ItemCategories IC3  with (nolock)  
, ItemCategories IC2  with (nolock)  
--,Tax T     with (nolock)  
 where IC4.categoryid = i.categoryid       
 and IC4.ParentId = IC3.categoryid       
 and IC3.ParentId = IC2.categoryid       
 and IC2.Category_Name = GR.Division       
-- And I.Taxsuffered = I.Taxsuffered      
 Order by 1,2,3,4 Asc      
End

