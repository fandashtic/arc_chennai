Create procedure sp_acc_rpt_list_SMCGICustomer_OutStanding_ITC_OCG(  
  @Salesman nVarchar(2550),    
  @Beat nVarchar(2550),     
  @CategoryGrouptype nVarchar(100),     
  @CategoryGroup nVarchar(2550),     
  @FromDate datetime,    
  @ToDate datetime)    
as    
Declare @Delimeter as nChar(1)      
Declare @GroupId Int  
  
Set @Delimeter=Char(15)      
  
Create table #tmpBeat(BeatId Int )      
Create table #tmpSalesMan(SalesManId Int)      
Create table #tmpCategoryGroup(GroupId Int )      
  
if @Beat=N'%'      
Begin  
   Insert into #tmpBeat values (0)  
   Insert into #tmpBeat select BeatId from Beat      
End  
Else      
   Insert into #tmpBeat Select BeatID From Beat Where Description In (select * from dbo.sp_SplitIn2Rows(@Beat,@Delimeter))      
  
if @Salesman=N'%'       
Begin  
   Insert into #tmpSalesMan values (0)  
   Insert into #tmpSalesMan select SalesmanId from SalesMan      
End  
Else      
   Insert into #tmpSalesMan Select SalesmanId From SalesMan Where SalesMan_Name In(select * from dbo.sp_SplitIn2Rows(@Salesman,@Delimeter))      
  
if @CategoryGroup=N'%'       
Begin  
   --Insert into #tmpCategoryGroup Values (0)  
   --Insert into #tmpCategoryGroup Select GroupId from Productcategorygroupabstract where OCGtype = Case when @CategoryGrouptype = 'Operational' then 1 Else 0 End 
	If @CategoryGrouptype <> 'Operational'
		Insert InTo #tmpCategoryGroup select distinct PCG.GroupID from tblcgdivmapping cg ,ProductCategoryGroupAbstract PCG where CG.CategoryGroup=PCG.GroupName
	else
		Insert InTo #tmpCategoryGroup Select Distinct GroupID From ProductCategoryGroupAbstract where OCGtype = 1 
End  
Else      
   Insert into #tmpCategoryGroup Select GroupId from ProductCategoryGroupAbstract Where GroupName In(select * from dbo.sp_SplitIn2Rows(@CategoryGroup,@Delimeter))      
  
create table #temp    
 (    
  SalesmanID int not null,    
  BeatID int not null,    
  GroupId int not null,  
  Balance Decimal(18,6) not null,    
  CustomerID nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS not null    
 )    
   
Create Table #TmpItem(GroupId Int, Product_Code nVarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS)   
Declare CursorGroup Cursor For Select Distinct GroupID From #tmpCategoryGroup order by GroupID 
Open CursorGroup  
Fetch From CursorGroup Into @GroupID  
While @@Fetch_Status = 0      
  Begin      
   Insert Into #TmpItem Select @GroupID,Product_Code From dbo.fn_Get_CGItems(@GroupID,@CategoryGrouptype)   
   Fetch Next From CursorGroup Into @GroupID  
  End  
Close CursorGroup  
DeAllocate CursorGroup  
  
-------------------------------  
-- Select * From #TmpItem  
------------------------------  
  
--  insert into #temp    
--  select  ISNULL(InvoiceAbstract.SalesmanID, 0), IsNull(InvoiceAbstract.BeatID, 0),     
--  IsNull(T.GroupId,0),  
--  ISNULL(Sum(InvoiceAbstract.Balance), 0), CustomerID    
--  from InvoiceAbstract, invoicedetail idl, #tmpBeat, #tmpSalesman, #tmpCategoryGroup,   
--  #TmpItem T  
--  where InvoiceAbstract.InvoiceID = idl.InvoiceID And  
--  idl.Product_Code = T.Product_Code And InvoiceAbstract.Status & 128 = 0 and    
--  InvoiceAbstract.Balance > 0 and    
--  InvoiceAbstract.InvoiceType in (1, 3) and    
--  InvoiceAbstract.InvoiceDate between @FromDate and @ToDate And    
--  IsNull(InvoiceAbstract.SalesmanID, 0) = #tmpSalesman.SalesmanID And    
--  IsNull(InvoiceAbstract.BeatID, 0) = #tmpBeat.BeatID And    
--  IsNull(T.GroupID, 0) = #tmpCategoryGroup.GroupId And    
--  ISNull(T.GroupId,0) <> 0  
--  Group by InvoiceAbstract.BeatID, InvoiceAbstract.SalesmanID,   
--  T.GroupId,InvoiceAbstract.CustomerID    
  
----------------------------------  
-- Select * From #temp  
----------------------------------  
   
 Insert Into #temp    
 Select   
 Case IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos Where dsos.InvoiceID = InvoiceAbstract.InvoiceID), '')  
 When '' Then ISNULL(InvoiceAbstract.SalesmanID, 0) Else   
 IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos Where dsos.InvoiceID = InvoiceAbstract.InvoiceID), '') End,  
  
 Case IsNull((Select Top 1 MappedBeatID From tbl_merp_dsostransfer dsos Where dsos.InvoiceID = InvoiceAbstract.InvoiceID), '')  
 When '' Then  IsNull(InvoiceAbstract.BeatID, 0) Else  
 IsNull((Select Top 1 MappedBeatID From tbl_merp_dsostransfer dsos Where dsos.InvoiceID = InvoiceAbstract.InvoiceID), '') End,  
     
 IsNull(T.GroupId,0) ,  
 IsNull(Sum((Idt.Amount /InvoiceAbstract.NetValue) * InvoiceAbstract.Balance), 0), CustomerID    
 from InvoiceAbstract,  #tmpBeat, #tmpSalesman, #tmpCategoryGroup P,  
 #tmpItem T, InvoiceDetail IDt    
 where InvoiceAbstract.Status & 128 = 0 and    
 InvoiceAbstract.Balance > 0 and    
 InvoiceAbstract.InvoiceType in (1, 3) and    
 InvoiceAbstract.InvoiceDate between @FromDate and @ToDate And    
 InvoiceAbstract.Invoiceid = Idt.Invoiceid And  
 Idt.Product_Code = T.Product_Code And  
 P.GroupId = T.GroupId And  
  
Case IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos   
Where dsos.InvoiceID = InvoiceAbstract.InvoiceID), '')  
When '' Then ISNULL(InvoiceAbstract.SalesmanID, 0) Else   
IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos   
Where dsos.InvoiceID = InvoiceAbstract.InvoiceID), '') End = #tmpSalesman.SalesmanID And   
  
Case IsNull((Select Top 1 MappedBeatID From tbl_merp_dsostransfer dsos   
Where dsos.InvoiceID = InvoiceAbstract.InvoiceID), '')  
When '' Then  IsNull(InvoiceAbstract.BeatID, 0) Else  
IsNull((Select Top 1 MappedBeatID From tbl_merp_dsostransfer dsos   
Where dsos.InvoiceID = InvoiceAbstract.InvoiceID), '') End = #tmpBeat.BeatID And    
  
 IsNull(T.GroupId,0) <> 0  
 Group by InvoiceAbstract.BeatID, InvoiceAbstract.SalesmanID,   
 InvoiceAbstract.CustomerID, IsNull(T.GroupId,0), InvoiceAbstract.InvoiceId  
  
----------------------------------  
-- Select * From #temp  
----------------------------------  
    
--  Insert into #temp    
--  select ISNULL(InvoiceAbstract.SalesmanID, 0), IsNull(InvoiceAbstract.BeatID, 0),     
--  IsNull(InvoiceAbstract.GroupId,0),  
--   0 - ISNULL(Sum(InvoiceAbstract.Balance), 0), CustomerID    
--  FROM InvoiceAbstract, #tmpSalesman, #tmpBeat, #tmpCategoryGroup  
--  WHERE ISNULL(Balance, 0) > 0 and InvoiceType In (4) AND    
--  (Status & 128) = 0 AND    
--  InvoiceDate Between @FromDate AND @ToDate And    
--  IsNull(InvoiceAbstract.BeatID, 0) = #tmpBeat.BeatID And    
--  IsNull(InvoiceAbstract.SalesmanID, 0) = #tmpSalesman.SalesmanID And    
--  IsNull(InvoiceAbstract.GroupID, 0) = #tmpCategoryGroup.GroupId And    
--  IsNull(InvoiceAbstract.GroupId,0) <> 0  
--  Group by InvoiceAbstract.BeatID, InvoiceAbstract.SalesmanID,   
--  InvoiceAbstract.GroupId,InvoiceAbstract.CustomerID    
     
 Insert into #temp    
 select --ISNULL(InvoiceAbstract.SalesmanID, 0), IsNull(InvoiceAbstract.BeatID, 0),     
 Case IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos Where dsos.InvoiceID = InvoiceAbstract.InvoiceID), '')  
 When '' Then ISNULL(InvoiceAbstract.SalesmanID, 0) Else   
 IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos Where dsos.InvoiceID = InvoiceAbstract.InvoiceID), '') End,  
  
 Case IsNull((Select Top 1 MappedBeatID From tbl_merp_dsostransfer dsos Where dsos.InvoiceID = InvoiceAbstract.InvoiceID), '')  
 When '' Then  IsNull(InvoiceAbstract.BeatID, 0) Else  
 IsNull((Select Top 1 MappedBeatID From tbl_merp_dsostransfer dsos Where dsos.InvoiceID = InvoiceAbstract.InvoiceID), '') End,  
  
 IsNull(T.GroupId,0) ,  
  0 -  IsNull(Sum((Idt.Amount /InvoiceAbstract.NetValue) * InvoiceAbstract.Balance), 0), CustomerID    
 FROM InvoiceAbstract, #tmpSalesman, #tmpBeat, #tmpCategoryGroup P,  
 InvoiceDetail Idt, #tmpItem T  
 WHERE ISNULL(Balance, 0) > 0 and InvoiceType In (4) AND    
 (Status & 128) = 0 AND    
 InvoiceDate Between @FromDate AND @ToDate And    
-- IsNull(InvoiceAbstract.BeatID, 0) = #tmpBeat.BeatID And    
 InvoiceAbstract.Invoiceid = Idt.Invoiceid And  
 Idt.Product_Code = T.Product_Code And  
 P.GroupId = T.GroupId And  
  
Case IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos   
Where dsos.InvoiceID = InvoiceAbstract.InvoiceID), '')  
When '' Then ISNULL(InvoiceAbstract.SalesmanID, 0) Else   
IsNull((Select Top 1 MappedSalesmanID From tbl_merp_dsostransfer dsos   
Where dsos.InvoiceID = InvoiceAbstract.InvoiceID), '') End = #tmpSalesman.SalesmanID And   
  
Case IsNull((Select Top 1 MappedBeatID From tbl_merp_dsostransfer dsos   
Where dsos.InvoiceID = InvoiceAbstract.InvoiceID), '')  
When '' Then  IsNull(InvoiceAbstract.BeatID, 0) Else  
IsNull((Select Top 1 MappedBeatID From tbl_merp_dsostransfer dsos   
Where dsos.InvoiceID = InvoiceAbstract.InvoiceID), '') End = #tmpBeat.BeatID And    
  
-- IsNull(InvoiceAbstract.SalesmanID, 0) = #tmpSalesman.SalesmanID And    
 IsNull(T.GroupId,0) <> 0  
 Group by InvoiceAbstract.BeatID, InvoiceAbstract.SalesmanID,   
 IsNull(T.GroupId,0),InvoiceAbstract.CustomerID, InvoiceAbstract.InvoiceId   
  
----------------------------------  
-- Select * From #temp  
----------------------------------  
  
 Select Cast(#temp.SalesmanID as nVarchar) + N';' + Cast(#temp.BeatID as nVarchar)+ N';' + Cast(#temp.GroupID as nVarchar)+ N';' + @CategoryGrouptype,    
 "Salesman" = IsNull(Salesman.Salesman_Name, N'Others'),     
 "Beat" = IsNull(Beat.Description, N'Others'),     
 "Category Group" = IsNull(Productcategorygroupabstract.GroupName, N'All Category Groups'),     
 "Net Outstanding (%c)" = SUM(Balance)  from #temp
 Left Outer Join Salesman On  #temp.SalesmanID = Salesman.SalesmanID
 Left Outer Join Beat On #temp.BeatID = Beat.BeatID
 Left Outer Join Productcategorygroupabstract  On #temp.GroupID = Productcategorygroupabstract.GroupID      
 Group By #temp.SalesmanID, Salesman.Salesman_Name, #temp.BeatID, Beat.Description ,  
 #temp.GroupId, ProductCategoryGroupAbstract.Groupname   
  
 Drop table #tmpItem  
 Drop table #temp  
  
