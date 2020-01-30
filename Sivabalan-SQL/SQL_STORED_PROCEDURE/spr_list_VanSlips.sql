
CREATE procedure spr_list_VanSlips (@fromdate datetime, @todate datetime, @UOM nVarchar(256))    
as    
  
Declare @OTHERS As NVarchar(50)  
Declare @OPENED As NVarchar(50)  
Declare @CLOSED As NVarchar(50)  
Set @OTHERS = dbo.LookupDictionaryItem(N'Others', Default)  
Set @OPENED = dbo.LookupDictionaryItem(N'Opened', Default)  
Set @CLOSED = dbo.LookupDictionaryItem(N'Closed', Default)  
  
select DocSerial,    
 "Van Statment No" =  VoucherPrefix.Prefix + cast (VanStatementAbstract.DocumentID as nvarchar),  
 "Date" = VanStatementAbstract.DocumentDate,  
 "Beat" = IsNull(Beat.Description,@OTHERS),     
 "Salesman" = Salesman.Salesman_Name,     
 "Van Id" = VanStatementAbstract.VanID,     
 "Van Number" = Van.Van_Number,    
 "Van Loading Date" = VanStatementAbstract.LoadingDate,  
 "Amount" = VanStatementAbstract.DocumentValue,  
 "Status" = CASE Status  
 WHEN 0 THEN @OPENED   
 WHEN 128 THEN @CLOSED  
        WHEN 192 THEN @CLOSED  
 END    
From VanStatementAbstract
Inner Join Van ON VanStatementAbstract.VanID = Van.Van
Inner Join Salesman ON VanStatementAbstract.SalesmanID = Salesman.SalesmanID
Left Outer Join Beat ON VanStatementAbstract.BeatID = Beat.BeatID
Inner Join VoucherPrefix ON VoucherPrefix.tranid = 'VAN LOADING STATEMENT'
Where 
VanStatementAbstract.DocumentDate between @fromdate and @todate     
And IsNull(Status, 0) & 192 = 0  
order by VanStatementAbstract.DocumentDate  

