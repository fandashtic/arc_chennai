CREATE Procedure spr_list_Rural_Secondary_Volume  
(   
@From_Date DateTime,   
@To_Date DateTime,   
@UOM nvarchar(256)  
 )  
AS  
  
Create Table #RuralTemp (RuralID Integer, Classification nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, Value Decimal(18,6))  
  
Insert into #RuralTemp (RuralID, Classification, Value)  
Select 1, 'Base Town', Sum(-1 * (Isnull(NetValue, 0)))  
from InvoiceAbstract, Customer, 
(Select Distinct InvoiceAbstract.InvoiceID 
from InvoiceDetail, Batch_Products, InvoiceAbstract 
Where InvoiceDetail.Batch_Code = Batch_Products.Batch_Code
and InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
and InvoiceType in (4) 
and Isnull(Damage, 0) = 0
and InvoiceDate between @From_Date and @To_Date) I  
Where InvoiceAbstract.CustomerID = Customer.CustomerID  
and InvoiceDate between @From_Date and @To_Date  
and Customer.TownClassify in (1)   
and InvoiceType in (4)  
and isnull(invoiceAbstract.Status, 0) & 192 = 0  
and InvoiceAbstract.InvoiceID in (I.InvoiceID)
Union  
Select 1, 'Base Town', Sum(Isnull(DispatchDetail.Quantity * DispatchDetail.SalePrice, 0))  
from DispatchAbstract, Customer, DispatchDetail  
Where DispatchAbstract.CustomerID = Customer.CustomerID  
and DispatchAbstract.DispatchID = DispatchDetail.DispatchID   
and DispatchDate between @From_Date and @To_Date  
and Customer.TownClassify in (1)   
and isnull(Status, 0) & 64 = 0  
  
Insert into #RuralTemp (RuralID, Classification, Value)  
Select 2, 'Satellite', Sum(-1 * (Isnull(NetValue, 0)))  
from InvoiceAbstract, Customer, 
(Select Distinct InvoiceAbstract.InvoiceID 
from InvoiceDetail, Batch_Products, InvoiceAbstract 
Where InvoiceDetail.Batch_Code = Batch_Products.Batch_Code
and InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
and InvoiceType in (4) 
and Isnull(Damage, 0) = 0
and InvoiceDate between @From_Date and @To_Date) I  
Where InvoiceAbstract.CustomerID = Customer.CustomerID  
and InvoiceDate between @From_Date and @To_Date  
and Customer.TownClassify in (2)   
and InvoiceType in (4)  
and isnull(invoiceAbstract.Status, 0) & 192 = 0  
and InvoiceAbstract.InvoiceID in (I.InvoiceID)
Union  
Select 2, 'Satellite', Sum(Isnull(DispatchDetail.Quantity * DispatchDetail.SalePrice, 0))  
from DispatchAbstract, Customer, DispatchDetail  
Where DispatchAbstract.CustomerID = Customer.CustomerID  
and DispatchAbstract.DispatchID = DispatchDetail.DispatchID   
and DispatchDate between @From_Date and @To_Date  
and Customer.TownClassify in (2)   
and isnull(Status, 0) & 64 = 0   
  
Insert into #RuralTemp (RuralID, Classification, Value)  
Select 4, 'Rural Urban', Sum(-1 * (Isnull(NetValue, 0)))  
from InvoiceAbstract, Customer, 
(Select Distinct InvoiceAbstract.InvoiceID 
from InvoiceDetail, Batch_Products, InvoiceAbstract 
Where InvoiceDetail.Batch_Code = Batch_Products.Batch_Code
and InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
and InvoiceType in (4) 
and Isnull(Damage, 0) = 0
and InvoiceDate between @From_Date and @To_Date) I  
Where InvoiceAbstract.CustomerID = Customer.CustomerID  
and InvoiceDate between @From_Date and @To_Date  
and Customer.TownClassify in (4)   
and InvoiceType in (4)  
and isnull(invoiceAbstract.Status, 0) & 192 = 0  
and InvoiceAbstract.InvoiceID in (I.InvoiceID) 
Union  
Select 4, 'Rural Urban', Sum(Isnull(DispatchDetail.Quantity * DispatchDetail.SalePrice, 0))  
from DispatchAbstract, DispatchDetail, Customer  
Where DispatchAbstract.CustomerID = Customer.CustomerID  
and DispatchAbstract.DispatchID = DispatchDetail.DispatchID   
and DispatchDate between @From_Date and @To_Date  
and Customer.TownClassify in (4)   
and isnull(Status, 0) & 64 = 0   
  
Insert into #RuralTemp (RuralID, Classification, Value)  
Select 3, 'Rural Rural', Sum(-1 * (Isnull(NetValue, 0)))  
from InvoiceAbstract, Customer, 
(Select Distinct InvoiceAbstract.InvoiceID 
from InvoiceDetail, Batch_Products, InvoiceAbstract 
Where InvoiceDetail.Batch_Code = Batch_Products.Batch_Code
and InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
and InvoiceType in (4) 
and Isnull(Damage, 0) = 0
and InvoiceDate between @From_Date and @To_Date) I  
Where InvoiceAbstract.CustomerID = Customer.CustomerID  
and InvoiceDate between @From_Date and @To_Date  
and Customer.TownClassify in (3)   
and InvoiceType in (4)  
and isnull(invoiceAbstract.Status, 0) & 192 = 0  
and InvoiceAbstract.InvoiceID in (I.InvoiceID) 
Union  
Select 3, 'Rural Rural', Sum(Isnull(DispatchDetail.Quantity * DispatchDetail.SalePrice, 0))  
from DispatchAbstract, DispatchDetail, Customer  
Where DispatchAbstract.CustomerID = Customer.CustomerID  
and DispatchAbstract.DispatchID = DispatchDetail.DispatchID   
and DispatchDate between @From_Date and @To_Date  
and Customer.TownClassify in (3)   
and isnull(Status, 0) & 64 = 0   
  
Select RuralID, Classification, "Net Value" = Sum(Value) from #RuralTemp Group by RuralID, Classification Order By RuralID  
Drop Table #RuralTemp  
  





