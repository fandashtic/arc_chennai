CREATE Procedure spr_CategorywiseSKUwiseDSwiseBeatwiseNonProductiveOutlets_Detail  
(@ItemCode nVarChar(2550), @Salesman nVarchar(2550),   
 @Beat nVarchar(2550), @Merchandise nVarchar(2550),@FromDate DateTime, @ToDate DateTime)  
AS  
Declare @Delimeter as Char(1)              
Set @Delimeter=Char(15)              
Declare @MerchandiseName nvarchar(150)
Declare @SQL nvarchar(1000)

Create Table #tmpResults([CustomerID] nvarchar(15)  Collate SQL_Latin1_General_CP1_CI_AS,[DS Name] nvarchar(100)  Collate SQL_Latin1_General_CP1_CI_AS,[Beat Name] nvarchar(255)  Collate SQL_Latin1_General_CP1_CI_AS,[Customer Name] nvarchar(150) Collate SQL_Latin1_General_CP1_CI_AS)

Create table #tmpSalesMan(SalesmanID Int)        
if @Salesman = N'%'         
   Insert into #tmpSalesMan select SalesmanID from Salesman        
Else        
   Insert into #tmpSalesMan Select SalesmanID From Salesman Where   
   Salesman_Name In (select * from dbo.sp_SplitIn2Rows(@Salesman,@Delimeter))  
  
Create table #tmpBeat(BeatID Int)        
if @Beat = N'%'        
   Insert into #tmpBeat select BeatID from Beat        
Else        
   Insert into #tmpBeat Select BeatID From Beat Where   
   [Description] In (select * from dbo.sp_SplitIn2Rows(@Beat,@Delimeter))  


Create Table #tmpMerchandise(MerchandiseType nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, CustomerID nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS)  

If @Merchandise = N'%'    
 Insert InTo #tmpMerchandise
 Select Merchandise.Merchandise,Isnull(CustMerchandise.CustomerID,'') From Merchandise  left outer join CustMerchandise
 on  Merchandise.MerchandiseID = CustMerchandise.MerchandiseID
 Union
 Select '', Customer.CustomerID From customer
 Where CustomerID not in (Select customerID from CustMerchandise)
 Order By 1
Else    
 Insert into #tmpMerchandise 
 Select Merchandise.Merchandise,Isnull(CustMerchandise.CustomerID,'') From Merchandise,CustMerchandise
 Where Merchandise.MerchandiseID = CustMerchandise.MerchandiseID
 and Merchandise.merchandise in (select * from dbo.sp_SplitIn2Rows(@Merchandise, @Delimeter)) 
 
select distinct BeatID,SalesmanID,CustomerID into #tmpBeatSalesman from Beat_Salesman  
  
Insert Into #tmpResults 
Select cus.CustomerID, "DS Name" = sm.Salesman_Name, "Beat Name" = bt.[Description],   
"Customer Name" = cus.Company_Name From Salesman sm,   
Beat bt, Customer cus, #tmpBeatSalesman bsm
Where bsm.SalesmanID = sm.SalesmanID And bsm.BeatID = bt.BeatID And   
cus.CustomerID = bsm.CustomerID And 
Cus.CustomerID in (select CustomerID from  #tmpMerchandise) and 
bsm.CustomerID Not In   
(Select CustomerID From InvoiceAbstract inva, InvoiceDetail invd   
Where inva.InvoiceID = invd.InvoiceID And   
InvoiceDate Between @FromDate And @ToDate And   
InvoiceType In (1, 3) And IsNull(Status, 0) & 192 = 0   
And invd.Product_Code = @ItemCode)  
And bsm.BeatID In (Select BeatID From #tmpBeat) And bsm.SalesmanID   
In (Select SalesmanID From #tmpSalesMan) And bsm.CustomerID != N''  
And cus.Active = 1  

 If @Merchandise =N'%' 
   Declare Merchandise Cursor Keyset For  
	 select Merchandise from Merchandise order by 1
 Else
   Declare Merchandise Cursor Keyset For  
   select * from dbo.sp_SplitIn2Rows(@Merchandise, @Delimeter)
	 
 Open Merchandise    
 Fetch From Merchandise Into @MerchandiseName    
 While @@Fetch_Status = 0    
 Begin    
 Set @SQL = 'Alter table #tmpResults Add [' + @MerchanDiseName + '] nvarchar(50) Collate SQL_Latin1_General_CP1_CI_AS'
 Exec(@SQL)
 
 Set @SQL = 'Update #tmpResults Set [' + @MerchanDiseName + '] = ''No'''
 exec(@SQL)


 Set @SQL = 'Update #tmpResults Set [' + @MerchanDiseName + '] = ''Yes'''
 Set @SQL = @SQL + ' From CustMerchandise,Merchandise '
 Set @SQL = @SQL + ' Where CustMerchandise.MerchandiseID = Merchandise.MerchandiseID '
 Set @SQL = @SQL + ' and #tmpResults.CustomerID = CustMerchandise.CustomerID '
 Set @SQL = @SQL + ' and Merchandise.Merchandise = ''' + @MerchanDiseName + ''''
 Exec(@SQL)

 Set @SQL = ''
 Fetch Next From Merchandise Into @MerchandiseName
 End    
 Close Merchandise    
 DeAllocate Merchandise  

 
 Set @SQL = 'Select * from #tmpResults'
 Exec(@SQL)
 
Drop Table #tmpBeatSalesman  
Drop Table #tmpSalesMan  
Drop Table #tmpBeat  
  
