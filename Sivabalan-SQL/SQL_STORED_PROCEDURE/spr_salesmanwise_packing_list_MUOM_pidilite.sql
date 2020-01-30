CREATE PROCEDURE spr_salesmanwise_packing_list_MUOM_pidilite (@SALESMAN nvarchar(256),      
             @FROMDATE datetime,      
      @TODATE datetime)      
AS      
Begin    
      
DECLARE @SALESMANID int      
DECLARE @FROMNO nvarchar(16)      
DECLARE @TONO nvarchar(16)      
DECLARE @INDEX1 int      
DECLARE @INDEX2 int      
      
SET @INDEX1 = charindex(N';', @SALESMAN)      
SET @INDEX2 = charindex(N';', @SALESMAN, @INDEX1 + 1)      
      
set @SALESMANID = cast(substring(@SALESMAN, 1, @INDEX1-1) as int)      
set @FROMNO = substring(@SALESMAN, @INDEX1+1, @INDEX2-1-@INDEX1)      
set @TONO = substring(@SALESMAN, @INDEX2+1, 100)      
    
Create Table #Temp(ItemCode nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,ProductName nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,Batch_Number nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
SalePrice Decimal(18,6), MRP Decimal(18,6),
TotalQty Decimal(18,6), [Reporting UOM] Decimal (18, 6), 
[Conversion Factor] Decimal (18, 6), Uom2Qty Decimal(18,6), Uom2Desc nvarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS,Uom1Qty Decimal(18,6),
Uom1Desc nvarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS,UomQty Decimal(18,6), UomDesc nvarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS)      



    
Insert into #Temp (ItemCode,ProductName,Batch_Number,TotalQty, [Reporting UOM], [Conversion Factor], SalePrice, MRP)  
Select InvoiceDetail.Product_Code, Items.ProductName,      
 Batch_Number, "TotalQty" = Sum(Quantity), 
 "Reporting UOM" = Sum(Quantity / Case IsNull(ReportingUnit, 1) When 0 Then 1 Else IsNull(ReportingUnit, 1) End),
 "Conversion Factor" = Sum(Quantity * IsNull(ConversionFactor, 0)),
SalePrice, InvoiceDetail.MRP
From InvoiceDetail, InvoiceAbstract, Items      
Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And      
 InvoiceDetail.Product_code = Items.Product_Code And      
 (InvoiceAbstract.Status & 128) = 0 And       
 InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE And      
 InvoiceAbstract.SalesmanID = @SALESMANID And      
 InvoiceType In (1, 3) And DocumentID Between dbo.GetTrueVal(@FROMNO) And dbo.GetTrueVal(@TONO)      
      
Group By InvoiceDetail.Product_Code, Items.ProductName, Batch_Number, SalePrice, InvoiceDetail.MRP
Order by InvoiceDetail.Product_Code      
   
declare @ItemCode nvarchar(50)    
declare @Qty Decimal(18,6)    
Declare @SQL nvarchar(255)   
Declare @UOM2Qty Decimal(18,6)  
Declare @UOM1Qty Decimal(18,6)  
Declare @UOMQty Decimal(18,6)  
  
Declare @UOM2Desc nvarchar(15)  
Declare @UOM1Desc nvarchar(15)  
Declare @UOMDesc nvarchar(15)  
    
declare UOMCursor Cursor for select ItemCode,TotalQty from #Temp    
Open UOMCursor    
Fetch from UOMCursor into @ItemCode,@Qty  
While @@Fetch_status = 0    
Begin     
  
Set @UOM2Qty = dbo.GetFirstLevelUOMQty(@ItemCode, @Qty)  
Set @UOM2Desc = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM2 from Items Where Items.Product_Code =  @ItemCode ))  
Set @UOM1Qty = dbo.GetSecondLevelUOMQty(@ItemCode, @Qty)  
Set @UOM1Desc = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM1 from Items Where Items.Product_Code =  @ItemCode ))  
Set @UOMQty = dbo.GetLastLevelUOMQty(@ItemCode, @Qty)  
Set @UOMDesc = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM from Items Where Items.Product_Code =  @ItemCode ))  
  
set @sql = N'update #Temp Set UOM2Qty = ' + Cast(@UOM2Qty As nvarchar) + N',UOM2Desc = ''' + @UOM2Desc + '''  where ItemCode = ''' + @ItemCode + ''''    
Exec sp_Executesql @SQL    
  
set @sql = N'update #Temp Set UOM1Qty = ' + Cast(@UOM1Qty As nvarchar) + ',UOM1Desc = ''' + @UOM1Desc + '''  where ItemCode = ''' + @ItemCode + ''''    
Exec sp_Executesql @SQL   
  
set @sql = N'update #Temp Set UOMQty = ' + Cast(@UOMQty As nvarchar) + ',UOMDesc = ''' + @UOMDesc + '''  where ItemCode = ''' + @ItemCode + ''''    
Exec sp_Executesql @SQL   
  
Fetch Next from UOMCursor into @ItemCode,@Qty  
End    
close UOMCursor    
deallocate UOMCursor      
    
Select * from #Temp      
    
End   


