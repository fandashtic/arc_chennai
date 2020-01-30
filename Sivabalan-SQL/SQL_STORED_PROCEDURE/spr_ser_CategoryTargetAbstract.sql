
Create Procedure spr_ser_CategoryTargetAbstract(@ProductHierarchy NVarchar(255),@CategoryName NVarchar(255), @UOM NVarchar(50))
AS
Declare @FiscalMonth NVarchar(15)
Declare @OPYEAR NVarchar(15)
Declare @OP1ST_YEAR NVarchar(15)
Declare @FiscalDate DateTime
Declare @1ST_QTR As Int
Declare @2ND_QTR As Int
Declare @3RD_QTR As Int
Declare @4TH_QTR As Int
Declare @4TH_QTR_END As Int
Declare @5TH_QTR As Int


Declare @ParamSep nVarchar(10)                
Set @ParamSep = Char(2)                


--For handling multiple Items Selected...
Declare @Delimeter as Char(1)  
Set @Delimeter = Char(15)  

Create Table #TmpCategory(Category_Name NVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)


If @CategoryName <> '%'   
   Insert into #TmpCategory Select * From dbo.sp_SplitIn2Rows(@CategoryName,@Delimeter)  


select @FiscalMonth = FiscalYear,@OPYEAR = OperatingYear  from Setup
Select Top 1 @OP1ST_YEAR = ItemValue from dbo.sp_SplitIn2Rows(@OPYEAR,'-') Order BY ItemValue

--select @FiscalMonth = FiscalYear 
Set @FiscalDate = Convert(DateTime,'01/' + @FiscalMonth + '/' + @OP1ST_YEAR)

Set @1ST_QTR = Convert(NVarchar(8), @FiscalDate, 112)
Set @2ND_QTR = Convert(NVarchar(8), DateAdd(m,3,@FiscalDate), 112)
Set @3RD_QTR = Convert(NVarchar(8), DateAdd(m,6,@FiscalDate), 112)
Set @4TH_QTR = Convert(NVarchar(8), DateAdd(m,9,@FiscalDate), 112)
Set @4TH_QTR_END = Convert(NVarchar(8), DateAdd(d,-1, DateAdd(m, 12, @FiscalDate)), 112)
Set @5TH_QTR = Convert(NVarchar(8), DateAdd(m, 12, @FiscalDate), 112)
-- Select @1st_QTR, @2nd_QTR, @3rd_QTR ,@4th_QTR, @4TH_QTR_END
Select [ITEM], [Time]
, "Target Value (%c)" = Sum(TargetValue), "Actual Value (%c)" = Sum(ActualValue)
, "Target Volume" = Sum(TargetVolume), "Actual Volume" = Sum(ActualVolume)
from
(
    SELECT "ITEM" = 
    CASE 
        WHEN Convert(NVarchar(8),MonthYear,112) >= @1ST_QTR AND Convert(NVarchar(8),MonthYear,112) < @2ND_QTR THEN Convert(NVarchar, @1ST_QTR) + @ParamSep + Convert(NVarchar, @2ND_QTR)
        WHEN Convert(NVarchar(8),MonthYear,112) >= @2ND_QTR AND Convert(NVarchar(8),MonthYear,112) < @3RD_QTR THEN Convert(NVarchar, @2ND_QTR) + @ParamSep + Convert(NVarchar, @3RD_QTR)
        WHEN Convert(NVarchar(8),MonthYear,112) >= @3RD_QTR AND Convert(NVarchar(8),MonthYear,112) < @4TH_QTR THEN Convert(NVarchar, @3RD_QTR) + @ParamSep + Convert(NVarchar, @4TH_QTR)
        WHEN Convert(NVarchar(8),MonthYear,112) >= @4TH_QTR AND Convert(NVarchar(8),MonthYear,112) <= @4TH_QTR_END THEN Convert(NVarchar, @4TH_QTR) + @ParamSep + Convert(NVarchar, @5TH_QTR)
    END
    ,"Time" = 
    CASE 
        WHEN Convert(NVarchar(8),MonthYear,112) >= @1ST_QTR AND Convert(NVarchar(8),MonthYear,112) < @2ND_QTR THEN 'QTR 1'
        WHEN Convert(NVarchar(8),MonthYear,112) >= @2ND_QTR AND Convert(NVarchar(8),MonthYear,112) < @3RD_QTR THEN 'QTR 2'
        WHEN Convert(NVarchar(8),MonthYear,112) >= @3RD_QTR AND Convert(NVarchar(8),MonthYear,112) < @4TH_QTR THEN 'QTR 3'
        WHEN Convert(NVarchar(8),MonthYear,112) >= @4TH_QTR AND Convert(NVarchar(8),MonthYear,112) <= @4TH_QTR_END THEN 'QTR 4'
    END
    ,"TargetValue" = Sum(CT.Value)
    ,"ActualValue" = 0
    ,"TargetVolume" = Sum(CT.Volume)
    ,"ActualVolume" = 0
    FROM CategoryTarget CT
    INNER JOIN ItemCategories IC ON CT.CategoryID = IC.CategoryID
    LEFT OUTER JOIN ItemHierarchy IH ON IH.HierarchyID = IC.[Level]
    WHERE (IC.Category_Name In (Select Category_Name from #TmpCategory) OR @CategoryName = '%')
    AND (Convert(NVarchar(8),MonthYear,112) BETWEEN @1ST_QTR AND @4TH_QTR_END)
    AND (IsNull(IH.[HierarchyName],'') = @ProductHierarchy OR IsNull(@ProductHierarchy,'') = '%')
    GROUP BY 
    CASE 
        WHEN Convert(NVarchar(8),MonthYear,112) >= @1ST_QTR AND Convert(NVarchar(8),MonthYear,112) < @2ND_QTR THEN Convert(NVarchar, @1ST_QTR) + @ParamSep + Convert(NVarchar, @2ND_QTR)
        WHEN Convert(NVarchar(8),MonthYear,112) >= @2ND_QTR AND Convert(NVarchar(8),MonthYear,112) < @3RD_QTR THEN Convert(NVarchar, @2ND_QTR) + @ParamSep + Convert(NVarchar, @3RD_QTR)
        WHEN Convert(NVarchar(8),MonthYear,112) >= @3RD_QTR AND Convert(NVarchar(8),MonthYear,112) < @4TH_QTR THEN Convert(NVarchar, @3RD_QTR) + @ParamSep + Convert(NVarchar, @4TH_QTR)
        WHEN Convert(NVarchar(8),MonthYear,112) >= @4TH_QTR AND Convert(NVarchar(8),MonthYear,112) <= @4TH_QTR_END THEN Convert(NVarchar, @4TH_QTR) + @ParamSep + Convert(NVarchar, @5TH_QTR)
    END
    ,CASE 
        WHEN Convert(NVarchar(8),MonthYear,112) >= @1ST_QTR AND Convert(NVarchar(8),MonthYear,112) < @2ND_QTR THEN 'QTR 1'
        WHEN Convert(NVarchar(8),MonthYear,112) >= @2ND_QTR AND Convert(NVarchar(8),MonthYear,112) < @3RD_QTR THEN 'QTR 2'
        WHEN Convert(NVarchar(8),MonthYear,112) >= @3RD_QTR AND Convert(NVarchar(8),MonthYear,112) < @4TH_QTR THEN 'QTR 3'
        WHEN Convert(NVarchar(8),MonthYear,112) >= @4TH_QTR AND Convert(NVarchar(8),MonthYear,112) <= @4TH_QTR_END THEN 'QTR 4'
    END
    
    UNION ALL

   SELECT 
   "ITEM" = CASE 
        WHEN Convert(NVarchar(8),INVABS.InvoiceDate,112) >= @1ST_QTR AND Convert(NVarchar(8),INVABS.InvoiceDate,112) < @2ND_QTR THEN Convert(NVarchar, @1ST_QTR) + @ParamSep + Convert(NVarchar, @2ND_QTR)
        WHEN Convert(NVarchar(8),INVABS.InvoiceDate,112) >= @2ND_QTR AND Convert(NVarchar(8),INVABS.InvoiceDate,112) < @3RD_QTR THEN Convert(NVarchar, @2ND_QTR) + @ParamSep + Convert(NVarchar, @3RD_QTR)
        WHEN Convert(NVarchar(8),INVABS.InvoiceDate,112) >= @3RD_QTR AND Convert(NVarchar(8),INVABS.InvoiceDate,112) < @4TH_QTR THEN Convert(NVarchar, @3RD_QTR) + @ParamSep + Convert(NVarchar, @4TH_QTR)
        WHEN Convert(NVarchar(8),INVABS.InvoiceDate,112) >= @4TH_QTR AND Convert(NVarchar(8),INVABS.InvoiceDate,112) <= @4TH_QTR_END THEN Convert(NVarchar, @4TH_QTR) + @ParamSep + Convert(NVarchar, @5TH_QTR)
    END
    ,"Time" = CASE 
        WHEN Convert(NVarchar(8),INVABS.InvoiceDate,112) >= @1ST_QTR AND Convert(NVarchar(8),INVABS.InvoiceDate,112) < @2ND_QTR THEN 'QTR 1'
        WHEN Convert(NVarchar(8),INVABS.InvoiceDate,112) >= @2ND_QTR AND Convert(NVarchar(8),INVABS.InvoiceDate,112) < @3RD_QTR THEN 'QTR 2'
        WHEN Convert(NVarchar(8),INVABS.InvoiceDate,112) >= @3RD_QTR AND Convert(NVarchar(8),INVABS.InvoiceDate,112) < @4TH_QTR THEN 'QTR 3'
        WHEN Convert(NVarchar(8),INVABS.InvoiceDate,112) >= @4TH_QTR AND Convert(NVarchar(8),INVABS.InvoiceDate,112) <= @4TH_QTR_END THEN 'QTR 4'
    END
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
    AND (Convert(NVarchar(8),INVABS.InvoiceDate,112) BETWEEN @1ST_QTR AND @4TH_QTR_END)
    AND (IC.Category_Name In (Select Category_Name from #TmpCategory) OR @CategoryName = '%')
    AND (IsNull(IH.[HierarchyName],'') = @ProductHierarchy OR IsNull(@ProductHierarchy,'') = '%')
    GROUP BY 
    CASE 
        WHEN Convert(NVarchar(8),INVABS.InvoiceDate,112) >= @1ST_QTR AND Convert(NVarchar(8),INVABS.InvoiceDate,112) < @2ND_QTR THEN Convert(NVarchar, @1ST_QTR) + @ParamSep + Convert(NVarchar, @2ND_QTR)
        WHEN Convert(NVarchar(8),INVABS.InvoiceDate,112) >= @2ND_QTR AND Convert(NVarchar(8),INVABS.InvoiceDate,112) < @3RD_QTR THEN Convert(NVarchar, @2ND_QTR) + @ParamSep + Convert(NVarchar, @3RD_QTR)
        WHEN Convert(NVarchar(8),INVABS.InvoiceDate,112) >= @3RD_QTR AND Convert(NVarchar(8),INVABS.InvoiceDate,112) < @4TH_QTR THEN Convert(NVarchar, @3RD_QTR) + @ParamSep + Convert(NVarchar, @4TH_QTR)
        WHEN Convert(NVarchar(8),INVABS.InvoiceDate,112) >= @4TH_QTR AND Convert(NVarchar(8),INVABS.InvoiceDate,112) <= @4TH_QTR_END THEN Convert(NVarchar, @4TH_QTR) + @ParamSep + Convert(NVarchar, @5TH_QTR)
    END
    ,CASE 
        WHEN Convert(NVarchar(8),INVABS.InvoiceDate,112) >= @1ST_QTR AND Convert(NVarchar(8),INVABS.InvoiceDate,112) < @2ND_QTR THEN 'QTR 1'
        WHEN Convert(NVarchar(8),INVABS.InvoiceDate,112) >= @2ND_QTR AND Convert(NVarchar(8),INVABS.InvoiceDate,112) < @3RD_QTR THEN 'QTR 2'
        WHEN Convert(NVarchar(8),INVABS.InvoiceDate,112) >= @3RD_QTR AND Convert(NVarchar(8),INVABS.InvoiceDate,112) < @4TH_QTR THEN 'QTR 3'
        WHEN Convert(NVarchar(8),INVABS.InvoiceDate,112) >= @4TH_QTR AND Convert(NVarchar(8),INVABS.InvoiceDate,112) <= @4TH_QTR_END THEN 'QTR 4'
    END
   
   UNION ALL
   
   SELECT 
   "ITEM" = CASE 
        WHEN Convert(NVarchar(8),INVABS.ServiceInvoiceDate,112) >= @1ST_QTR AND Convert(NVarchar(8),INVABS.ServiceInvoiceDate,112) < @2ND_QTR THEN Convert(NVarchar, @1ST_QTR) + @ParamSep + Convert(NVarchar, @2ND_QTR)
        WHEN Convert(NVarchar(8),INVABS.ServiceInvoiceDate,112) >= @2ND_QTR AND Convert(NVarchar(8),INVABS.ServiceInvoiceDate,112) < @3RD_QTR THEN Convert(NVarchar, @2ND_QTR) + @ParamSep + Convert(NVarchar, @3RD_QTR)
        WHEN Convert(NVarchar(8),INVABS.ServiceInvoiceDate,112) >= @3RD_QTR AND Convert(NVarchar(8),INVABS.ServiceInvoiceDate,112) < @4TH_QTR THEN Convert(NVarchar, @3RD_QTR) + @ParamSep + Convert(NVarchar, @4TH_QTR)
        WHEN Convert(NVarchar(8),INVABS.ServiceInvoiceDate,112) >= @4TH_QTR AND Convert(NVarchar(8),INVABS.ServiceInvoiceDate,112) <= @4TH_QTR_END THEN Convert(NVarchar, @4TH_QTR) + @ParamSep + Convert(NVarchar, @5TH_QTR)
    END
    ,"Time" = CASE 
        WHEN Convert(NVarchar(8),INVABS.ServiceInvoiceDate,112) >= @1ST_QTR AND Convert(NVarchar(8),INVABS.ServiceInvoiceDate,112) < @2ND_QTR THEN 'QTR 1'
        WHEN Convert(NVarchar(8),INVABS.ServiceInvoiceDate,112) >= @2ND_QTR AND Convert(NVarchar(8),INVABS.ServiceInvoiceDate,112) < @3RD_QTR THEN 'QTR 2'
        WHEN Convert(NVarchar(8),INVABS.ServiceInvoiceDate,112) >= @3RD_QTR AND Convert(NVarchar(8),INVABS.ServiceInvoiceDate,112) < @4TH_QTR THEN 'QTR 3'
        WHEN Convert(NVarchar(8),INVABS.ServiceInvoiceDate,112) >= @4TH_QTR AND Convert(NVarchar(8),INVABS.ServiceInvoiceDate,112) <= @4TH_QTR_END THEN 'QTR 4'
    END
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
    AND (Convert(NVarchar(8),INVABS.ServiceInvoiceDate,112) BETWEEN @1ST_QTR AND @4TH_QTR_END)
    AND (IC.Category_Name In (Select Category_Name from #TmpCategory) OR @CategoryName = '%')
    AND (IsNull(IH.[HierarchyName],'') = @ProductHierarchy OR IsNull(@ProductHierarchy,'') = '%')
    AND IsNull(INVDET.SpareCode, '') <> ''
    GROUP BY 
    CASE 
        WHEN Convert(NVarchar(8),INVABS.ServiceInvoiceDate,112) >= @1ST_QTR AND Convert(NVarchar(8),INVABS.ServiceInvoiceDate,112) < @2ND_QTR THEN Convert(NVarchar, @1ST_QTR) + @ParamSep + Convert(NVarchar, @2ND_QTR)
        WHEN Convert(NVarchar(8),INVABS.ServiceInvoiceDate,112) >= @2ND_QTR AND Convert(NVarchar(8),INVABS.ServiceInvoiceDate,112) < @3RD_QTR THEN Convert(NVarchar, @2ND_QTR) + @ParamSep + Convert(NVarchar, @3RD_QTR)
        WHEN Convert(NVarchar(8),INVABS.ServiceInvoiceDate,112) >= @3RD_QTR AND Convert(NVarchar(8),INVABS.ServiceInvoiceDate,112) < @4TH_QTR THEN Convert(NVarchar, @3RD_QTR) + @ParamSep + Convert(NVarchar, @4TH_QTR)
        WHEN Convert(NVarchar(8),INVABS.ServiceInvoiceDate,112) >= @4TH_QTR AND Convert(NVarchar(8),INVABS.ServiceInvoiceDate,112) <= @4TH_QTR_END THEN Convert(NVarchar, @4TH_QTR) + @ParamSep + Convert(NVarchar, @5TH_QTR)
    END
    ,CASE 
        WHEN Convert(NVarchar(8),INVABS.ServiceInvoiceDate,112) >= @1ST_QTR AND Convert(NVarchar(8),INVABS.ServiceInvoiceDate,112) < @2ND_QTR THEN 'QTR 1'
        WHEN Convert(NVarchar(8),INVABS.ServiceInvoiceDate,112) >= @2ND_QTR AND Convert(NVarchar(8),INVABS.ServiceInvoiceDate,112) < @3RD_QTR THEN 'QTR 2'
        WHEN Convert(NVarchar(8),INVABS.ServiceInvoiceDate,112) >= @3RD_QTR AND Convert(NVarchar(8),INVABS.ServiceInvoiceDate,112) < @4TH_QTR THEN 'QTR 3'
        WHEN Convert(NVarchar(8),INVABS.ServiceInvoiceDate,112) >= @4TH_QTR AND Convert(NVarchar(8),INVABS.ServiceInvoiceDate,112) <= @4TH_QTR_END THEN 'QTR 4'
    END
) RS
GROUP BY RS.[Time],RS.[ITEM]
HAVING (Sum(TargetValue) <> 0 OR Sum(ActualValue)  <> 0  OR
Sum(TargetVolume) <> 0  OR Sum(ActualVolume)  <> 0)
DROP Table #TmpCategory            
              
