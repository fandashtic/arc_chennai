CREATE procedure sp_View_Collections_Received(@CustomerID nvarchar(50), @BranchID nVarchar(50),     
      @FromDate datetime,      
      @ToDate datetime)      
as      

select Customer.Company_Name, Customer.CustomerID, FullDocID, Collections.DocumentDate,       
Value, DocSerial, Balance, Status, DocReference,DocumentReference    
from Collectionsreceived collections, Customer, WareHouse      
where Collections.CustomerID like @CustomerID and      
Customer.CustomerID = Collections.CustomerID And
Collections.BranchForumCode = WareHouse.ForumID And 
WareHouse.WareHouseID like @BranchID and      
Collections.DocumentDate between @FromDate and @ToDate       
order by Customer.Company_Name, Collections.DocumentDate      





