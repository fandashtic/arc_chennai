Create Procedure Spr_list_Itemwise_Damaged_Return(@ITEMCODE nVarChar(500),  
    @SALESRETURNTYPE nVarChar(100),  
    @FROMDATE DateTime,  
    @TODATE DateTime)  
As  

Declare @DELIMETER as Char(1)      
Set @DELIMETER=Char(15)      
Create Table #tmpItem(ItemCode nVarChar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)
    
If @ITEMCODE = N'%'  
   Insert InTo #tmpItem Select Product_Code From Items --Union Select 0  
Else    
   Insert InTo #tmpItem select Product_Code From Items Where Product_Code In   
   (Select * from dbo.sp_SplitIn2Rows(@ITEMCODE, @DELIMETER))  
  
Select   
 "Item" = Itm.Product_Code,   
 "Item Name" = Itm.ProductName,   
 "Item Code" = Itm.Product_Code,   
 "Total Sales ReturnValue (%c)" = Sum(IDet.Amount)  
From   
 InvoiceAbstract IAbs, InvoiceDetail IDet, Items Itm     
Where   
 IAbs.InvoiceType in (4,5) And   
 IAbs.InvoiceDate BETWEEN @FROMDATE AND @TODATE And  
 Itm.Product_Code in (Select ItemCode From #tmpItem) And   
 IsNull(IAbs.Status, 0) & 32 =   
  (Case @SalesReturnType When N'Saleable' Then 0     
  When N'Damages' Then 32   
  Else IsNull(IAbs.Status, 0) & 32  End) And   
 (IsNull(IAbs.Status, 0) & 192) = 0 And   
 IAbs.InvoiceID = IDet.InvoiceID And   
 IDet.Product_Code = Itm.Product_Code  
Group By  
 Itm.ProductName, Itm.Product_Code  
  
Drop table #tmpItem  

