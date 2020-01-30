CREATE procedure [dbo].[spr_list_Townwise_Secondary_Sales_Detail]  
(   
@CityID Integer,  
@From_Date DateTime,   
@To_Date DateTime,  
@UOM nvarchar(256)  
 )  
AS  

Create Table #SalesTemp (Temp_Prod_Code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Prod_Code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, Qty Decimal(18,6), Value Decimal(18,6)) 

If @UOM = N'Sales UOM' or @UOM = N'Reporting UOM'
insert into #SalesTemp (Temp_Prod_Code ,Prod_Code ,Qty , Value) 
 (select InvoiceDetail.Product_Code,   
 "Item Code" = InvoiceDetail.Product_Code,   
 "Secondary Sales Volume" = Sum(-1 * Isnull(InvoiceDetail.Quantity, 0)),  
 "Value" = Sum(-1 * isnull(InvoiceDetail.Amount, 0)) 
 from InvoiceAbstract,InvoiceDetail, Customer, Batch_Products 
 Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID   
 and Customer.CustomerID = InvoiceAbstract.CustomerID   
 and InvoiceDate between @From_Date and @To_Date
 and Batch_Products.Batch_Code = InvoiceDetail.Batch_Code
 and Isnull(Damage, 0) = 0 
 and Customer.CityID = @CityID  
 and Isnull(Status & 192,0) = 0   
 and InvoiceType in (4)
 Group by InvoiceDetail.Product_Code)
 Union 
 (select DispatchDetail.Product_Code,   
 "Item Code" = DispatchDetail.Product_Code,   
 "Secondary Sales Volume" = Sum(Isnull(DispatchDetail.Quantity, 0)),  
 "Value" = Sum(Isnull(DispatchDetail.Quantity * DispatchDetail.SalePrice, 0))
 from DispatchAbstract,DispatchDetail, Customer  
 Where DispatchAbstract.DispatchID = DispatchDetail.DispatchID   
 and Customer.CustomerID = DispatchAbstract.CustomerID   
 and DispatchDate between @From_Date and @To_Date  
 and Customer.CityID = @CityID  
 and Isnull(Status & 64,0) = 0  
 Group by DispatchDetail.Product_Code)


Else If @UOM = N'Conversion Factor'  
insert into #SalesTemp (Temp_Prod_Code ,Prod_Code ,Qty , Value) 
 (select InvoiceDetail.Product_Code,   
 "Item Code" = InvoiceDetail.Product_Code,   
 "Secondary Sales Volume" = Cast(Sum(-1 * Isnull(InvoiceDetail.Quantity, 0) * CASE IsNull(Items.ConversionFactor,0) WHEN 0 THEN 1 ELSE IsNull(Items.ConversionFactor,0) END) as Decimal(18,6)),    
 "Value" = Sum(-1 * Isnull(InvoiceDetail.Amount, 0)) 
 from InvoiceAbstract,InvoiceDetail, Customer, Items, Batch_Products  
 Where InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID   
 and InvoiceDetail.Product_Code = Items.Product_Code
 and Customer.CustomerID = InvoiceAbstract.CustomerID   
 and InvoiceDate between @From_Date and @To_Date  
 and Batch_Products.Batch_Code = InvoiceDetail.Batch_Code
 and Isnull(Damage, 0) = 0 
 and Customer.CityID = @CityID  
 and Isnull(Status & 192,0) = 0   
 and InvoiceType in (4)
 Group by InvoiceDetail.Product_Code)
 Union 
 (select DispatchDetail.Product_Code,   
 "Item Code" = DispatchDetail.Product_Code,   
 "Secondary Sales Volume" = Cast(Sum(Isnull(DispatchDetail.Quantity, 0)  * CASE IsNull(Items.ConversionFactor,0) WHEN 0 THEN 1 ELSE IsNull(Items.ConversionFactor,0) END) as Decimal(18,6)),    
 "Value" = Sum(Isnull(DispatchDetail.Quantity * DispatchDetail.SalePrice, 0)) 
 from DispatchAbstract,DispatchDetail, Customer, Items  
 Where DispatchAbstract.DispatchID = DispatchDetail.DispatchID   
 and Customer.CustomerID = DispatchAbstract.CustomerID   
 and DispatchDetail.Product_Code = Items.Product_Code
 and DispatchDate between @From_Date and @To_Date  
 and Customer.CityID = @CityID  
 and Isnull(Status & 64,0) = 0  
 Group by DispatchDetail.Product_Code)

if @UOM = N'Reporting UOM'   
 Select "Temp Item Code" = Temp_Prod_Code, "Item Code" = Prod_Code, "Secondary Sales Volume" = dbo.sp_Get_ReportingUOMQty(Prod_Code, Sum(Qty)), "Value" = Sum(Value)  
 from #SalesTemp 
 Group by Temp_Prod_Code, Prod_Code   
Else If @UOM = N'Sales UOM'  
 Select "Temp Item Code" = Temp_Prod_Code, "Item Code" = Prod_Code, "Secondary Sales Volume" = Cast(Sum(Qty) as nvarchar) --+ ' ' + UOM.Description
, "Value" = Sum(Value) 
 from #SalesTemp, Items, UOM
 Where Items.UOM = UOM.UOM
 and #SalesTemp.Prod_Code = Items.Product_Code
 Group by Temp_Prod_Code, Prod_Code, UOM.Description
Else If @UOM = N'Conversion Factor'
 Select "Temp Item Code" = Temp_Prod_Code, "Item Code" = Prod_Code, "Secondary Sales Volume" = Cast(Sum(Qty) as nvarchar) --+ ' ' + Isnull(ConversionTable.ConversionUnit, '') 
, "Value" = Sum(Value) 
 from #SalesTemp, Items, ConversionTable
 Where Items.ConversionUnit *= ConversionTable.ConversionID
 and #SalesTemp.Prod_Code = Items.Product_Code
 Group by Temp_Prod_Code, Prod_Code, ConversionTable.ConversionUnit
