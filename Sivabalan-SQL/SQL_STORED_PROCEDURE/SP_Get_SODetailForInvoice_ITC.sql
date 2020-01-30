CREATE  Procedure SP_Get_SODetailForInvoice_ITC(@SONo nvarchar(255))    
AS    
-- This procedure returns the SO Details.    
-- with Sale order SchemeID which one received from handheld device  
    
Create Table #TempUOMWiseSODetail(    
 Product_Code nvarchar(30) Collate SQL_Latin1_General_CP1_CI_AS,     
 Batch_Number nvarchar(128) Collate SQL_Latin1_General_CP1_CI_AS,     
 SalePrice Decimal(18,6),     
 Quantity Decimal(18,6),    
 UomDescription nvarchar(255) Collate SQL_Latin1_General_CP1_CI_AS,    
 ECP decimal(18,6),   
 PTS decimal(18,6),     
 Discount decimal(18,6),    
 TaxApplicableOn int,    
 TaxPartOff Decimal(18,6),    
 TaxSuffApplicableOn int,    
 TaxSuffPartOff Decimal(18,6),    
 saletax Decimal(18,6),    
 taxsuffered Decimal(18,6),     
 UOM Int,     
 UOMPrice Decimal(18,6),    
 Serial int  ,  
 OrderedSchemeID int,
 Locality Int,
 MRPPerPack Decimal(18,6),    
 TaxONQty int
 )    
  
Select * into #tempScNew from dbo.sp_splitin2rows(@sono,',')    
  
Insert Into #TempUOMWiseSODetail   
Select SODetail.Product_Code, SoDetail.Batch_Number, soDetail.SalePrice,    
sum(SODetail.Pending)as Quantity, UOM.Description, Sodetail.Ecp, Sodetail.PTS, Sodetail.Discount,  
TaxApplicableOn, TaxPartOff, TaxSuffApplicableOn, TaxSuffPartOff ,   
(Case When ISNull(Customer.Locality,0) = 1 then sodetail.saletax Else sodetail.TaxCode2 End) as "SalesTax",  
sodetail.taxsuffered, SoDetail.UOM, SoDetail.UomPrice, sodetail.serial,   
Isnull((Select Top 1 SchemeID from Scheme_Details   
where SALEORDERID = SODetail.SONumber And SERIAL = SODetail.Serial AND ISNULL(SchemeID,0) <> 0 ),0), ISNull(Customer.Locality,0) as "Locality",
SODetail.MRPPerPack,Max(Isnull(SoDetail.TaxONQty,0))
From SOAbstract, SODetail, #tempScNew, Customer, Uom    
WHERE SODetail.SONumber = #tempScNew.itemvalue     
 And Customer.CustomerId = SOAbstract.CustomerID    
 And SOAbstract.SONumber = #tempScNew.itemvalue     
 And SoDetail.UOM = UOM.UOM  
GROUP BY  SODetail.SONumber,sodetail.serial,SODetail.Product_Code,SODetail.Batch_Number,SoDetail.SalePrice  ,    
 Sodetail.Ecp, Sodetail.PTS, Sodetail.Discount,TaxApplicableOn,TaxPartOff,TaxSuffApplicableOn,TaxSuffPartOff ,sodetail.saletax,sodetail.taxcode2,    
 sodetail.taxsuffered, Customer.Locality, UOM.Description, SoDetail.UOM, SoDetail.UomPrice,SODetail.MRPPerPack   
having sum(sodetail.pending) > 0     
order by sodetail.serial  

--Select * from #TempUOMWiseSODetail order by Serial    
-- Sp_Get_ItemInformation and Sp_Get_PricesFromItems are mearged in this Procedrue
Select 
SOD.Product_Code, SOD.Batch_Number, SOD.SalePrice , SOD.Quantity, SOD.UomDescription, 
SOD.ECP, SOD.Discount, SOD.TaxApplicableOn, SOD.TaxPartOff, 
SOD.TaxSuffApplicableOn, SOD.TaxSuffPartOff, SOD.saletax, SOD.taxsuffered,
SOD.UOM, SOD.UOMPrice, SOD.Serial, SOD.OrderedSchemeID,
"PRICEOPTION"= IC.Price_Option,"ItemName" = I.Productname,
"TrackBatch" = I.Track_batches, "TrackInv" = IC.Track_Inventory,
"IPTS" = Case When Isnull(SOD.PTS,0) = 0 Then I.PTS Else Isnull(SOD.PTS,0) End,"IPTR" = I.PTR,"IECP" = I.ECP,"ISplP" = I.Company_Price,
"IAdhocAmt" =  IsNull(I.AdhocAmount,0),
"VAT" = I.Vat, "CollectTaxSuffered" = I.CollectTaxSuffered,
"GroupID" = (Select GroupID From v_mERP_ItemWithCG Where Product_Code = SOD.Product_Code),
SOD.MRPPerPack,I.ToQ_Sales as TOQ_Sales
From #TempUOMWiseSODetail SOD, Items I, ItemCategories IC
Where SOD.Product_Code = I.Product_Code
And I.CategoryID = IC.CategoryID
Order By Serial

Drop Table #TempUOMWiseSODetail    
Drop Table #tempScNew  

