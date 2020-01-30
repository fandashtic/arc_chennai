CREATE PROCEDURE [dbo].[spr_list_invoices_by_beat_abstract_Van_pidilite](@beat nvarchar(2550),   
@Category nVarchar(2550), @VAN nVARCHAR(100),@FROMDATE DATETIME, @TODATE DATETIME)        
AS        
  
DECLARE @Delimeter as Char(1)            
SET @Delimeter=Char(15)          
Create Table #tmpBeat(Beat varchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)        
  
If @Beat = N'%'             
 Insert into #tmpBeat Select Description from Beat            
Else            
 Insert into #tmpBeat Select * from dbo.sp_SplitIn2Rows(@Beat,@Delimeter)         
                      
Create Table #tempCategory(CategoryID int, Status int)                        
Exec GetLeafCategories N'%', @Category                      
  
select      
"BeatVan" = Convert(nVarchar,case Isnull(Beat.Description,N'') When N'' Then 0 Else Beat.BeatID End) +   
 Char(15) + Van.Van,  
--"BeatID" = case Isnull(Beat.Description,'') When '' Then 0 Else Beat.BeatID End,        
"Beat" = IsNull(Beat.Description, N'Others'),         
"Van" = Van.Van,    
"Net Value (%c)" = Sum(distinct NetValue),        
"Balance (%c)" = Sum(distinct Balance),        
"Quantity" = Sum(Quantity),      
"Reporting UOM" = Sum(Quantity / Case IsNull(ReportingUnit, 1) When 0 Then 1 Else IsNull(ReportingUnit, 1) End),
"Conversion Factor" = Sum(Quantity * IsNull(ConversionFactor, 0)),
"KGS/Ltr" = sum(isnull(Quantity, 0) / Case isnull(Items.reportingunit, 1)       
           When 0 Then 1 Else isnull(Items.reportingunit, 1) End)      
-- Case When Count(DISTINCT Items.ReportingUOM) <=1 Then      
--        Case When IsNull(Max(Items.ReportingUnit),0) > 0       
--        Then Cast(Cast(Sum(Quantity)/Max(Items.ReportingUnit) as Decimal(18,2)) as nVarchar) End End  
-- --+ ' ' + Max(uom.[Description]) End      
-- --       End      
FROM InvoiceAbstract
Left Outer Join Beat  On  InvoiceAbstract.BeatID = Beat.BeatID
Inner Join InvoiceDetail  On InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID 
Inner Join  Items On InvoiceDetail.Product_Code = Items.Product_Code
Left Outer Join uom On uom.uom = Items.ReportingUOM 
Inner Join Van On InvoiceAbstract.VanNumber=Van.Van 
WHERE   InvoiceType in (1, 3) AND        
 (Status & 128) = 0 AND         
 Van.van Like @VAN AND  
-- InvoiceAbstract.VanNumber Like @VAN AND  
--=@VAN AND     
 Beat.Description IN (Select Beat COLLATE SQL_Latin1_General_CP1_CI_AS From #tmpBeat) AND  
 Items.CategoryID in (Select CategoryID from #tempCategory) AND   
 InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE        
GROUP BY Beat.BeatID,Beat.Description,Van.Van        

SET QUOTED_IDENTIFIER OFF 

