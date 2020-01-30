CREATE PROCEDURE sp_list_Dispatch_DocLU (@FromDocID int, @ToDocID int,@DocumentRef nvarchar(510)=N'')
AS

declare @sql as nvarchar(3000)
declare @Disp_ID as int

Create Table #temp1 (DispatchID int, DispatchDate datetime, CustID nvarchar(255), 
Custname nvarchar(255), Status int, DocumentID int, Original_Ref int,DocumentReference nvarchar(255)) 

If Len(@DocumentRef)=0 
begin
	insert into #temp1 (DispatchID, DispatchDate, CustID, Custname, Status, DocumentID,DocumentReference)
	SELECT DispatchID, DispatchDate, DispatchAbstract.CustomerID, 
	Customer.Company_Name, Status, DocumentID,DocRef
	FROM DispatchAbstract, Customer
	WHERE DispatchAbstract.CustomerID = Customer.CustomerID 
	and (DocumentID between @FromDocID and @ToDocID
	OR (Case Isnumeric(docref) When 1 then Cast(docref as int)end) between @FromDocID And @ToDocID) 
	ORDER BY Customer.Company_Name, DispatchDate, DispatchID
	
	Declare Disp_Cursor Cursor for
	Select DispatchID from DispatchAbstract where (Status & 128) <> 0 and DispatchID in 
	(Select Original_Reference from DispatchAbstract where (DocumentID between @FromDocID and @ToDocID
	OR (Case Isnumeric(docref) When 1 then Cast(docref as int)end) between @FromDocID And @ToDocID))
	union 
	Select DispatchID from DispatchAbstract where Original_Reference <> N'' and (DocumentID between @FromDocID and @ToDocID
	OR (Case Isnumeric(docref) When 1 then Cast(docref as int)end)between @FromDocID And @ToDocID) 
	
	OPEN Disp_Cursor
	FETCH FROM Disp_Cursor Into @Disp_ID
	
		WHILE @@FETCH_STATUS = 0  
		BEGIN  
	         
		 SET @sql = N'Update #temp1 Set Original_Ref = 1 Where DispatchID  = '''+ cast(@Disp_ID as nvarchar)  +''''
	         exec sp_executesql @sql  
	
		 FETCH NEXT FROM Disp_Cursor Into @Disp_ID
		END
End
Else
Begin
	insert into #temp1 (DispatchID, DispatchDate, CustID, Custname, Status, DocumentID,DocumentReference)
	SELECT DispatchID, DispatchDate, DispatchAbstract.CustomerID, 
	Customer.Company_Name, Status, DocumentID,DocRef
	FROM DispatchAbstract, Customer
	WHERE DispatchAbstract.CustomerID = Customer.CustomerID 
	AND docref LIKE  @DocumentRef + N'%' + N'[0-9]'
	And (CAse ISnumeric(Substring(docref,Len(@DocumentRef)+1,Len(docref))) 
	When 1 then Cast(Substring(docref,Len(@DocumentRef)+1,Len(docref))as int)End) BETWEEN @FromDocID and @ToDocID
	ORDER BY Customer.Company_Name, DispatchDate, DispatchID
	
	Declare Disp_Cursor Cursor for
	Select DispatchID from DispatchAbstract where (Status & 128) <> 0 and DispatchID in (Select Original_Reference from DispatchAbstract 
	where docref LIKE  @DocumentRef + N'%' + N'[0-9]'
	And (CAse ISnumeric(Substring(docref,Len(@DocumentRef)+1,Len(docref))) 
	When 1 then Cast(Substring(docref,Len(@DocumentRef)+1,Len(docref))as int)End) BETWEEN @FromDocID and @ToDocID)
	union 
	Select DispatchID from DispatchAbstract where Original_Reference <> N'' and 
	docref LIKE  @DocumentRef + N'%' + N'[0-9]'
	And (CAse ISnumeric(Substring(docref,Len(@DocumentRef)+1,Len(docref))) 
	When 1 then Cast(Substring(docref,Len(@DocumentRef)+1,Len(docref))as int)End) BETWEEN @FromDocID and @ToDocID
	
	OPEN Disp_Cursor
	FETCH FROM Disp_Cursor Into @Disp_ID
	
		WHILE @@FETCH_STATUS = 0  
		BEGIN  
	         
		 SET @sql = N'Update #temp1 Set Original_Ref = 1 Where DispatchID  = '''+ cast(@Disp_ID as nvarchar)  +''''
	         exec sp_executesql @sql  
	
		 FETCH NEXT FROM Disp_Cursor Into @Disp_ID
		END

End	
select * from #temp1
Close Disp_Cursor
DeAllocate Disp_Cursor
drop table #temp1




