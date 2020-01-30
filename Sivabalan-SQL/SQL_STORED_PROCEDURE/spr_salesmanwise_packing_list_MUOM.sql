CREATE PROCEDURE spr_salesmanwise_packing_list_MUOM (@SALESMAN nvarchar(256), @FROMDATE datetime, @TODATE datetime)        
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
TotalQty Decimal(18,6),Uom2Qty Decimal(18,6), Uom2Desc nvarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS,Uom1Qty Decimal(18,6),  
 Uom1Desc nvarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS,UomQty Decimal(18,6), UomDesc nvarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS)        
      
Insert into #Temp (ItemCode,ProductName,Batch_Number,TotalQty, SalePrice, MRP)    
Select InvoiceDetail.Product_Code, Items.ProductName,        
 Batch_Number, "TotalQty" = Sum(Quantity), SalePrice, InvoiceDetail.MRP  
From InvoiceDetail, InvoiceAbstract, Items        
Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID And        
 InvoiceDetail.Product_code = Items.Product_Code And        
 (InvoiceAbstract.Status & 128) = 0 And         
 InvoiceAbstract.InvoiceDate Between @FROMDATE And @TODATE And        
 InvoiceAbstract.SalesmanID = @SALESMANID And        
 InvoiceType In (1, 3) And DocumentID Between dbo.GetTrueVal(@FROMNO) And dbo.GetTrueVal(@TONO)        
        
Group By InvoiceDetail.Product_Code, Items.ProductName, Batch_Number, SalePrice, InvoiceDetail.MRP  
Order by InvoiceDetail.Product_Code        
  
update #temp   
  
set UOM2Qty = dbo.GetFirstLevelUOMQty(ItemCode, TotalQty),  
UOM2Desc = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM2 from Items Where Items.Product_Code =  ItemCode )),    
  
UOM1Qty = dbo.GetSecondLevelUOMQty(ItemCode, TotalQty),    
UOM1Desc = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM1 from Items Where Items.Product_Code =  ItemCode )),    
  
UOMQty = dbo.GetLastLevelUOMQty(ItemCode, TotalQty),    
UOMDesc = (Select UOM.Description from UOM Where UOM.UOM in( Select UOM from Items Where Items.Product_Code =  ItemCode ))    
  
Select * from #Temp        
      
End     
  
