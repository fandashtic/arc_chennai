CREATE Procedure spr_list_SecondarySalesVolume(@FromDate DateTime, @ToDate DateTime, @Uom nvarchar(20))  
as   
If @Uom = N'Sales UOM'  
Begin  
Select Null, Tmp.Product_Code "Item Code", cast(Sum(tmp.Quantity) as nvarchar) "Sale Quantity" 
From   
(  
select it.product_code ,it.productName,   
sum(dd.quantity) Quantity,   UOM.description  
from dispatchabstract da  
 Join dispatchdetail dd On                         
 da.dispatchid = dd.dispatchid                   
 Join items it On  
 dd.product_code = it.product_code  
 Join UOM on  
 it.UOM = UOM.UOM  
--Left Outer Join invoiceabstract ia On  
--    da.invoiceid = ia.InvoiceId   
where    
   da.status & 64 = 0 --and isnull(ia.Status,0) & 192 = 0   
and   
   Da.DispatchDate between @FromDate And @ToDate  
group by it.product_code, it.productname, Uom.description  
  
Union  
  
select it.product_code ,it.productName,   
sum((Case ia.InvoiceType when 4 then -1 when 2 then 1 End) * ind.quantity),  UOM.description  
from InvoiceAbstract ia  
 Join Invoicedetail Ind On  
 Ind.Invoiceid = Ia.Invoiceid  
Join items it On  
 Ind.product_code = it.product_code  
 Join UOM on  
 it.UOM = UOM.UOM 
join Batch_Products BP on 
 Ind.Batch_Code = BP.Batch_Code 
where    
   isnull(ia.Status,0) & 192 = 0 and ia.InvoiceType in (2, 4) and  
   ia.InvoiceDate between @FromDate And @ToDate And
   isnull(BP.Damage, 0) = 0	
group by it.product_code, it.productname, Uom.description  
) Tmp  
Group By Tmp.Product_Code, tmp.productName, tmp.Description   
End  
  
Else If @Uom = N'Reporting UOM'  
Begin  
Select Null, Tmp.Product_Code "Item Code", Cast(dbo.sp_Get_ReportingUOMQty(Tmp.Product_Code, Sum(tmp.Quantity)) as nvarchar) "Sale Quantity"  
From   
(  
select it.product_code ,it.productName,   
sum(dd.quantity) Quantity,   
IsNull(UOM.[description], N'')  [Description]
from dispatchabstract da  
 Join dispatchdetail dd On  
 da.dispatchid = dd.dispatchid   
 Join items it On  
 dd.product_code = it.product_code  
 Left Join UOM on  
 it.ReportingUOM = UOM.UOM  
--Left Outer Join invoiceabstract ia On  
--    da.invoiceid = ia.InvoiceId   
where    
   da.status & 64 = 0 --and isnull(ia.Status,0) & 192 = 0   
and   
   Da.DispatchDate between @FromDate And @ToDate  
group by it.product_code, it.productname, Uom.description, it.ReportingUnit  
  
Union  
  
select it.product_code ,it.productName,   
sum((Case ia.InvoiceType when 4 then -1 when 2 then 1 End) * ind.quantity),  
IsNull(UOM.[description], N'') [Description]
from InvoiceAbstract ia  
 Join Invoicedetail Ind On  
 Ind.Invoiceid = Ia.Invoiceid  
 Join items it On  
 Ind.product_code = it.product_code  
 Left Join UOM on  
 it.ReportingUOM = UOM.UOM  
join Batch_Products BP on 
 Ind.Batch_Code = BP.Batch_Code 
where    
   isnull(ia.Status,0) & 192 = 0 and ia.InvoiceType in (2, 4) and  
   ia.InvoiceDate between @FromDate And @ToDate And
   Isnull(BP.Damage, 0) = 0
group by it.product_code, it.productname, Uom.description, it.ReportingUnit  
) Tmp  
Group By Tmp.Product_Code, tmp.productName, tmp.Description   
End  
  
Else If @Uom = N'Conversion Factor'  
Begin  
Select Null, Tmp.Product_Code "Item Code", cast(Sum(tmp.Quantity) as nvarchar) "Sale Quantity" 
From                                                     
(                                                        
select it.product_code ,it.productName,   
sum(dd.quantity) * (Case When it.ConversionFactor > 0 Then It.ConversionFactor Else 1 End)
 Quantity,   IsNull(con.ConversionUnit, N'') ConversionUnit
from dispatchabstract da  
 Join dispatchdetail dd On                         
 da.dispatchid = dd.dispatchid                   
 Join items it On  
 dd.product_code = it.product_code  
 Left Join conversiontable con on  
 it.Conversionunit = con.ConversionID  
--Left Outer Join invoiceabstract ia On  
--    da.invoiceid = ia.InvoiceId   
where    
   da.status & 64 = 0 --and isnull(ia.Status,0) & 192 = 0   
and   
   Da.DispatchDate between @FromDate And @ToDate  
group by it.product_code, it.productname, con.ConversionUnit, it.ConversionFactor  
 
Union  
  
select it.product_code ,it.productName,   
sum((Case ia.InvoiceType when 4 then -1 when 2 then 1 End) * ind.quantity) * (Case 
When it.ConversionFactor > 0 Then It.ConversionFactor Else 1 End)
,  IsNull(con.ConversionUnit, N'') ConversionUnit
from InvoiceAbstract ia  
 Join Invoicedetail Ind On  
 Ind.Invoiceid = Ia.Invoiceid  
 Join items it On  
 Ind.product_code = it.product_code  
 Left Join ConversionTable con on  
 it.Conversionunit = con.ConversionID  
join Batch_Products BP on 
 Ind.Batch_Code = BP.Batch_Code 
where    
   isnull(ia.Status,0) & 192 = 0 and ia.InvoiceType in (2, 4) and  
   ia.InvoiceDate between @FromDate And @ToDate  And
   Isnull(BP.Damage, 0) = 0
group by it.product_code, it.productname, con.ConversionUnit, it.ConversionFactor  
) Tmp  
Group By Tmp.Product_Code, tmp.productName, tmp.ConversionUnit  
End  



