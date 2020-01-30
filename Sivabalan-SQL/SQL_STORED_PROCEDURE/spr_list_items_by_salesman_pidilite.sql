  
CREATE PROCEDURE spr_list_items_by_salesman_pidilite(@SALESMANID INT,  
@ProductHierarchy nVarChar(100),     
@Category nVarChar(4000),  
@beat nvarchar(2550),
@Salesman nVarchar(2550),    
@FromInvNo nVarchar(50),  
@ToInvNo nVarchar(50),  
@UOM nVarChar(100))     
  
AS  

Declare @Delimeter as Char(1)        
Set @Delimeter=Char(15)        

Create Table #tmpBeat(Beat Int)        

If @Beat = N'%'             
 Insert into #tmpBeat Select BeatID From Beat Union Select 0  
Else            
 Insert into #tmpBeat Select BeatID From Beat Where  Description In (Select * from dbo.sp_SplitIn2Rows(@Beat,@Delimeter))  
  
Create Table #tempCategory(CategoryID int, Status int)              
Exec getleafcategories @ProductHierarchy, @Category            
  
SELECT  InvoiceDetail.Product_Code, "Category Name" = itemcategories.category_name,  
"Item Code" = InvoiceDetail.Product_Code,   
 "Item Name" = Items.ProductName, "Mfr" = IsNull(Manufacturer.Manufacturer_Name, ''),  
 "Batch" = Batch_Number, "Sale Price" = SalePrice  
 , "Quantity" = sum(Case @UOM When N'Sales UOM' Then Quantity    
      When N'UOM1' Then  Quantity / (Case isnull(Items.uom1_conversion, 1) when 0 then 1 Else isnull(Items.uom1_conversion, 1) End)    
      When N'UOM2' Then Quantity / (Case isnull(Items.uom2_conversion, 1) when 0 then 1 Else isnull(Items.uom2_conversion, 1) End) End), 
"Reporting UOM" = Sum(Quantity / Case IsNull(ReportingUnit, 1) When 0 Then 1 Else IsNull(ReportingUnit, 1) End),
"Conversion Factor" = Sum(Quantity * IsNull(ConversionFactor, 0)),
    "Amount"=Sum(Amount)   
FROM InvoiceAbstract, InvoiceDetail, Items, itemcategories, Manufacturer  
WHERE Items.Categoryid = itemcategories.Categoryid And InvoiceAbstract.InvoiceType in (1, 3) AND  
(InvoiceAbstract.Status & 128) = 0 AND  
InvoiceAbstract.DocumentID BETWEEN dbo.GetTrueVal(@FromInvNo) AND dbo.GetTrueVal(@ToInvNo) AND  
InvoiceAbstract.SalesmanID = @SALESMANID AND  
InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND  
InvoiceDetail.Product_Code = Items.Product_Code And  
Items.ManufacturerID = Manufacturer.ManufacturerID And  
itemcategories.Categoryid In (Select Categoryid From #tempCategory) And
InvoiceAbstract.BeatID In (Select BeatID From #tmpBeat)  
GROUP BY InvoiceDetail.Product_Code, Items.ProductName, Batch_Number, SalePrice,  
Manufacturer.Manufacturer_Name, itemcategories.Category_Name  
Order By IsNull(Manufacturer.Manufacturer_Name, N'')  
  
  
