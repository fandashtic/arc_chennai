CREATE PROCEDURE [dbo].[Spr_Salesmanproductivity_Abstract]  
(@DSName NVarchar(200),@BName NVarchar(200),@FromDate DateTime,@ToDate DateTime)   
AS        
          
BEGIN        
        
Declare @Delimeter as Char(1)              
Set @Delimeter = Char(15)
              
        
Create Table #TmpSalesman(Salesman_Name NVarchar(200) COLLATE SQL_Latin1_General_CP1_CI_AS)          
--Create Table #TmpBeat(BeatName NVarchar(200) COLLATE SQL_Latin1_General_CP1_CI_AS)          
          
if @DSName = '%'       
     
   Insert into #TmpSalesman select Salesman_Name from Salesman            
else            
   Insert into #TmpSalesman select * from dbo.sp_SplitIn2Rows(@DSName, @Delimeter)            
          
Select Distinct CustomerID into #Cust from Customer
 where ChannelType Not In  
(Select ChannelType from Customer_Channel where ChannelDesc='Hawker' And Active='1')  
And Active=1  
  
Select Distinct IA.SalesmanID,Salesman.Salesman_Name  
Into #temp   
From InvoiceAbstract IA, Salesman             
Where 
IA.SalesmanID = Salesman.SalesmanID   
And IA.InvoiceDate Between @FromDate And @ToDate     
And Salesman_Name In (Select * From #TmpSalesman) Group By IA.SalesmanID,Salesman.Salesman_Name            
  
Create Table #temp1 (  
SalesmanID int,            
   
DSName nvarchar(50)COLLATE SQL_Latin1_General_CP1_CI_AS,                 
TotalOutlet Decimal(10),                
TotalOutletCovered Decimal(10),   
NoofBillsforCustomers Decimal(10)            
)  
   
Insert Into #temp1 (SalesmanID,DSName,TotalOutlet,TotalOutletCovered,NoofBillsforCustomers)  
Select               
SalesmanID,            
"DSName" = Salesman_Name,              
               
"TotalOutlet" = (Select Count(Distinct CustomerID) From Customer Where ChannelType Not In  
(Select Channe
lType from Customer_Channel where ChannelDesc='Hawker' And Active='1')  
And Active=1   
And CustomerID In              
(Select Distinct CustomerID From Beat_Salesman where SalesmanId=C.SalesmanID)  
),   
  
"TotalOutletCovered" = (Select Count(Distinct
 invoiceabstract.CUSTOMERID)   
From InvoiceAbstract Where SalesmanId = C.SalesmanID   
And CustomerID IN (Select CustomerID from #Cust)  
And InvoiceDate Between @FromDate And @ToDate        
And Status & 192 = 0 and InvoiceType in (1,3)),     
         
     
"NoofBillsforCustomers" = (Select Count(Distinct InvoiceID)   
From InvoiceAbstract Where SalesmanId = C.SalesmanID   
And CustomerID IN (Select CustomerID from #Cust)  
And InvoiceDate Between @FromDate And @ToDate        
And Status & 192 = 0 and 
InvoiceType in (1,3))  
From #temp c              
            
Select SalesmanID,            
"DS Name" = DSName ,            
"Total Outlet" = Convert(Int,TotalOutlet),   
"Total Outlet Covered" = Convert(Int,TotalOutletCovered),   
"No of Unbilled Outl
et" =Convert(Int,( TotalOutlet -  TotalOutletCovered)),  
"% Variance"= (TotalOutlet - TotalOutletCovered)*100/TotalOutlet,              
"No of Bills" =Convert(Int,NoofBillsforCustomers) From #temp1           
       
Drop Table #temp              
Drop 
Table #temp1              
Drop Table #TmpSalesman        
--Drop Table #TmpBeat        
Drop Table #Cust             
End
