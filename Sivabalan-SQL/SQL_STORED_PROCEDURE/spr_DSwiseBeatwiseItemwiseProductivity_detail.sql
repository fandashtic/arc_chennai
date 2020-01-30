CREATE PROCEDURE spr_DSwiseBeatwiseItemwiseProductivity_detail (@BEAT NVARCHAR(255),
							             @PRODUCTCODE NVARCHAR(4000), 
								     @PRODUCTNAME NVARCHAR(4000),              
								     @FROMDATE DATETIME,
								     @TODATE DATETIME)                
AS           
Declare @DS Int
Declare @Beatid Int
Declare @indx Int
Declare @Delimeter as Char(1)              
Set @Delimeter = Char(15)            

Set @indx = Charindex(@Delimeter, @BEAT)
Set @DS = Substring(@BEAT, 1, @indx - 1)
Set @BeatID = Substring(@BEAT, @indx + 1, Len(@BEAT))

Create table #item(itemcode nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)            
    
If @PRODUCTCODE='%'               
 insert into #item select product_code from items           
Else              
 Insert into #item select * from dbo.sp_SplitIn2Rows(@PRODUCTCODE,@Delimeter)       

Select "Item Code" = Product_Code, 
"Item Code" = Product_Code, 
"Item Name" = (Select ProductName From Items Where Product_Code = invd.Product_Code), 
"Total No Of Customers" = (Select Count(Distinct CustomerID) From Beat_Salesman
			   Where SalesmanID > 0 And CustomerID <> ''And 
			   BeatID = @BeatID And SalesmanID = @DS),

"No Of Customers Invoiced" = Count(Distinct Inv.CustomerID),
"No Of Customers Not Invoiced" = (Select Count(Distinct CustomerID) From Beat_Salesman
			   Where SalesmanID > 0 And CustomerID <> ''And 
			   BeatID = @BeatID And SalesmanID = @DS) - Count(Distinct Inv.CustomerID),

"UOM" = (Select TOP 1 UOM.Description From Items, UOM Where UOM.UOM=Items.UOM And 
         Items.Product_Code = InvD.Product_Code),
"Qty" = Sum(InvD.Quantity),
"Value %c" = Sum(InvD.Amount)
From InvoiceAbstract Inv, InvoiceDetail InvD
Where inv.InvoiceID = Invd.InvoiceID And 
inv.InvoiceType in (1, 3) and ISNULL(inv.STATUS, 0) & 128 = 0  And
inv.InvoiceDate Between @FROMDATE And @TODATE And
inv.BeatID = @BeatID And 
inv.SalesmanID = @DS  And 
invd.Product_Code In (Select itemcode From #item)
Group By invd.Product_Code

