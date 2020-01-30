
  
CREATE Procedure Spr_NewProductLaunchTrackerReport_Detail(@ItemName NVarchar(2000),@Fromdate DateTime, @Todate DateTime)                  
As                  
Begin                  
Set DateFormat DMY                  
Declare @Delimeter Char(1)                
Declare @Iname NVarchar(200)                
Declare @DSname NVarchar(200)                
Declare @Bname NVarchar(200)                

Set @Delimeter = Char(15)                
Set @DSName = SubString(@ItemName,1,CharIndex(@Delimeter,@ItemName) - 1)                
Set @ItemName = SubString(@ItemName,CharIndex(@Delimeter,@ItemName) + 1,Len(@ItemName)- CharIndex(@Delimeter,@ItemName))                
Set @BName = SubString(@ItemName,1,CharIndex(@Delimeter,@ItemName) - 1)                
Set @IName = SubString(@ItemName,CharIndex(@Delimeter,@ItemName) + 1,Len(@ItemName)- CharIndex(@Delimeter,@ItemName))                
                
Create Table #tmp1 (InvDate DateTime, ItmCode NVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,                
                    ItmName NVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,                   
                    CustID NVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,                
                    Des NVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,                
                    Qty Decimal(18, 6),                
                    FreeQ Decimal(18, 6),                
                    Con Int)                  
                
Insert InTo #tmp1                   
Select Cast(DatePart(DD, inva.InvoiceDate) As VarChar) + '/' + Cast(DatePart(MM, inva.InvoiceDate) As VarChar) + '/' + Cast(DatePart(YY, inva.InvoiceDate) As VarChar),                   
invd.Product_Code, its.ProductName,                   
inva.CustomerID, uom.[Description],                   
Case When Saleprice > 0  Then     
sum((Case when Inva.Invoicetype in(1,3)  then isnull(invd.Quantity,0) End))    
End,                  
Case When Saleprice = 0 Then     
sum((Case when Inva.Invoicetype in(1,3) then isnull(invd.Quantity,0) End))    
End,                  
(Select Count(*) From InvoiceAbstract ia, InvoiceDetail ids Where ia.InvoiceID = ids.InvoiceID And             
ia.CustomerID = inva.CustomerID And               
Cast(Cast(DatePart(DD, ia.InvoiceDate) As VarChar) + '/' + Cast(DatePart(MM, ia.InvoiceDate) As VarChar) + '/' + Cast(DatePart(YY, ia.InvoiceDate) As VarChar) as DateTime)              
Between @Fromdate And DateAdd(DD, -1, Inva.InvoiceDate) And ids.Product_Code = invd.Product_Code)                  
From InvoiceAbstract inva, InvoiceDetail invd, Items its, UOM,beat_salesman,beat,salesman                  
Where its.UOM = UOM.UOM And inva.InvoiceID = invd.InvoiceID And invd.Product_Code = its.Product_Code And beat_salesman.salesmanid = salesman.salesmanid and                  
beat_salesman.beatid = beat.beatid and beat_salesman.customerid = inva.customerid and inva.beatid=beat.beatid and beat.description =@BName and invd.product_code = @IName and                  
salesman.salesman_name =@DSName and inva.InvoiceDate Between @Fromdate And @Todate And inva.status & 192 = 0               
Group By Cast(DatePart(DD, inva.InvoiceDate) As VarChar) + '/' + Cast(DatePart(MM, inva.InvoiceDate) As VarChar) + '/' + Cast(DatePart(YY, inva.InvoiceDate) As VarChar),                  
invd.Product_Code, its.ProductName, inva.CustomerID, Inva.InvoiceDate,                   
uom.[Description], invd.Quantity, invd.saleprice                  
Order By Cast(DatePart(DD, inva.InvoiceDate) As VarChar) + '/' + Cast(DatePart(MM, inva.InvoiceDate) As VarChar) + '/' + Cast(DatePart(YY, inva.InvoiceDate) As VarChar)                  
      
Select "Date" = [InvDate], "Item Code" = [ItmCode], "Item Name" = [ItmName],                   
"No of Potential Customers" = (Select count(distinct customerid) from beat_salesman,beat,salesman where beat_salesman.beatid = beat.beatid       
                       and salesman.salesmanid = beat_salesman.salesmanid and description = @BName and                
                               salesman_name = @DSName),                  
"New Productive Customers" = Sum(IsNull([New Cust], 0)),                  
"Repeat Customers" = Sum(IsNull([Rep Cust], 0)), "UOM" = [Des],     
"1st time productive sale" = Sum(IsNull([New Cust Qty], 0)),                 
 "Repeat Sale" = Sum(IsNull([Rep Cust Qty], 0)), "Free Sale/Sample Given" =  Sum(IsNull([free], 0))                   
into #temp               
From (                  
Select InvDate, ItmCode, ItmName, "New Cust" = Case Con When 0 Then Count(Distinct CustID) End,                   
"Rep Cust" = Case When Con > 0 Then Count(Distinct CustID) End, Des,                   
"New Cust Qty" =     
Case Con     
When 0 Then     
Sum(isNull(Qty,0))
End,                   
"Rep Cust Qty" = Case When Con > 0 Then Sum(isNull(Qty,0)) End, "free" = Sum(isNull(Freeq,0)), Con From #tmp1                   
Group By InvDate, ItmCode, ItmName, Con, des) fl Group By [InvDate], [ItmCode], [ItmName], [Des]                  


Select '',*,"Average Sale Per Customer" = (([1st time productive sale] + [Repeat Sale]) / ([New Productive Customers] + [Repeat Customers])) From #temp    

Drop Table #tmp1                  
                  
Drop Table #temp                  
                  
End            
           
SET QUOTED_IDENTIFIER ON 
