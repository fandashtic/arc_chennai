
Create Procedure spr_ser_CategoryTargetDetail(@Item as NVarchar(255), @ProductHierarchy NVarchar(255),@CategoryName NVarchar(255), @UOM NVarchar(50))  
AS  
Declare @QTR_START INT  
Declare @QTR_END_PLUS_ONE INT  
Declare @ParamSep nVarchar(10)  
Declare @Delimeter as Char(1)  
Declare @tempString As NVarchar(255)  
Declare @ParamSepcounter as Int  
  
--For handling multiple Items Selected...  
Set @ParamSep = Char(2)            
Set @Delimeter = Char(15)  
  
Create Table #TmpCategory(Category_Name NVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  
  
  
If @CategoryName <> '%'     
   Insert into #TmpCategory Select * From dbo.sp_SplitIn2Rows(@CategoryName,@Delimeter)    
  
--Qtr Sepration from Parameter [@Item]  
Set @tempString = @ITEM  
/* QTR_START */  
Set @ParamSepcounter = CHARINDEX(@ParamSep,@tempString,1)  
set @QTR_START = substring(@tempString, 1, @ParamSepcounter-1)  
  
/* QTR_END */  
set  @QTR_END_PLUS_ONE = Convert(Int, substring(@tempString, @ParamSepcounter+1, len(@ITEM)))  
  
  
Select CategoryID, Category_Name  
, "Target Value (%c)" = Sum(TargetValue), "Actual Value (%c)" = Sum(ActualValue)  
, "Target Volume" = Sum(TargetVolume), "Actual Volume" = Sum(ActualVolume)  
from  
(  
    SELECT IC.CategoryID, IC.Category_Name  
    ,"TargetValue" = Sum(CT.Value)  
    ,"ActualValue" = 0  
    ,"TargetVolume" = Sum(CT.Volume)  
    ,"ActualVolume" = 0  
    FROM CategoryTarget CT  
    INNER JOIN ItemCategories IC ON CT.CategoryID = IC.CategoryID  
    LEFT OUTER JOIN ItemHierarchy IH ON IH.HierarchyID = IC.[Level]  
    WHERE (IC.Category_Name In (Select Category_Name from #TmpCategory) OR @CategoryName = '%')  
    AND (Convert(NVarchar(8),MonthYear,112) >= @QTR_START AND Convert(NVarchar(8),MonthYear,112) < @QTR_END_PLUS_ONE)  
    AND (IsNull(IH.[HierarchyName],'') = @ProductHierarchy OR IsNull(@ProductHierarchy,'') = '%')  
    GROUP BY   
    IC.CategoryID, IC.Category_Name  
      
    UNION ALL  
  
    SELECT IC.CategoryID, IC.Category_Name  
    ,"TargetValue" = 0  
    ,"ActualValue" = SUM(  
        CASE INVABS.InvoiceType   
        WHEN 4 Then 0 - INVDET.Amount  
        ELSE INVDET.Amount  
        END  
        /   
        CASE @UOM  
        WHEN 'Reporting UOM' THEN  IsNull(case when isnull(IT.reportingunit,0)=0  then 1  else IT.reportingunit end,0)  
        ELSE 1  
        END  
    )  
    ,"TargetVolume" = 0  
    ,"ActualVolume" = SUM(  
        CASE INVABS.InvoiceType   
        WHEN 4 Then 0 - INVDET.Quantity  
        ELSE INVDET.Quantity  
        END  
        /   
        CASE @UOM  
        WHEN 'Reporting UOM' THEN  IsNull(case when isnull(IT.reportingunit,0)=0  then 1  else IT.reportingunit end,0)  
        ELSE 1  
        END  
    )  
    FROM InvoiceAbstract INVABS  
    INNER JOIN InvoiceDetail INVDET ON INVABS.InvoiceID = INVDET.InvoiceID  
    INNER JOIN ITEMS IT ON INVDET.Product_Code = IT.Product_Code  
    INNER JOIN ItemCategories IC ON IT.CategoryID = IC.CategoryID  
    LEFT OUTER JOIN ItemHierarchy IH ON IH.HierarchyID = IC.[Level]  
    WHERE INVABS.InvoiceType IN (1,3,4)  
    AND IsNull(INVABS.Status,0) & 128 = 0  
    AND (Convert(NVarchar(8), INVABS.InvoiceDate, 112) >= @QTR_START AND Convert(NVarchar(8), INVABS.InvoiceDate, 112) < @QTR_END_PLUS_ONE)  
    AND (IC.Category_Name In (Select Category_Name from #TmpCategory) OR @CategoryName = '%')  
    AND (IsNull(IH.[HierarchyName],'') = @ProductHierarchy OR IsNull(@ProductHierarchy,'') = '%')  
    GROUP BY IC.CategoryID, IC.Category_Name  
   
   UNION ALL

   SELECT 
    IC.CategoryID, IC.Category_Name
    ,"TargetValue" = 0
    ,"ActualValue" = SUM(INVDET.NetValue
        / 
        CASE @UOM
        WHEN 'Reporting UOM' THEN  IsNull(case when isnull(IT.reportingunit,0)=0  then 1  else IT.reportingunit end,0)
        ELSE 1
        END
    )
    ,"TargetVolume" = 0
    ,"ActualVolume" = SUM(INVDET.Quantity
        / 
        CASE @UOM
        WHEN 'Reporting UOM' THEN  IsNull(case when isnull(IT.reportingunit,0)=0  then 1  else IT.reportingunit end,0)
        ELSE 1
        END
    )
    FROM ServiceInvoiceAbstract INVABS
    INNER JOIN ServiceInvoiceDetail INVDET ON INVABS.ServiceInvoiceID = INVDET.ServiceInvoiceID
    INNER JOIN ITEMS IT ON INVDET.SpareCode = IT.Product_Code
    INNER JOIN ItemCategories IC ON IT.CategoryID = IC.CategoryID
    LEFT OUTER JOIN ItemHierarchy IH ON IH.HierarchyID = IC.[Level]
    WHERE INVABS.ServiceInvoiceType IN (1)
    AND IsNull(INVABS.Status,0) & 192 = 0
    AND (Convert(NVarchar(8),INVABS.ServiceInvoiceDate,112) >= @QTR_START AND Convert(NVarchar(8), INVABS.ServiceInvoiceDate, 112) < @QTR_END_PLUS_ONE)
    AND (IC.Category_Name In (Select Category_Name from #TmpCategory) OR @CategoryName = '%')
    AND (IsNull(IH.[HierarchyName],'') = @ProductHierarchy OR IsNull(@ProductHierarchy,'') = '%')
    AND IsNull(INVDET.SpareCode, '') <> ''
    GROUP BY 
     IC.CategoryID, IC.Category_Name
) RS  
GROUP BY CategoryID, Category_Name  
HAVING (Sum(TargetValue) <> 0 OR Sum(ActualValue)  <> 0  OR
Sum(TargetVolume) <> 0  OR Sum(ActualVolume) <> 0)
DROP Table #TmpCategory  

