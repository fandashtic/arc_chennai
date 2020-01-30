CREATE procedure spr_list_freescheme_detail(@TYPE int, @fromdate datetime, @todate datetime)  
as  
DECLARE @SCHEME_TYPE int  
  
SELECT @SCHEME_TYPE = SchemeType FROM Schemes WHERE SchemeID = @TYPE  
IF @SCHEME_TYPE = 17 or @SCHEME_TYPE = 18 or @SCHEME_TYPE = 49 or @SCHEME_TYPE = 50  
BEGIN  
select  SchemeSale.Product_Code, "Free Item Code" = SchemeSale.Product_Code,   
 "Free Item Name" = Items.ProductName, "Free Qty" = SUM(Schemesale.Free), 
"Cost (%c)" = SUM(SchemeSale.Cost)  
from SchemeSale, Items  
where   Type = @TYPE and   
 InvoiceID in (select InvoiceID from InvoiceAbstract where (IsNull(Status,0) & 192) = 0  And InvoiceDate between @fromdate and @todate)      
 and SchemeSale.Product_Code = Items.Product_Code  
Group By SchemeSale.Product_code, Items.ProductName  
END  
ELSE IF @SCHEME_TYPE = 20  
BEGIN  
select  SchemeSale.Product_Code, "Item Code" = SchemeSale.Product_Code, 
"Item Name" = Items.ProductName,   
 "Quantity" = Schemesale.Free, "Cost (%c)" = SchemeSale.Cost   
from SchemeSale, Items   
where   Type = @TYPE   
 and InvoiceID in (select InvoiceID from InvoiceAbstract where  (IsNull(Status,0) & 192) = 0  And InvoiceDate between @fromdate and @todate)    
 and SchemeSale.Product_Code = Items.Product_Code  
END  
ELSE IF @SCHEME_TYPE = 19  
BEGIN  
select  SchemeSale.Product_Code, "Item Code" = SchemeSale.Product_Code, 
"Item Name" = Items.ProductName,   
 "Quantity" = Schemesale.Free, "Discount %" = round(SchemeSale.Cost, 2), 
"Cost (%c)" = Round((SchemeSale.Cost * SchemeSale.Value) / 100, 2)
from SchemeSale, Items   
where   Type = @TYPE   
 and InvoiceID in (select InvoiceID from InvoiceAbstract where  (IsNull(Status,0) & 192) = 0  And InvoiceDate between @fromdate and @todate)    
 and SchemeSale.Product_Code = Items.Product_Code  
END  
Else IF @SCHEME_TYPE = 3 or @SCHEME_TYPE = 35
BEGIN  
select  SchemeSale.Product_Code, "Free Item Code" = SchemeSale.Product_Code,   
	"Free Item Name" = Items.ProductName, 
	"Free Qty" = SUM(Schemesale.Free), "Cost (%c)" = SUM(SchemeSale.Cost)  
from SchemeSale, Items  
where   Type = @TYPE and   
 InvoiceID in (select InvoiceID from InvoiceAbstract where  (IsNull(Status,0) & 192) = 0  And InvoiceDate between @fromdate and @todate)    
 and SchemeSale.Product_Code = Items.Product_Code  
Group By SchemeSale.Product_code, Items.ProductName  
END 

Else IF @SCHEME_TYPE = 4
BEGIN  
select  SchemeSale.Product_Code, "Free Item Code" = SchemeSale.Product_Code,   
	"Free Item Name" = Items.ProductName, 
	"Free Qty" = SUM(Schemesale.Free), "Cost (%c)" = SUM(SchemeSale.Cost)  
from SchemeSale, Items  
where   Type = @TYPE and   
 InvoiceID in (select InvoiceID from InvoiceAbstract where  (IsNull(Status,0) & 192) = 0  And InvoiceDate between @fromdate and @todate)    
 and SchemeSale.Product_Code = Items.Product_Code  
Group By SchemeSale.Product_code, Items.ProductName  
END 

Else IF @SCHEME_TYPE = 21 Or @SCHEME_TYPE = 22 Or @SCHEME_TYPE = 81
BEGIN  
select  SchemeSale.Product_Code, 
 "Item Code" = SchemeSale.Product_Code, 
 "Item Name" = Items.ProductName,   
 "Quantity" = Sum(Schemesale.Free), 
 "Discount %" = round(SchemeSale.Cost, 2), 
 "Cost (%c)" = Sum(Round((SchemeSale.Cost * SchemeSale.Value) / 100, 2))
from SchemeSale, Items   
where   Type = @TYPE   
 and InvoiceID in (select InvoiceID from InvoiceAbstract where  (IsNull(Status,0) & 192) = 0  And InvoiceDate between @fromdate and @todate)    
 and SchemeSale.Product_Code = Items.Product_Code  
Group By SchemeSale.Product_code, Items.ProductName,-- Schemesale.Free, 
 SchemeSale.Cost  --, SchemeSale.Value
END 
Else IF @SCHEME_TYPE = 82
BEGIN  
select  SchemeSale.Product_Code, 
 "Item Code" = SchemeSale.Product_Code, 
 "Item Name" = Items.ProductName,   
 "Quantity" = Sum(Schemesale.Free), 
 "Amount Discount" = Sum(round(SchemeSale.Cost, 2))
-- "Cost (%c)" = Round((SchemeSale.Cost * SchemeSale.Value) / 100, 2)
from SchemeSale, Items 
where   Type = @TYPE   
 and InvoiceID in (select InvoiceID from InvoiceAbstract where  (IsNull(Status,0) & 192) = 0  And InvoiceDate between @fromdate and @todate)    
 and SchemeSale.Product_Code = Items.Product_Code  
Group By SchemeSale.Product_code, Items.ProductName --, Schemesale.Free, 
-- SchemeSale.Cost, SchemeSale.Value
END 
Else IF @SCHEME_TYPE = 83 Or @SCHEME_TYPE = 84
BEGIN  
select  SchemeSale.Product_Code, "Free Item Code" = SchemeSale.Product_Code,   
 "Free Item Name" = Items.ProductName, "Free Qty" = SUM(Schemesale.Free), 
"Cost (%c)" = SUM(SchemeSale.Cost)  
from SchemeSale, Items  
where Type = @TYPE and   
      SchemeSale.Value = 0 And
 InvoiceID in (select InvoiceID from InvoiceAbstract where  (IsNull(Status,0) & 192) = 0  And InvoiceDate between @fromdate and @todate)    
 and SchemeSale.Product_Code = Items.Product_Code  
Group By SchemeSale.Product_code, Items.ProductName 
END 
Else IF @SCHEME_TYPE = 97 Or @SCHEME_TYPE = 99
BEGIN  
select  SchemeSale.Product_Code, "Free Item Code" = SchemeSale.Product_Code,   
 "Free Item Name" = Items.ProductName, "Free Qty" = SUM(Schemesale.Free)
--"Cost (%c)" = SUM(SchemeSale.Cost)  
from SchemeSale, Items  
where Type = @TYPE and   
      SchemeSale.Value = 0 And
 InvoiceID in (select InvoiceID from InvoiceAbstract where  (IsNull(Status,0) & 192) = 0  And InvoiceDate between @fromdate and @todate)    
 and SchemeSale.Product_Code = Items.Product_Code  
Group By SchemeSale.Product_code, Items.ProductName  
END
