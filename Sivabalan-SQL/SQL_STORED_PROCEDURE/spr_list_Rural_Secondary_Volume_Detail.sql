CREATE procedure [dbo].[spr_list_Rural_Secondary_Volume_Detail]      
(       
@Classification Integer,      
@From_Date DateTime,       
@To_Date DateTime,       
@UOM nvarchar(256)      
 )      
AS      
      
Create Table #SalesTemp (Temp_Prod_Code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Prod_Code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Qty Decimal(18,6), Value Decimal(18,6))       
      
If @Classification = 1       
Begin      
  If @UOM = 'Sales UOM' or @UOM = 'Reporting UOM'      
 insert into #SalesTemp (Temp_Prod_Code ,Prod_Code ,Qty , Value)       

 (select InvoiceDetail.Product_Code, "Item Code" = InvoiceDetail.Product_Code,         
 "Volume" = Sum(-1 * Isnull(InvoiceDetail.Quantity, 0)),        
 "Value" = Sum(-1 * isnull(InvoiceDetail.Amount, 0))        
 from InvoiceAbstract,InvoiceDetail, Customer, Batch_products        
 Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID         
 and InvoiceDetail.Batch_Code = Batch_Products.Batch_Code
 and Isnull(Damage, 0) = 0
 and Customer.CustomerID = InvoiceAbstract.CustomerID         
 and InvoiceDate between @From_Date and @To_Date       
 and Customer.TownClassify = 1        
 and Isnull(Status & 192,0) = 0         
 and InvoiceType in (4)      
 Group by InvoiceDetail.Product_Code)     
 Union      
 (select DispatchDetail.Product_Code,         
 "Item Code" = DispatchDetail.Product_Code,         
 "Volume" = Sum(Isnull(DispatchDetail.Quantity, 0)),        
 "Value" = Sum(Isnull(DispatchDetail.Quantity * DispatchDetail.SalePrice, 0))      
 from DispatchAbstract,DispatchDetail, Customer        
 Where DispatchAbstract.DispatchID = DispatchDetail.DispatchID         
 and Customer.CustomerID = DispatchAbstract.CustomerID         
 and DispatchDate between @From_Date and @To_Date        
 and Customer.TownClassify = 1      
 and Isnull(Status & 64,0) = 0        
 Group by DispatchDetail.Product_Code)      
 Else If @UOM = 'Conversion Factor'       
 insert into #SalesTemp (Temp_Prod_Code ,Prod_Code ,Qty , Value)       
 (select InvoiceDetail.Product_Code, "Item Code" = InvoiceDetail.Product_Code,         
 "Volume" = Sum((-1 * Isnull(InvoiceDetail.Quantity, 0)) * CASE IsNull(Items.ConversionFactor,0) WHEN 0 THEN 1 ELSE IsNull(Items.ConversionFactor,0) END),        
 "Value" = Sum(-1 * isnull(InvoiceDetail.Amount, 0))        
 from InvoiceAbstract,InvoiceDetail, Customer, Batch_products, Items        
 Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID         
 and InvoiceDetail.Batch_Code = Batch_Products.Batch_Code
 and InvoiceDetail.product_Code = Items.Product_Code  
 and Isnull(Damage, 0) = 0
 and Customer.CustomerID = InvoiceAbstract.CustomerID         
 and InvoiceDate between @From_Date and @To_Date       
 and Customer.TownClassify = 1        
 and Isnull(Status & 192,0) = 0         
 and InvoiceType in (4)      
 Group by InvoiceDetail.Product_Code)      
 Union      
 (select DispatchDetail.Product_Code,         
 "Item Code" = DispatchDetail.Product_Code,         
 "Volume" = Sum(Isnull(DispatchDetail.Quantity, 0)  * CASE IsNull(Items.ConversionFactor,0) WHEN 0 THEN 1 ELSE IsNull(Items.ConversionFactor,0) END),        
 "Value" = Sum(Isnull(DispatchDetail.Quantity * DispatchDetail.SalePrice, 0))      
 from DispatchAbstract,DispatchDetail, Customer, Items       
 Where DispatchAbstract.DispatchID = DispatchDetail.DispatchID         
 and DispatchDetail.product_Code = Items.Product_Code      
 and Customer.CustomerID = DispatchAbstract.CustomerID         
 and DispatchDate between @From_Date and @To_Date        
 and Customer.TownClassify = 1      
 and Isnull(Status & 64,0) = 0        
 Group by DispatchDetail.Product_Code)      
End      
Else If @Classification = 2      
Begin      
  If @UOM = 'Sales UOM' or @UOM = 'Reporting UOM'      
 insert into #SalesTemp (Temp_Prod_Code ,Prod_Code ,Qty , Value)       
 (select InvoiceDetail.Product_Code, "Item Code" = InvoiceDetail.Product_Code,         
 "Volume" = Sum(-1 * Isnull(InvoiceDetail.Quantity, 0)),        
 "Value" = Sum(-1 * isnull(InvoiceDetail.Amount, 0))        
 from InvoiceAbstract,InvoiceDetail, Customer, Batch_products        
 Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID         
 and InvoiceDetail.Batch_Code = Batch_Products.Batch_Code
 and Isnull(Damage, 0) = 0
 and Customer.CustomerID = InvoiceAbstract.CustomerID         
 and InvoiceDate between @From_Date and @To_Date       
 and Customer.TownClassify = 2        
 and Isnull(Status & 192,0) = 0         
 and InvoiceType in (4)      
 Group by InvoiceDetail.Product_Code)      
 Union      
 (select DispatchDetail.Product_Code,         
 "Item Code" = DispatchDetail.Product_Code,         
 "Volume" = Sum(Isnull(DispatchDetail.Quantity, 0)),        
 "Value" = Sum(Isnull(DispatchDetail.Quantity * DispatchDetail.SalePrice, 0))      
 from DispatchAbstract,DispatchDetail, Customer        
 Where DispatchAbstract.DispatchID = DispatchDetail.DispatchID         
 and Customer.CustomerID = DispatchAbstract.CustomerID         
 and DispatchDate between @From_Date and @To_Date        
 and Customer.TownClassify = 2      
 and Isnull(Status & 64,0) = 0        
 Group by DispatchDetail.Product_Code)      
 Else If @UOM = 'Conversion Factor'       
 insert into #SalesTemp (Temp_Prod_Code ,Prod_Code ,Qty , Value)       
 (select InvoiceDetail.Product_Code, "Item Code" = InvoiceDetail.Product_Code,         
 "Volume" = Sum((-1 * Isnull(InvoiceDetail.Quantity, 0)) * CASE IsNull(Items.ConversionFactor,0) WHEN 0 THEN 1 ELSE IsNull(Items.ConversionFactor,0) END),        
 "Value" = Sum(-1 * isnull(InvoiceDetail.Amount, 0))        
 from InvoiceAbstract,InvoiceDetail, Customer, Batch_products, items        
 Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID         
 and InvoiceDetail.Batch_Code = Batch_Products.Batch_Code
 and Isnull(Damage, 0) = 0
 and Customer.CustomerID = InvoiceAbstract.CustomerID       
 and InvoiceDetail.product_Code = Items.Product_Code    
 and InvoiceDate between @From_Date and @To_Date       
 and Customer.TownClassify = 2        
 and Isnull(Status & 192,0) = 0         
 and InvoiceType in (4)      
 Group by InvoiceDetail.Product_Code)    
 Union      
 (select DispatchDetail.Product_Code,         
 "Item Code" = DispatchDetail.Product_Code,         
 "Volume" = Sum(Isnull(DispatchDetail.Quantity, 0)  * CASE IsNull(Items.ConversionFactor,0) WHEN 0 THEN 1 ELSE IsNull(Items.ConversionFactor,0) END),        
 "Value" = Sum(Isnull(DispatchDetail.Quantity * DispatchDetail.SalePrice, 0))      
 from DispatchAbstract,DispatchDetail, Customer, Items       
 Where DispatchAbstract.DispatchID = DispatchDetail.DispatchID         
 and DispatchDetail.product_Code = Items.Product_Code      
 and Customer.CustomerID = DispatchAbstract.CustomerID         
 and DispatchDate between @From_Date and @To_Date        
 and Customer.TownClassify = 2      
 and Isnull(Status & 64,0) = 0        
 Group by DispatchDetail.Product_Code)      
End      
Else If @Classification = 3      
Begin      
  If @UOM = 'Sales UOM' or @UOM = 'Reporting UOM'      
 insert into #SalesTemp (Temp_Prod_Code ,Prod_Code ,Qty , Value)       
 (select InvoiceDetail.Product_Code, "Item Code" = InvoiceDetail.Product_Code,         
 "Volume" = Sum(-1 * Isnull(InvoiceDetail.Quantity, 0)),        
 "Value" = Sum(-1 * isnull(InvoiceDetail.Amount, 0))        
 from InvoiceAbstract,InvoiceDetail, Customer, Batch_products        
 Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID         
 and InvoiceDetail.Batch_Code = Batch_Products.Batch_Code
 and Isnull(Damage, 0) = 0
 and Customer.CustomerID = InvoiceAbstract.CustomerID         
 and InvoiceDate between @From_Date and @To_Date       
 and Customer.TownClassify = 3        
 and Isnull(Status & 192,0) = 0         
 and InvoiceType in (4)      
 Group by InvoiceDetail.Product_Code)     
 Union      
 (select DispatchDetail.Product_Code,         
 "Item Code" = DispatchDetail.Product_Code,         
 "Volume" = Sum(Isnull(DispatchDetail.Quantity, 0)),        
 "Value" = Sum(Isnull(DispatchDetail.Quantity * DispatchDetail.SalePrice, 0))      
 from DispatchAbstract,DispatchDetail, Customer       
 Where DispatchAbstract.DispatchID = DispatchDetail.DispatchID         
 and Customer.CustomerID = DispatchAbstract.CustomerID         
 and DispatchDate between @From_Date and @To_Date        
 and Customer.TownClassify = 3      
 and Isnull(Status & 64,0) = 0        
 Group by DispatchDetail.Product_Code)      
 Else If @UOM = 'Conversion Factor'       
 insert into #SalesTemp (Temp_Prod_Code ,Prod_Code ,Qty , Value)       
 (select InvoiceDetail.Product_Code, "Item Code" = InvoiceDetail.Product_Code,         
 "Volume" = Sum((-1 * Isnull(InvoiceDetail.Quantity, 0)) * CASE IsNull(Items.ConversionFactor,0) WHEN 0 THEN 1 ELSE IsNull(Items.ConversionFactor,0) END),        
 "Value" = Sum(-1 * isnull(InvoiceDetail.Amount, 0))        
 from InvoiceAbstract,InvoiceDetail, Customer, Batch_products, Items        
 Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID         
 and InvoiceDetail.Batch_Code = Batch_Products.Batch_Code
 and InvoiceDetail.product_Code = Items.Product_Code  
 and Isnull(Damage, 0) = 0
 and Customer.CustomerID = InvoiceAbstract.CustomerID         
 and InvoiceDate between @From_Date and @To_Date       
 and Customer.TownClassify = 3        
 and Isnull(Status & 192,0) = 0         
 and InvoiceType in (4)      
 Group by InvoiceDetail.Product_Code)       
 Union      
 (select DispatchDetail.Product_Code,         
 "Item Code" = DispatchDetail.Product_Code,         
 "Volume" = Sum(Isnull(DispatchDetail.Quantity, 0)  * CASE IsNull(Items.ConversionFactor,0) WHEN 0 THEN 1 ELSE IsNull(Items.ConversionFactor,0) END),        
 "Value" = Sum(Isnull(DispatchDetail.Quantity * DispatchDetail.SalePrice, 0))      
 from DispatchAbstract,DispatchDetail, Customer, Items       
 Where DispatchAbstract.DispatchID = DispatchDetail.DispatchID         
 and DispatchDetail.product_Code = Items.Product_Code      
 and Customer.CustomerID = DispatchAbstract.CustomerID         
 and DispatchDate between @From_Date and @To_Date        
 and Customer.TownClassify = 3      
 and Isnull(Status & 64,0) = 0        
 Group by DispatchDetail.Product_Code)      
End      
Else If @Classification = 4      
Begin      
  If @UOM = 'Sales UOM' or @UOM = 'Reporting UOM'      
 insert into #SalesTemp (Temp_Prod_Code ,Prod_Code ,Qty , Value)       
 (select InvoiceDetail.Product_Code, "Item Code" = InvoiceDetail.Product_Code,         
 "Volume" = Sum(-1 * Isnull(InvoiceDetail.Quantity, 0)),        
 "Value" = Sum(-1 * isnull(InvoiceDetail.Amount, 0))        
 from InvoiceAbstract,InvoiceDetail, Customer, Batch_products        
 Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID         
 and InvoiceDetail.Batch_Code = Batch_Products.Batch_Code
 and Isnull(Damage, 0) = 0
 and Customer.CustomerID = InvoiceAbstract.CustomerID         
 and InvoiceDate between @From_Date and @To_Date       
 and Customer.TownClassify = 4        
 and Isnull(Status & 192,0) = 0         
 and InvoiceType in (4)      
 Group by InvoiceDetail.Product_Code)     
 Union      
 (select DispatchDetail.Product_Code,         
 "Item Code" = DispatchDetail.Product_Code,         
 "Volume" = Sum(Isnull(DispatchDetail.Quantity, 0)),        
 "Value" = Sum(Isnull(DispatchDetail.Quantity * DispatchDetail.SalePrice, 0))      
 from DispatchAbstract,DispatchDetail, Customer        
 Where DispatchAbstract.DispatchID = DispatchDetail.DispatchID         
 and Customer.CustomerID = DispatchAbstract.CustomerID         
 and DispatchDate between @From_Date and @To_Date        
 and Customer.TownClassify = 4      
 and Isnull(Status & 64,0) = 0        
 Group by DispatchDetail.Product_Code)      
 Else If @UOM = 'Conversion Factor'       
 insert into #SalesTemp (Temp_Prod_Code ,Prod_Code ,Qty , Value)       
 (select InvoiceDetail.Product_Code, "Item Code" = InvoiceDetail.Product_Code,         
 "Volume" = Sum((-1 * Isnull(InvoiceDetail.Quantity, 0)) * CASE IsNull(Items.ConversionFactor,0) WHEN 0 THEN 1 ELSE IsNull(Items.ConversionFactor,0) END),        
 "Value" = Sum(-1 * isnull(InvoiceDetail.Amount, 0))        
 from InvoiceAbstract,InvoiceDetail, Customer, Batch_products, Items        
 Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID         
 and InvoiceDetail.Batch_Code = Batch_Products.Batch_Code
 and InvoiceDetail.product_Code = Items.Product_Code  
 and Isnull(Damage, 0) = 0
 and Customer.CustomerID = InvoiceAbstract.CustomerID         
 and InvoiceDate between @From_Date and @To_Date       
 and Customer.TownClassify = 4        
 and Isnull(Status & 192,0) = 0         
 and InvoiceType in (4)      
 Group by InvoiceDetail.Product_Code)       
 Union      
 (select DispatchDetail.Product_Code,         
 "Item Code" = DispatchDetail.Product_Code,         
 "Volume" = Sum(Isnull(DispatchDetail.Quantity, 0)  * CASE IsNull(Items.ConversionFactor,0) WHEN 0 THEN 1 ELSE IsNull(Items.ConversionFactor,0) END),        
 "Value" = Sum(Isnull(DispatchDetail.Quantity * DispatchDetail.SalePrice, 0))      
 from DispatchAbstract,DispatchDetail, Customer, Items       
 Where DispatchAbstract.DispatchID = DispatchDetail.DispatchID         
 and DispatchDetail.product_Code = Items.Product_Code      
 and Customer.CustomerID = DispatchAbstract.CustomerID         
 and DispatchDate between @From_Date and @To_Date        
 and Customer.TownClassify = 4      
 and Isnull(Status & 64,0) = 0        
 Group by DispatchDetail.Product_Code)      
End      
    
if @UOM = 'Reporting UOM'       
 Select "Temp Item Code" = Temp_Prod_Code, "Item Code" = Prod_Code, "Volume" = dbo.sp_Get_ReportingUOMQty(Prod_Code, Sum(Qty)), "Value" = Sum(Value)      
 from #SalesTemp     
 Group by Temp_Prod_Code, Prod_Code       
Else If @UOM = 'Sales UOM'      
 Select "Temp Item Code" = Temp_Prod_Code, "Item Code" = Prod_Code, "Volume" = Cast(Sum(Qty) as nvarchar) , "Value" = Sum(Value)     
 from #SalesTemp, Items, UOM    
 Where Items.UOM = UOM.UOM    
 and #SalesTemp.Prod_Code = Items.Product_Code    
 Group by Temp_Prod_Code, Prod_Code, UOM.Description    
Else If @UOM = 'Conversion Factor'    
 Select "Temp Item Code" = Temp_Prod_Code, "Item Code" = Prod_Code, "Volume" = Cast(Sum(Qty) as nvarchar), "Value" = Sum(Value)     
 from #SalesTemp, Items, ConversionTable    
 Where Items.ConversionUnit *= ConversionTable.ConversionID    
 and #SalesTemp.Prod_Code = Items.Product_Code    
 Group by Temp_Prod_Code, Prod_Code, ConversionTable.ConversionUnit    
      
Drop Table #SalesTemp
