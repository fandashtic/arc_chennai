CREATE PROCEDURE sp_list_Dispatch(@CUSTOMER nvarchar(15), @FROMDATE DATETIME,
				  @TODATE DATETIME, @STATUS INT)

AS
declare @Original_Refer as int 
declare @Dispatch_ID as int
declare @sql as nvarchar(3000)
declare @Org_Ref as int
declare @Disp_ID as int

/* creating a temp table with all the fields */

Create Table #temp1 (DispatchID int, DispatchDate datetime, CustID nvarchar(255), 
Custname nvarchar(255), Status int, DocumentID int, Original_Ref int,DocumentReference nvarchar(255),DocumentType nvarchar(100)) 

/* inserting values into temp table except the last field */
insert into #temp1 (DispatchID, DispatchDate, CustID, Custname, Status, DocumentID,DocumentReference,DocumentType)

SELECT DispatchID, DispatchDate, DispatchAbstract.CustomerID, 
Customer.Company_Name, Status, DocumentID,DocRef,DocSerialType

FROM DispatchAbstract, Customer

WHERE DispatchAbstract.CustomerID LIKE @CUSTOMER 
AND DispatchAbstract.CustomerID = Customer.CustomerID 
AND DispatchDate BETWEEN @FROMDATE AND @TODATE
AND DispatchAbstract.Status & @STATUS = 0
ORDER BY Customer.Company_Name, DispatchDate, DispatchID
Declare Disp_Cursor Cursor for
Select DispatchID from DispatchAbstract where (Status & 128) <> 0 and DispatchID in (Select Original_Reference from DispatchAbstract where DispatchDate BETWEEN @FROMDATE AND @TODATE)
union 
Select DispatchID from DispatchAbstract where Original_Reference <> N'' and DispatchDate BETWEEN @FROMDATE AND @TODATE

OPEN Disp_Cursor
FETCH FROM Disp_Cursor Into @Disp_ID

	WHILE @@FETCH_STATUS = 0  
	BEGIN  
         
	 SET @sql = N'Update #temp1 Set Original_Ref = 1 Where DispatchID  = '''+ cast(@Disp_ID as nvarchar)  +''''
	 print @sql
         exec sp_executesql @sql  

	 FETCH NEXT FROM Disp_Cursor Into @Disp_ID
	END
select * from #temp1
Close Disp_Cursor
DeAllocate Disp_Cursor
drop table #temp1


