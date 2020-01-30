Create Procedure Spr_list_SKULedger_Abstract_GSK(@FromDate Datetime,@ToDate DateTime,@ItemName nvarchar(2550))  
as  
begin  
declare @CORRECTED_DATE as datetime  
declare @NEXT_DATE as datetime  
declare @FDATE as datetime  
SET DATEFORMAT DMY  
SET @CORRECTED_DATE = CAST(DATEPART(dd, @TODATE) AS nvarchar) + '/' + CAST(DATEPART(mm, @TODATE) as nvarchar) + '/' + cast(DATEPART(yyyy, @TODATE) AS nVarChar)    
SET  @NEXT_DATE = CAST(DATEPART(dd, dbo.Fn_GetOperartingDate(GETDATE())) AS nvarchar) + '/'     
+ CAST(DATEPART(mm, dbo.Fn_GetOperartingDate(GETDATE())) as nvarchar) + '/'     
+ cast(DATEPART(yyyy, dbo.Fn_GetOperartingDate(GETDATE())) AS nvarchar)    
Set @FDATE = CAST(DATEPART(dd, @FROMDATE) AS nvarchar) + '/' + CAST(DATEPART(mm, @FROMDATE) as nvarchar) + '/' + cast(DATEPART(yyyy, @FROMDATE) AS nvarchar)    
Declare @Delimeter as Char(1)                                                
Set @Delimeter=Char(15)                                               

Declare @tmpSch Table(ProductName NVarchar(255)COLLATE SQL_Latin1_General_CP1_CI_AS)              
                                              
If @ItemName='%'                                                 
   Insert into @tmpSch select ProductName from Items                                                
Else                                                
   Insert into @tmpSch select * from dbo.sp_SplitIn2Rows(@ItemName,@Delimeter)   
 
Declare @temp1 Table([ProductCode] nVarChar(255), [Item Code] nVarChar(255),    
[Total Opening] Decimal(18, 6), [Receipt] Decimal(18, 6), [Sales] Decimal(18, 6),  
 [Other Disposal] Decimal(18, 6), [Closing Stock] Decimal(18, 6))  
  
insert into @temp1 select [Item Code],  
"Item Code" = [Item Code],  
"Total Opening" = [Opening Stock],  
"Receipt" = [Purchase],  
"Sales" = [Sales],  
"Other Disposal" = ([Closing Stock] - ([Opening Stock] + [Purchase] - [Sales])),  
"Closing Stock" = [Closing Stock]  
  
from   
  
(Select  "Item Code" = its.Product_Code,     
    
  "Opening Stock" = IsNull((Select IsNull(Opening_Quantity, 0) - IsNull(Damage_Opening_Quantity, 0)    
    From OpeningDetails Where Product_Code = its.Product_Code And Opening_Date = @FromDate), 0),    
    
  "Purchase" = IsNull((Select Sum(IsNull(QuantityReceived, 0) + IsNull(FreeQty, 0) - IsNull(QuantityRejected, 0)) From     
    GRNAbstract ga, GRNDetail gd Where ga.GRNID = gd.GRNID And GRNDate Between @FromDate And    
    @ToDate And Product_Code = its.Product_Code And IsNull(GRNStatus, 0) & 96 = 0), 0) -     
    
    IsNull((Select Sum(IsNull(Quantity, 0)) From AdjustmentReturnAbstract ara, AdjustmentReturnDetail ard Where    
    ara.AdjustmentID = ard.AdjustmentID And AdjustmentDate Between @FromDate And @ToDate And     
    IsNull(Status, 0) & 192 = 0 And Product_Code = its.Product_Code), 0),    
    
  "Sales" = IsNull((Select Sum(Case InvoiceType When 4 Then -1 Else 1 End * Quantity)     
    From InvoiceAbstract inv, InvoiceDetail invd Where inv.InvoiceID = invd.InvoiceID    
    And Product_Code = its.Product_Code And InvoiceDate Between @FromDate And @ToDate     
    And IsNull(Status, 0) & 192 = 0 And Case InvoiceType When 4 Then IsNull(Status, 0) & 32 Else 0 End = 0), 0) +    
    
    IsNull((Select Sum(IsNull(Quantity, 0)) From DispatchAbstract da, DispatchDetail dd Where     
    da.DispatchID = dd.DispatchID And DispatchDate Between @FromDate And @ToDate And     
    dd.Product_Code = its.Product_Code And IsNull(da.Status, 0) & 192 = 0), 0),  
  
   "Closing Stock" = dbo.OnHandQ(@CORRECTED_DATE, @NEXT_DATE, its.Product_Code)  
  
 From Items its  Where Product_Code in( select Product_Code  From Items Where ProductName in (Select ProductName From @tmpsch)))#tmp1  
   
select * from @temp1  
end   




