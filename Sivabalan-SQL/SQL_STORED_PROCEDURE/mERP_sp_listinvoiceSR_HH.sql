Create procedure mERP_sp_listinvoiceSR_HH
(@fromdate datetime,
@todate datetime, 
@CUSTOMER nvarchar(15) = '%',
@SalesMan nVarchar(500) = N'',  
@Beat nVarchar(500) = N'',  
@Channel Int = 0,  
@SubChannel Int =0,
@nFlag Int = 1)   
As
Begin


--nFlag 1 For SalesReturn Saleable
--nFlag 2 For SalesReturn Damage

Create Table #tblSalesman(SalesManID Int)      
Create Table #tblBeat(BeatID Int)      
Create Table #tblChannel(ChannelID Int)  
Create Table #tblSubChannel(SubChannelID Int)  

Declare @SalesmanID Int


Create Table #tmpSR(DocumentID int, CustomerID nVarchar(500), Company_Name nVarchar(500), ReturnNumber nVarchar(500), 
DocumentDate DateTime,TotalValue Decimal(18,6),ReturnType Int,BillID Int, CatGrp nVarchar(1000), SalesmanID Int, CatGrpID nVarchar(100)
, CategoryGroup int)
      
If @SalesMan = N''      
    Insert InTo #tblSalesman Select SalesmanID From SalesMan Where Active = 1      
Else      
	Insert InTo #tblSalesman Select * From sp_SplitIn2Rows(@SalesMan,N',')       
  
      
If @Beat = N''       
	Insert InTo #tblBeat Select BeatID From Beat Where Active = 1      
Else  
	Insert InTo #tblBeat Select * From sp_SplitIn2Rows(@Beat,N',')      
    

If @Channel = 0 
	Begin 
		Insert Into #tblChannel Values(0)
		Insert Into #tblChannel Select ChannelType From Customer_Channel Where Active = 1    
	End
Else  
	Insert Into #tblChannel Values(@Channel)  
   

If @SubChannel = 0  
	Begin
		Insert Into #tblSubChannel Values(0)
		Insert Into #tblSubChannel Select  SubChannelID From SubChannel Where Active =1    
	End
Else  
	Insert Into #tblSubChannel Values(@SubChannel)  
  
Insert Into #tmpSR  
select 
	DocumentID, 
	C.CustomerID, C.Company_Name, ReturnNumber, DocumentDate,Total_Value,  
	ReturnType, BillID, '' CatGrp,
	 case when (SR.SalesmanID in 
	(select DSD.Salesmanid from DSType_details DSD , tbl_mERP_DSTypeCGMapping TDSCGM 
        Where DSD.dstypeid=TDSCGM.dstypeid and TDSCGM.GroupId=IsNull(SR.CategoryGroupID,0))) then SR.SalesmanID
    else (select top 1 DSD.Salesmanid from DSType_details DSD,tbl_mERP_DSTypeCGMapping TDSCGM ,Beat_salesman BS
          Where  DSD.dstypeid=TDSCGM.dstypeid and TDSCGM.GroupId=IsNull(SR.CategoryGroupID,0)
          and   BS.salesmanid=DSD.Salesmanid and BS.CustomerID=SR.OutletID order by DSD.Salesmanid
    ) end 'SalesmanID',''
	, IsNull(SR.CategoryGroupID,0)
from 
	Stock_Return SR
	Inner Join Customer C On SR.OutletID = C.CustomerID
	Left Outer Join ProductCategoryGroupAbstract PCG On SR.CategoryGroupID = PCG.GroupID
where SR.DocumentDate between @fromdate and @todate and SR.ReturnType = @nFlag And C.CustomerID like @CUSTOMER and Processed = 3
	And Isnull(SR.BeatID,0) In (Select  BeatId From #tblBeat) And Isnull(SR.SalesmanID,0) In (Select SalesmanID From #tblSalesman)  
	And IsNull(C.ChannelType,0) In (Select ChannelID From #tblChannel) And IsNull(C.SubChannelID,0) In (Select SubChannelID From #tblSubChannel)  
  
Update  #tmpSR Set CatGrpID = dbo.fn_Get_GrpMappedForSalesman(#tmpSR.SalesmanID)

Create Table #tmpSR2(CustomerID nVarchar(500), Company_Name nVarchar(500), ReturnNumber nVarchar(500), 
DocumentDate DateTime, TotalValue Decimal(18,6), ReturnType Int, BillID Int, CatGrp nVarchar(1000), 
CatGrpID nVarchar(100), SalesmanID Int, SalesmanGrpID nVarchar(1000) )


Insert Into #tmpSR2
Select Distinct 
	CustomerID, Company_Name, ReturnNumber, DocumentDate,  Sum(TotalValue), ReturnType,  
	 -- BillID, '', '', CatGrp, CatGrpID,  SalesmanID, '' 
	BillID, CatGrp, CatGrpID,  SalesmanID, '' 
From #tmpSR  
Group BY CustomerID, Company_Name, ReturnNumber, DocumentDate,
	ReturnType, BillID, SalesmanID, CatGrpID, CatGrp


Declare @SalesmanCategoryGrpID nVarchar(1000)
Declare @RtnNo nVarchar(500)


Declare Cur_SR Cursor For
Select ReturnNumber, SalesmanID From #tmpSR2
Open Cur_SR 
Fetch From Cur_SR Into @RtnNo, @SalesmanID
While @@Fetch_Status = 0
Begin
	Set @SalesmanCategoryGrpID = ''

	Select @SalesmanCategoryGrpID = @SalesmanCategoryGrpID + cast(CategoryGroup as nVarchar(100)) + ',' from #TmpSR
	Where SalesmanID = @SalesmanID and ReturnNumber = @RtnNo

	select @SalesmanCategoryGrpID = (case when @SalesmanCategoryGrpID ='' then '' else left(@SalesmanCategoryGrpID,len(@SalesmanCategoryGrpID)-1) end) -- 'SalesmanGrpID'

	Update #tmpSR2 Set SalesmanGrpID = @SalesmanCategoryGrpID Where SalesmanID = @SalesmanID and ReturnNumber = @RtnNo

	Fetch Next From Cur_SR Into @RtnNo, @SalesmanID
End
Close Cur_SR
Deallocate Cur_SR


Update  #tmpSR2 Set CatGrp = dbo.mERP_fn_Get_GroupNames(#tmpSR2.SalesmanGrpID)


Select CustomerID, Company_Name, ReturnNumber, DocumentDate,  Sum(TotalValue), ReturnType,  
	  BillID, '', '', CatGrp, CatGrpID,  SalesmanID, SalesmanGrpID
From #tmpSR2  
Group BY CustomerID, Company_Name, ReturnNumber, DocumentDate,
	ReturnType, BillID, SalesmanID, CatGrpID, CatGrp, SalesmanGrpID


Drop Table #tblSalesman      
Drop Table #tblBeat
Drop Table #tblChannel
Drop Table #tblSubChannel
Drop Table #tmpSR
Drop Table #tmpSR2

End
