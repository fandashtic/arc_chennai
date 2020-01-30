CREATE PROCEDURE sp_list_Invoices_ITC (          
  @FromDate DateTime,            
  @ToDate DateTime,            
  @SalesMan NVarChar(4000) = N'',            
  @Beat NVarChar(4000) = N'',            
  @FromDocID int = 0,            
  @ToDocID int = 0,          
  @OrderBy int = 2,      
  @DocumentRef nvarchar(510)=N'')            
AS            

Create Table #TempSalesman(SalesManID Int)            
Create Table #TempBeat(BeatID Int)   
Create Table #tmpInvoiceID(InvoiceID Int)           

Select @FromDocID = DocumentID From InvoiceAbstract Where InvoiceID = @FromDocID  
Select @ToDocID = DocumentID From InvoiceAbstract Where InvoiceID = @ToDocID  
  
Insert Into #tmpInvoiceID  
  Select InvoiceID From InvoiceAbstract Where DocumentID Between @FromDocID and @ToDocID  
  
if (Select Count(*) From #tmpInvoiceID ) = 0  
Begin
	Insert Into #tmpInvoiceID VALUES(0)  
	Insert Into #tmpInvoiceID Select InvoiceID From InvoiceAbstract Where InvoiceDate Between @FromDate And @ToDate
End
            
If @SalesMan = N''            
 Begin            
  Insert InTo #TempSalesman Values(0)            
  Insert InTo #TempSalesman Select SalesmanID From SalesMan --Where Active = 1            
 End            
Else            
 Insert InTo #TempSalesman Select * From sp_SplitIn2Rows(@SalesMan,N',')             
            
If @Beat = N''             
 Begin            
  Insert InTo #TempBeat Values(0)            
  Insert InTo #TempBeat Select BeatID From Beat --Where Active = 1            
 End            
Else            
  Insert InTo #TempBeat Select * From sp_SplitIn2Rows(@Beat,N',')            
                
    
SELECT InvoiceID,DocumentID, DocReference, Customer.Company_Name, InvoiceDate, NetValue,             
S.SalesMan_Name,B.Description,Case When InvoiceAbstract.GroupID = '0' Then 'All Categories'
	Else (Select dbo.mERP_fn_Get_GroupNames(InvoiceAbstract.GroupID) ) End        
, GSTFlag, GSTFullDocID
FROM InvoiceAbstract
Inner Join  Customer On InvoiceAbstract.CustomerID = Customer.CustomerID          
Left Outer Join  SalesMan S On InvoiceAbstract.SalesManID = S.SalesManID          
Left Outer Join  Beat B On InvoiceAbstract.BeatID = B.BeatID          
WHERE Isnull(InvoiceAbstract.BeatID,0) In (Select  BeatId From #TempBeat)                
And Isnull(InvoiceAbstract.SalesmanID,0) In (Select SalesmanID From #TempSalesman)              
--AND InvoiceAbstract.GroupID *= CG.GroupID        
AND (InvoiceAbstract.InvoiceDate between @FromDate and @ToDate)          
--AND (DocumentID BETWEEN @FromDocID AND @ToDocID           
--AND (InvoiceID BETWEEN @FromDocID AND @ToDocID           
AND (InvoiceID In (Select * From #tmpInvoiceID)
--OR (Case Isnumeric(DocReference) When 1 then Cast(DocReference as Decimal(18,6))Else N'0' end) between @FromDocID And @ToDocID)            
OR (Case Isnumeric(DocReference) When 1 then Cast(DocReference as Decimal(18,6))Else N'0' end) In (Select * From #tmpInvoiceID))              
And InvoiceType In (1, 3)          
And (IsNull(Status,0) & 128) = 0           
ORDER BY (Case @OrderBy   When 0 then Cast(Customer.Company_Name as nvarchar)      
  When 1 then Cast(DocReference as nvarchar)      
  Else Cast(DocumentID as nvarchar)End),InvoiceAbstract.InvoiceDate            

Drop Table #TempSalesman
Drop Table #TempBeat
Drop Table #tmpInvoiceID


