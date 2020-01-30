Create Procedure sp_han_updateSR (@ReturnNumber as nvarchar(50), @status int)        
As
declare @GroupName nVarchar(100)
declare @CustName  nVarchar(300)
declare @msg nvarchar(500)

Declare @NoRecs as Integer      

Declare @SalesManID int
Declare @CustId nVarchar(1000)
Select @SalesManID = SalesmanID, @CustId = OutletID from Stock_Return where ReturnNumber = @ReturnNumber
and Processed = 0


If @Status=2    
    Begin    
        Update Stock_Return set Processed = @Status Where isnull(ReturnNumber,'') =isnull(@ReturnNumber,'') and Processed=0      
        Set @NoRecs = @@RowCount   
		Goto Done 
    End    
Else    
Begin
    -- Salesman handle Specific category
    create table #TmpSalesmanCat ( DocumentId int, ReturnNumber nVarchar(100), SalesManID Int,GroupName nVarchar(100),GroupID int)
    insert into #TmpSalesmanCat
    Select distinct documentid, IsNull(SR.ReturnNumber,'') 'ReturnNumber'
    , case when (@SalesManID in 
    (select DSD.Salesmanid from DSType_details DSD inner join tbl_mERP_DSTypeCGMapping TDSCGM 
        on DSD.dstypeid=TDSCGM.dstypeid and TDSCGM.GroupId=IsNull(GD.GroupID,0))) then @SalesManID
    else (select top 1 DSD.Salesmanid from DSType_details DSD inner join tbl_mERP_DSTypeCGMapping TDSCGM 
        on DSD.dstypeid=TDSCGM.dstypeid and TDSCGM.GroupId=IsNull(GD.GroupID,0)
        inner join Beat_salesman BS on BS.salesmanid=DSD.Salesmanid and BS.CustomerID = Convert(nVarchar, @CustId) order by DSD.Salesmanid
    ) end 'SalesmanID'
    ,GD.GroupName
    ,GD.GroupId
    From STOCK_return SR 
    Inner Join Items ITM On SR.Product_Code = ITM.Product_Code
    Inner Join ProductCategoryGroupAbstract GD On GD.GroupId = Isnull(dbo.sp_han_GetCategoryGroup(ITM.CategoryId), 0)
	where Convert(nVarchar,SR.ReturnNumber) = @ReturnNumber and SR.Processed = 0
end


If exists(select * from #TmpSalesmanCat where SalesManID is null)
	begin
	set @GroupName=''
	set @CustName=''
	select @GroupName=@GroupName+dbo.fn_han_Get_GroupItems_SR(@ReturnNumber,GroupID) + ',' from #TmpSalesmanCat where SalesManID is null
	select @GroupName= left(@GroupName,len(@GroupName)-1)
	Select @CustId = OutletID, @SalesmanID = SalesmanID From Stock_Return Where ReturnNumber = @ReturnNumber
	select @CustName=isnull(Company_Name,'') from customer where customerid= @CustId
	set @msg='For SR-No Salesman attached to the Category Group(s) '+ @GroupName+' for Customer '+@CustId+' - '+@CustName
	Exec sp_han_InsertErrorlog @ReturnNumber, 3 , 'Error', 'Aborted' ,@msg, @SalesmanID
End

update stock_return set processed = 2 where ReturnNumber = @ReturnNumber and documentid in 
(select documentid from #TmpSalesmanCat where SalesManID is null )

Declare @GrpID int
Declare @DocumentID  int

Set @NoRecs = 0

Declare MyCur Cursor For
Select DocumentID, GroupId from #TmpSalesmanCat where ReturnNumber = @ReturnNumber and documentid in 
(select documentid from #TmpSalesmanCat where SalesManID Is Not null )
OPEN MyCur  
FETCH NEXT FROM MyCur into @DocumentID, @GrpID
WHILE (@@FETCH_STATUS <> -1)  
Begin
	update SR Set SR.Processed = 3, SR.CategoryGroupID = #TmpSalesmanCat.GroupID, SR.PendingQty = dbo.FN_Get_BaseUOMQty(SR.Product_Code, SR.UOM,SR.Quantity)
	From #TmpSalesmanCat Inner Join Stock_return SR On #TmpSalesmanCat.documentID = SR.DocumentID
	where SR.Processed = 0 and SR.DocumentID = @DocumentID and IsNull(#TmpSalesmanCat.SalesManID,'') <> ''
	Set @NoRecs = @NoRecs + @@RowCount  
FETCH NEXT FROM MyCur into @DocumentID, @GrpID
End
Close MyCur
Deallocate MyCur

drop table #TmpSalesmanCat

Done:
	Select @NoRecs 'rowcnt'  


