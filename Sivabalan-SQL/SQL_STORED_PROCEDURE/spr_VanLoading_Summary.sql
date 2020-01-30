CREATE procedure [dbo].[spr_VanLoading_Summary](@ProductHier nVarChar(250),
										@Category nVarChar(250),
										@Beat nVarChar(250),
										@VanNo nVarChar(250),
										@FromDate DateTime,
										@ToDate DateTime)
As

Declare @Delimeter as Char(1)      
Set @Delimeter=Char(15)      
Declare @MLOthers nVarchar(50)
Set @MLOthers = dbo.LookupDictionaryItem(N'Others', Default)
    
create table #VanNo(van_number nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)    
if @VanNo='%'    
   insert into #VanNo select van_number from van
else    
   insert into #VanNo select * from dbo.sp_SplitIn2Rows(@VanNo ,@Delimeter)    
    
Create Table #tempCategory(CategoryID int, Status int)                  
Exec GetSubCategories @Category                

If @Beat = '%' 
Begin
Select v.van_number + char(15) + Convert(nvarchar, IsNull(bt.BeatID, 0)), 
"Van No" = v.van_number, 
"Beat Name" = IsNull(bt.[Description], @MLOthers),  
"Total Quantity" = sum(ids.Quantity), 
"Reporting UOM" = sum(ids.Quantity / Case IsNull(it.ReportingUnit, 1) When 0 Then 1 Else IsNull(it.ReportingUnit, 1) End), 
"Conversion Factor" = sum(ids.Quantity * it.ConversionFactor), 
"Total Value" = sum(ids.Amount)
From InvoiceAbstract ia, Beat bt, InvoiceDetail ids, Items it, Van v
WHERE   ia.InvoiceType in (1, 3) AND        
 (ia.Status & 128) = 0 AND         
 ia.BeatID *= bt.BeatID AND        
 ia.InvoiceID = ids.InvoiceID AND      
 ia.VanNumber=V.Van AND    
-- InvoiceAbstract.VanNumber Like @VAN AND  
 v.van_number In (select van_number from #VanNo) AND
 ids.Product_Code = It.Product_Code  AND
 It.CategoryID In (Select CategoryID From #tempCategory) AND
-- uom.uom =* Items.ReportingUOM And       
 ia.InvoiceDate BETWEEN @FROMDATE AND @TODATE        
GROUP BY v.van_number, bt.[Description], bt.BeatID
Order By v.van_number
End
Else
Begin
Select v.van_number + char(15) + Convert(nvarchar, IsNull(bt.BeatID, 0)), 
"Van No" = v.van_number, 
"Beat Name" = IsNull(bt.[Description], @MLOthers),  
"Total Quantity" = sum(ids.Quantity), 
"Reporting UOM" = sum(ids.Quantity / Case IsNull(it.ReportingUnit, 1) When 0 Then 1 Else IsNull(it.ReportingUnit, 1) End), 
"Conversion Factor" = sum(ids.Quantity * it.ConversionFactor), 
"Total Value" = sum(ids.Amount)
From InvoiceAbstract ia, Beat bt, InvoiceDetail ids, Items it, Van v
WHERE   ia.InvoiceType in (1, 3) AND        
 (ia.Status & 128) = 0 AND         
 ia.BeatID = bt.BeatID AND        
 ia.InvoiceID = ids.InvoiceID AND      
 ia.VanNumber=V.Van AND    
-- InvoiceAbstract.VanNumber Like @VAN AND  
 v.van_number In (select van_number from #VanNo) AND
 ids.Product_Code = It.Product_Code AND
 bt.[Description] Like @Beat AND
 It.CategoryID In (Select CategoryID From #tempCategory) AND
-- uom.uom =* Items.ReportingUOM And       
 ia.InvoiceDate BETWEEN @FROMDATE AND @TODATE        
GROUP BY v.van_number, bt.[Description], bt.BeatID
Order By v.van_number
End
