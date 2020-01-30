Create Procedure mERP_Sp_GetGRNTransactionDate(@ProductHierarchy nvarchar(255),@Category nvarchar(2550))
As
Declare @EffDate as datetime
Declare @Sysdate as datetime
Declare @GRNDate as datetime
declare @ProdHierarchy as nvarchar(255)
Declare @GRNID as int
Begin
	Create table #tempCategory(CategoryID int,Status int)
	Create table #TmpGRN(GRNID int)

    If @ProductHierarchy=N'Sub_Category'
        select @ProdHierarchy=HierarchyName from Itemhierarchy where HierarchyID=3
    Else if @ProductHierarchy=N'Division'
		select @ProdHierarchy=HierarchyName from Itemhierarchy where HierarchyID=2

	exec dbo.GetLeafCategories @ProdHierarchy,@Category

    insert into #TmpGRN
	select Distinct GRNID from
	Items,
	GRNDetail
	where Items.CategoryID in (select CategoryID from #tempCategory)
	and GRNDetail.Product_Code=Items.Product_Code
    and Items.Active=1

	If Not Exists(select * from MarginAbstract) or Not Exists (select * from MarginDetail where CategoryID in (select CategoryID from ItemCategories where Category_Name=@Category))
    Begin
       Set @EffDate=Getdate()-1
    End
	Else
	Begin     		
		select @EffDate=Isnull(EffectiveDate,Getdate()-1) from MarginDetail 
        where MarginID in (select Max(MarginID) from MarginAbstract)
        and CategoryID in (select CategoryID from ItemCategories where Category_Name=@Category)
    End
	
	select @GRNID=isnull(Max(GRNID),0) from GRNAbstract where GRNID in (select GRNID from #TmpGRN)
    and (GRNStatus & 96) =0 

    If @GRNID=0
	   select @EffDate
    Else
       select GRNDate from  GRNAbstract where GRNID=@GRNID	
    	
	truncate table #tempCategory
	truncate table #tempCategory
	drop table #tempCategory
    drop table #TmpGRN
End
