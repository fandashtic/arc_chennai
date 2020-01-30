CREATE PROCEDURE spr_Brandspercall(@FROMDATE DATETIME,    
      @TODATE DATETIME)    
AS    
  
declare @level int  
Declare @BRAND As NVarchar(50)

Set @BRAND = dbo.LookupDictionaryItem(N'Brand', Default)

select @Level = HierarchyId from ItemHierarchy where HierarchyName like @BRAND + '%'  
create table #temptable (invid int , manid int, ItemCount float, ItemAmount Decimal(18,6), brand int)    
if isnull(@Level, N'') <> N''  
begin  
insert into #temptable(invid, manid,ItemCount, ItemAmount,brand)     
SELECT invoiceabstract.invoiceid , salesman.salesmanid,  
 "ItemCount"=count(Distinct Product_Code), Sum(Amount)  ,  
 dbo.getBrandID(Product_Code, @Level)  
  
FROM InvoiceAbstract,InvoiceDetail, Customer, Salesman    
WHERE   InvoiceType in (1, 3) AND InvoiceAbstract.InvoiceID=InvoiceDetail.InvoiceID AND    
 InvoiceAbstract.CustomerID = Customer.CustomerID AND    
 InvoiceAbstract.SalesmanID = Salesman.SalesmanID AND    
 InvoiceAbstract.InvoiceDate BETWEEN @FromDate and @ToDate AND    
 (InvoiceAbstract.Status & 128) = 0    
GROUP BY invoicedate,InvoiceAbstract.InvoiceID,salesman.salesmanid  , dbo.getBrandID(Product_Code, @Level)  
----------------  
----select * from   #temptable  
------------------  
end  
SELECT  #temptable.manID, "Salesman" = Salesman.Salesman_Name,     
 "Net Value (%c)" = SUM(ItemAmount), --"Avg Brands Per Call" = cast(round(avg(ItemCount),1) as Float)    
--"Avg Brands Per Call" = round(cast (count(distinct(brand)) as Decimal(18,6)),2) / round(cast (count(distinct(invid)) as Decimal(18,6)),2)  
"Avg Brands Per Call" = round(cast (count((brand)) as Decimal(18,6)),2) / round(cast (count(distinct(invid)) as Decimal(18,6)),2)  
FROM Salesman, #temptable    
WHERE salesman.salesmanid = #temptable.manid    
GROUP BY Salesman.Salesman_Name, #temptable.manid    
drop table #temptable    


