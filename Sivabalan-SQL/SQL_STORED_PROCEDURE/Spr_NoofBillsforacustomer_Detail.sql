  
Create  PROCEDURE Spr_NoofBillsforacustomer_Detail(@DSBeat NVarchar(200),@FromDate DateTime,@ToDate DateTime)              
            
AS      
            
BEGIN      
      
Declare @Beat NVarchar(200)      
      
Declare @DSName NVarchar(200)      
      
Set @DSName = Substring(@DSBeat,1,CharIndex(Char(15),@DSBeat) - 1)      
      
Set @Beat = Substring(@DSBeat,CharIndex(Char(15),@DSBeat) + 1,Len(@DSBeat) - CharIndex(Char(15),@DSBeat) + 1)      
         
Select             
  
Description,          
  
"Beat Name" = Description,            
          
"Customer Code" = Beat_Salesman.CustomerID,          
      
"Customer Name" = Company_Name,      
            
"Customer Type (New/Repeat)" = Case When Customer.CreationDate Between @FromDate And @ToDate Then 'New' Else      
                               Case When Customer.CreationDate < @FromDate Then 'Repeat' End End,          
         
"No. of Invoices" = Count(distinct InvoiceAbstract.InvoiceID)          

From InvoiceAbstract, Beat, Beat_Salesman, Salesman, Customer   
Where InvoiceAbstract.SalesmanID = Beat_Salesman.SalesmanID And InvoiceAbstract.BeatID = Beat_Salesman.BeatID And   
Beat.BeatID = Beat_Salesman.BeatID And  Beat_Salesman.CustomerID = Customer.CustomerID And InvoiceAbstract.CustomerID = Beat_Salesman.CustomerID And      
Beat_Salesman.SalesmanID = Salesman.SalesmanID And Description Like @Beat And Salesman_Name Like @DSName          
And InvoiceDate Between @FromDate And @ToDate And Status & 192 = 0 And InvoiceType in (1,3)      
Group By Beat_Salesman.CustomerID, Customer.CreationDate, Description, Company_Name         
       
END  
  
