Create PROCEDure Spr_han_SalesReturn(            
@Salesman nVarchar(4000), @Beat nvarchar(4000), @Customer nvarchar(4000) , @FromDate DateTime, @ToDate DateTime)            
As            
Declare @Delimeter as Char(1)              
Set @Delimeter=Char(15)                  
            
Create table #tmpSalesman(Saleman nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS )                  
Create table #tmpBeat(Beat nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS )              
Create table #tmpCustomer(Customer nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS )                  
            
If @Salesman ='%'                   
 Insert into #tmpSalesman Select Salesman_Name from Salesman            
 Else                  
 Insert into #tmpSalesman Select * from dbo.sp_SplitIn2Rows(@Salesman,@Delimeter)                  
                 
If @Beat ='%'                   
 Insert into #tmpBeat Select Description from Beat            
Else                  
 Insert into #tmpBeat Select * from dbo.sp_SplitIn2Rows(@Beat,@Delimeter)                  
            
If @Customer ='%'                   
 Insert into #tmpCustomer Select Company_Name from Customer            
Else                  
 Insert into #tmpCustomer Select * from dbo.sp_SplitIn2Rows(@Customer,@Delimeter)                   
            
            
Select Data = Cast(IsNull(StkRet.OUTLETID,'') AS VARCHAR)          
+ @Delimeter + Cast(IsNull(StkRet.SalesmanID,0) AS VARCHAR) + @Delimeter + Cast(IsNull(StkRet.BeatID,0)  AS VARCHAR) + @Delimeter + Cast(StkRet.ReturnType as varchar)     
+ @Delimeter + Cast(StkRet.DocumentDate as Varchar),   
"Date"= IsNull(StkRet.DocumentDate,''),        
"CustomerID" = IsNull(StkRet.OUTLETID,''),  
"CustomerName"= IsNull(Cust.Company_name,''),         
"SalesManID" = IsNull(StkRet.SalesmanID,0),  
"SalesManName"=IsNull(S.Salesman_Name,''),  
"BeatID"= IsNull(StkRet.BeatID,0),  
"BeatName"=IsNull(BET.Description,''),            
"ReturnType"=(case  when IsNull(StkRet.ReturnType,0)=1 then 'Saleable' when IsNull(StkRet.ReturnType,0)=2 Then 'Damage'  end),  
"Comments"=IsNull(StkRet.Reason,'')         
From stock_Return StkRet            
Inner Join Salesman S ON StkRet.SalesmanId = Cast(S.SalesmanId as nvarchar)             
Inner Join Customer Cust ON Cust.CustomerID = StkRet.OUTLETID            
Inner Join Beat BET ON Cast(BET.BeatID as nVarchar)  = StkRet.BeatID  
Where S.Salesman_Name in (Select Saleman from #tmpSalesman)            
And Cust.Company_name in (select customer from #tmpcustomer)            
AND BET.Description in (Select Beat from #tmpBeat)    
And StkRet.DocumentDate Between @FromDate and @ToDate            
Group by   
StkRet.SalesmanId
,StkRet.BillID
,StkRet.DocumentDate       
,StkRet.OUTLETID  
,Cust.Company_name  
,S.Salesman_Name            
,StkRet.BeatID  
,BET.Description             
,StkRet.ReturnType            
,StkRet.Reason    
Drop Table #tmpSalesman    
