CREATE Procedure spr_Itemwise_Companywise_BookStock_Received(@FromDate Datetime)    
    
as    
  
Declare @CoID nvarchar(100)  
Declare @AlterSQL nvarchar(4000)  
Declare @UpdateSQL nvarchar(4000)  
Declare @Item nvarchar(500)  
Declare @Co nvarchar(100)  
Declare @Qty Decimal(18,6)  

Declare @CATEGORYMISMATCH nvarchar(30)
Select @CATEGORYMISMATCH = dbo.LookupdictionaryItem(N'CATEGORY MISMATCH',Default)
  
Select "Item Code" = ReportAbstractReceived.Field1,     
"ItemCode" = ReportAbstractReceived.Field1,     
"Item Name" = min(ReportAbstractReceived.Field2),     
"Category" =   
case when ((min(ReportAbstractReceived.Field3)) <> (max(ReportAbstractReceived.Field3))) Then  
@CATEGORYMISMATCH
Else max(ReportAbstractReceived.Field3)  
End,  
"Total Qty" = Sum (cast(Cast(ReportAbstractReceived.Field4 as float)as Decimal(18,6))),      
"Saleable Stock" = Sum (cast(Cast(ReportAbstractReceived.Field5 as float)as Decimal(18,6))),      
"Free Stock" = Sum (cast(Cast(ReportAbstractReceived.Field6 as float) as Decimal(18,6))),      
"Damage Stock" = Sum (cast(Cast(ReportAbstractReceived.Field7 as float)as Decimal(18,6)))     
  
into #Received_Temp  
  
from ReportAbstractReceived, Reports     
    
where Reports.ReportID = ReportAbstractReceived.ReportID    
and Reports.ReportID in (Select Max(ReportID) From Reports   
   Where ReportName = N'Available Book Stock'   
   And dbo.StripDateFromTime(ReportDate) = dbo.StripDateFromTime(@FROMDATE)Group By CompanyID)  
  
And dbo.StripDateFromTime(ReportDate) = dbo.StripDateFromTime(@FROMDATE)    
and ReportAbstractReceived.Field1 <> N'Item Code'         
and ReportAbstractReceived.Field1 <> N'SubTotal:'    
and ReportAbstractReceived.Field1 <> N'GrandTotal:'      
Group by ReportAbstractReceived.Field1  
  
-- cursor to store Company Names  
DECLARE CompanyID CURSOR FOR        
Select distinct CompanyID  
from ReportAbstractReceived, Reports      
where Reports.ReportName = N'Available Book Stock'         
and Reports.ReportID = ReportAbstractReceived.ReportID        
and dbo.stripdatefromtime(Reports.ReportDate) = dbo.stripdatefromtime(@FROMDATE)        
  
-- Adding Co name to the top frame  
OPEN CompanyID  
FETCH FROM CompanyID Into @CoID  
            
WHILE @@FETCH_STATUS = 0            
BEGIN            
 SET @AlterSQL = N'ALTER TABLE #Received_Temp Add [' + @CoID +  N'] Decimal(18,6)'             
 EXEC sp_executesql @AlterSQL            
 FETCH NEXT FROM CompanyID INTO @CoID            
END         
  
-- storing Co wise Qty in a cursor  
Declare Item_Qty CURSOR FOR  
Select "Item Code" = ReportAbstractReceived.Field1,  
CompanyID, "Total Quantity" = (cast(Cast(ReportAbstractReceived.Field4 as float)as Decimal(18,6)))  
from ReportAbstractReceived, Reports      
where Reports.ReportName = N'Available Book Stock'         
and Reports.ReportID = ReportAbstractReceived.ReportID        
and dbo.stripdatefromtime(Reports.ReportDate) = dbo.stripdatefromtime(@FROMDATE)        
and ReportAbstractReceived.Field4 <> N'Total Qty'  
  
-- Updating the Item with the Qty Co wise  
  
Open Item_Qty   
FETCH FROM Item_Qty Into @Item, @Co, @Qty  
  
 WHILE @@FETCH_STATUS = 0            
 BEGIN            
  
 SET @UpdateSQL = N'Update #Received_Temp Set [' + cast(@Co as nvarchar)+ N'] = ' + cast (@Qty as nvarchar) + N' Where ItemCode collate SQL_Latin1_General_Cp1_CI_AS = N''' + cast(@Item as nvarchar) + ''''          
 exec sp_executesql @UpdateSQL           
 FETCH NEXT FROM Item_Qty Into @Item, @Co, @Qty  
 END  
  
  
Select * from #Received_Temp  
  
Close CompanyID  
Deallocate CompanyID  
Close Item_Qty  
Deallocate Item_Qty  
Drop Table #Received_Temp  
  
  
  
  



