CREATE FUNCTION Fn_Get_DSMetrics()  
RETURNS @DSMetrics TABLE ([SalesmanID] Int, [Group_ID] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS, 
    [Level] Int, [Product_Code] nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS, 
    [Product_Name] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
    [SalesTarget] Decimal(18,6) Default(0), [Achievement] Decimal(18,6) Default(0), 
    [BillsCut] Decimal(18,6) Default(0), [LinesCut] Decimal(18,6) Default(0), 
    [ValidFromDate] Datetime, [ValidToDate] Datetime) 
AS      
BEGIN  

Declare @SalesmanID Int,@Groups nvarchar(1000),@PLevel Int,@Product_Code nvarchar(30),@Product_Code_view nvarchar(30),  
    @Product_Name nVarchar(255), @Target Int, @ValidFromDate Datetime, @ValidToDate Datetime,
    @Parm Int, @Frequency Int, @SlabUOM nvarchar(100), @PM_Groups_ID Int

Declare @PM_Groups Table (ID Int Identity (1,1), SalesmanID Int, 
    Groups nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, PLevel Int, 
    Product_Code nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS, 
    Product_Code_view nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS, 
    Product_Name nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
    Target Int, ValidFromDate Datetime, ValidToDate Datetime,
    Parm Int, Frequency Int)

Declare @PM Table (PM_Groups_ID Int, SalesmanID Int, PLevel Int, 
    Product_Code nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS, 
    Product_Code_view nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS, 
    Product_Name nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
    Target Int, ValidFromDate Datetime, ValidToDate Datetime,
    Parm Int, Frequency Int, CtgGroup nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS)

Declare @Itm Table ( CategoryGroup nvarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, 
					 DivName nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS, DivID int, 
					 SubCName nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS, SubCatID int, 
					 MktName nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS, MktSKUID int,
					 Product_Code nvarchar(510) COLLATE SQL_Latin1_General_CP1_CI_AS)

Declare @I Table ( SalesmanId Int, InvoiceId Int, InvoiceType Int, InvoiceDate Datetime, 
    ItemCode nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS, NetAmount Decimal(18, 5))

Declare @fromDate Datetime, @ToDate Datetime
Select @fromDate = dbo.StripDatefromtime(DateAdd(DD, 1, DateAdd(DD, (-1 * DatePart(DD, GetDate())), GetDate())))
    , @ToDate = GetDate()

Declare @tmpHHSM Table (SalesmanID int)
Insert into @tmpHHSM
Select dd.salesmanID From DSType_Details dd, DSType_Master dm 
Where dd.DSTypeID = dm.DSTypeID And dm.DSTypeName = 'Handheld DS' And dm.DSTypeValue = 'Yes' 

Insert Into @Itm
Select CG.CategoryGroup, ItcDiv.Category_Name DivName, ItcDiv.CategoryID DivID, 
ItcSubC.Category_Name SubCName, ItcSubC.CategoryID SubCatID, 
ItcMkt.Category_Name MktName, ItcMkt.CategoryID MktSKUID,
Itm.Product_Code 
From ItemCategories ItcDiv 
Join ItemCategories ItcSubC on ItcDiv.CategoryId = ItcSubC.ParentId 
Join ItemCategories ItcMkt on ItcSubC.CategoryId = ItcMkt.ParentId  
Join Items Itm on ItcMkt.CategoryId = Itm.CategoryId 
Join tblcgdivmapping CG on ItcDiv.Category_Name = CG.Division

Insert Into @I 
Select Ia.SalesmanId, Ia.InvoiceId, InvoiceType, [InvoiceDate] = convert(datetime, convert(varchar(10), Ia.InvoiceDate, 103), 103),
[ItemCode] = idt.Product_Code, 
[NetAmount] = Sum((Case When ia.InvoiceType = 4 Then -1 Else 1 End) * idt.Amount)
From InvoiceAbstract ia, InvoiceDetail idt,
DSType_Details Dd, DSType_Master dm 
Where ia.InvoiceID = idt.InvoiceID 
--And ia.InvoiceType In (1, 3, 4) And (IsNull(ia.Status, 0) & 192) = 0 
And ia.InvoiceDate Between @FromDate And @ToDate 
And	((ia.InvoiceType in(1, 3) and isnull(ia.Status,0) & 128 = 0)
		OR (ia.InvoiceType = 4 and isnull(ia.Status,0) & 32 = 0 and isnull(ia.Status,0) & 128 = 0))
And ia.SalesmanID = Dd.SalesmanID and dd.DSTypeID = dm.DSTypeID 
And dm.DSTypeName = 'Handheld DS' And dm.DSTypeValue = 'Yes'
Group by Ia.SalesmanId, Ia.InvoiceId, InvoiceType, convert(datetime, convert(varchar(10), Ia.InvoiceDate, 103), 103), 
Idt.Product_Code

Insert Into @PM_Groups 
Select [SalesmanID] = sl.SalesManID, [Groups] = pmm.CGGroups, [PLevel] = pmpf.ProdCat_Level, 
[Product_Code] = Case When pmpf.ProdCat_Level = 0 Then 'Overall' Else pmpf.ProdCat_Code End,  
[Product_Code_view] = Case When pmpf.ProdCat_Level = 0 Then 'Overall' 
                    When pmpf.ProdCat_Level = 5 Then pmpf.ProdCat_Code 
                    Else IsNull((Select Cast(CategoryID As nVarchar) From ItemCategories Where Category_Name = pmpf.ProdCat_Code), '') 
				 End,  
[Product_Name] = Case When pmpf.ProdCat_Level = 0 Then 'Overall' 
                    When pmpf.ProdCat_Level = 5 Then IsNull((Select ProductName From Items Where Product_Code = pmpf.ProdCat_Code), '') 
                    Else pmpf.ProdCat_Code 
                 End, 
[Target] = IsNull((Case When pmp.ParameterType = 1 Or pmp.ParameterType = 2 Then 0 Else 
(Select top 1 Target From tbl_mERP_PMetric_TargetDefn Where ParamID = pmp.ParamID and SalesmanID=sl.SalesmanID and active = 1) End), 0), 
[ValidFromDate] = dbo.StripDatefromtime(DateAdd(DD, 1, DateAdd(DD, (-1 * DatePart(DD, GetDate())), GetDate()))),  
[ValidToDate] = dbo.StripDateFromtime(DateAdd(SS, -1, DateAdd(MM, 1, dbo.StripDatefromtime(DateAdd(DD, 1, DateAdd(DD, (-1 * DatePart(DD, GetDate())), GetDate())))))), 
[Parm] = pmp.ParamID, 
[Frequency] = pmp.Frequency
From tbl_mERP_PMMaster pmm, tbl_mERP_PMDSType pmds, 
DSType_Details dd, DSType_Master dm, 
Salesman sl, tbl_mERP_PMParam pmp, 
tbl_mERP_PMParamFocus pmpf, @tmpHHSM hhsm
Where pmm.pmid = pmds.pmid And pmm.Active=1 
And	dd.DSTypeID = dm.DsTypeID 
And dd.SalesmanID = sl.SalesmanID And sl.Active = 1 
And dm.DSTypeValue = pmds.DSType And dm.DSTypeCtlPos = 1
And pmp.ParamID = pmpf.ParamID And pmp.DSTypeID = pmds.DSTypeID 
And pmm.Period = Substring(DateName(mm, Getdate()), 1, 3) + '-' + DateName(YYYY, Getdate())
And sl.SalesmanID = hhsm.SalesmanID

DECLARE CurCtg CURSOR FOR 
Select Id, SalesmanID, Groups, PLevel, Product_Code, Product_Code_view, Product_Name, Target, ValidFromDate, ValidToDate, Parm, Frequency
from @PM_Groups 

OPEN CurCtg
FETCH FROM CurCtg Into @PM_Groups_ID, @SalesmanID, @Groups, @PLevel, @Product_Code, @Product_Code_view, @Product_Name, 
    @Target, @ValidFromDate, @ValidToDate, @Parm, @Frequency
While @@fetch_status = 0 
Begin
    If @PLevel = 0 
        Insert Into @PM
        select @PM_Groups_ID, @SalesmanID, @PLevel, @Product_Code, @Product_Code_view, @Product_Name, @Target,
            @ValidFromDate, @ValidToDate, @Parm, @Frequency, * from dbo.sp_SplitIn2Rows(@Groups, '|' ) 
    Else
        Insert Into @PM
        select @PM_Groups_ID, @SalesmanID, @PLevel, @Product_Code, @Product_Code_view, @Product_Name, @Target, 
            @ValidFromDate, @ValidToDate, @Parm, @Frequency, ''
    FETCH FROM CurCtg Into @PM_Groups_ID, @SalesmanID, @Groups, @PLevel, @Product_Code, @Product_Code_view,
        @Product_Name, @Target, @ValidFromDate, @ValidToDate, @Parm, @Frequency
End 
Close CurCtg
DeAllocate CurCtg

--select * from @PM_Groups order by 1;select * from @PM order by 1;
Declare @Achievement Table ( Id Int, Netamount Decimal(18, 6))
Insert Into @Achievement 
Select pm_groups_Id, sum( Netamount) Netamount From @pm pm
Join ( Select paramId From tbl_mERP_PMParamSlab where Slab_uom = 'percentage' 
        group by paramId ) pmps on pm.parm = pmps.paramId
Join @I I on pm.SalesmanID = I.SalesmanID 
Join @Itm Itm on I.Itemcode = Itm.product_code 
Where
    ( Case when pm.plevel = 0 then pm.CtgGroup 
		when pm.plevel = 5 then pm.product_code 
        when ( pm.plevel = 2 or pm.plevel = 3 or pm.plevel = 4) then pm.product_code_view  
      end)
    =
    ( Case when pm.plevel = 0 then Itm.CategoryGroup
        when pm.plevel = 2 then Cast(Itm.DivID as nVarchar(10))
        when pm.plevel = 3 then Cast(Itm.SubCatID as nVarchar(10))
        when pm.plevel = 4 then Cast(Itm.MktSKUID as nVarchar(10))
        when pm.plevel = 5 then Itm.Product_Code
      End)
group by pm_groups_Id

Declare @PreResult table(pm_Groups_ID int, InvoiceDate DateTime, InvoiceID int, ItemCode nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS)
Insert into @PreResult
Select pm.pm_groups_Id, I.InvoiceDate, I.InvoiceId, I.ItemCode
From @pm pm
    Join @I I on pm.SalesmanID = I.SalesmanID 
    Join @Itm Itm on Itm.product_code  = I.Itemcode 
where
	I.InvoiceType in (1,3) and 
    (Case when pm.plevel = 0 then pm.CtgGroup 
		when pm.plevel = 5 then pm.product_code 
        when ( pm.plevel = 2 or pm.plevel = 3 or pm.plevel = 4) then pm.product_code_view  
     end)
    =
    ( Case when pm.plevel = 0 then Itm.CategoryGroup
        when pm.plevel = 2 then Cast(Itm.DivID as nVarchar(10))
        when pm.plevel = 3 then Cast(Itm.SubCatID as nVarchar(10))
        when pm.plevel = 4 then Cast(Itm.MktSKUID as nVarchar(10))
        when pm.plevel = 5 then Itm.Product_Code
      End)
    group by pm_groups_Id, I.InvoiceId, I.InvoiceDate , I.ItemCode

----Bills Cut - Frequency = 2
Declare @BillsCount_Fre2 Table (pm_groups_Id Int, BillsCount Int )
Insert Into @BillsCount_Fre2 
Select pm_groups_Id, count(*) BillsCount 
From (Select distinct pr.pm_groups_Id, pr.InvoiceId From @PreResult pr) tmp group by pm_groups_Id

Declare @BillsCut_Fre2 Table ( Id Int, BillsCut Decimal(18, 6) )
Insert Into @BillsCut_Fre2
Select pmg.Id,
	sum((Case when Slab.Slab_Every_QTY = 0 
    		then Slab.SLAB_VALUE 
		    else ((BCF2.BillsCount/convert(decimal(18, 6), Slab.Slab_Every_QTY)) * convert(decimal(18, 6), Slab.SLAB_VALUE)) 
	    End))
From @PM_Groups pmg 
	Join @BillsCount_Fre2 BCF2 on pmg.Id = BCF2.pm_groups_Id and pmg.frequency = 2
	Join tbl_mERP_PMParamSlab Slab on pmg.parm = Slab.paramId And Slab.SLAB_UOM = 'BC'
Where
    BCF2.BillsCount Between Slab.SLAB_START  And Slab.SLAB_END
group by pmg.Id

----Bills Cut - Frequency = 1 
Declare @BillsCount_Fre1_Datewise Table (pm_groups_Id Int, InvoiceDate datetime, BillsCount Int )
Insert Into @BillsCount_Fre1_Datewise
Select pm_groups_Id, InvoiceDate, count(*) BillsCount 
From (Select Distinct pr.pm_groups_Id, pr.InvoiceId, pr.InvoiceDate From @PreResult pr)tmp group by pm_groups_Id, InvoiceDate     

Declare @BillsCut_Fre1 Table ( Id Int, BillsCut decimal(18, 6) )
Insert Into @BillsCut_Fre1
Select Id, sum(BillsCount) from 
(   Select pmg.Id, 
	    (Case when Slab.Slab_Every_QTY = 0 
		    then Slab.SLAB_VALUE 
		    else ((BFD.BillsCount/convert(decimal(18, 6), Slab.Slab_Every_QTY)) * convert(decimal(18, 6), Slab.SLAB_VALUE)) 
	     End) BillsCount 
    From @PM_Groups pmg 
		Join tbl_mERP_PMParamSlab Slab on pmg.parm = Slab.paramId And Slab.SLAB_UOM = 'BC' and pmg.frequency = 1 
		Join @BillsCount_Fre1_Datewise BFD on pmg.Id = BFD.pm_groups_Id 
	Where
		BFD.BillsCount Between Slab.SLAB_START And Slab.SLAB_END
) tmp group by Id

----Lines Cut - Frequency = 2 
Declare @LinesCount_Fre2 Table ( pm_groups_Id Int, LinesCount Int )
Insert Into @LinesCount_Fre2 
Select pm_groups_Id, count(*) LinesCount 
From (Select distinct pr.pm_groups_Id, pr.InvoiceId, pr.ItemCode From @PreResult pr) tmp group by pm_groups_Id

Declare @LinesCut_Fre2 Table ( Id Int, LinesCut decimal(18, 6) )
Insert Into @LinesCut_Fre2
Select pmg.Id, 
    sum(Case when Slab.Slab_Every_QTY = 0 
    		then Slab.SLAB_VALUE 
	    	else ((LCF2.LinesCount/convert(decimal(18, 6), Slab.Slab_Every_QTY)) * convert(decimal(18, 6), Slab.SLAB_VALUE)) 
	    End)
From @PM_Groups pmg 
	Join @LinesCount_Fre2 LCF2 on pmg.Id = LCF2.pm_groups_Id and pmg.frequency = 2
	Join tbl_mERP_PMParamSlab Slab on pmg.parm = Slab.paramId And Slab.SLAB_UOM = 'LC'
Where
    LCF2.LinesCount Between Slab.SLAB_START And Slab.SLAB_END
group by pmg.Id

----Lines Cut - Frequency = 1
Declare @LinesCount_Fre1_Datewise Table (pm_groups_Id Int, InvoiceDate datetime, LinesCount Int )
Insert Into @LinesCount_Fre1_Datewise
Select pm_groups_Id, InvoiceDate, count(*) LinesCount 
From (Select pr.pm_groups_Id, pr.ItemCode, pr.InvoiceID, pr.InvoiceDate From @PreResult pr)tmp group by pm_groups_Id, InvoiceDate

Declare @LinesCut_Fre1 Table ( Id Int, LinesCut decimal(18, 6)  )
Insert Into @LinesCut_Fre1
Select Id, sum(LinesCount) from 
(   Select pmg.Id, 
	    (Case when Slab.Slab_Every_QTY = 0 
		    then Slab.SLAB_VALUE 
		    else ((LFD.LinesCount/convert(decimal(18, 6), Slab.Slab_Every_QTY)) * convert(decimal(18, 6), Slab.SLAB_VALUE)) 
	     End) LinesCount 
    From @PM_Groups pmg 
    Join tbl_mERP_PMParamSlab Slab on pmg.parm = Slab.paramId And Slab.SLAB_UOM = 'LC' and pmg.frequency = 1  
    Join @LinesCount_Fre1_Datewise LFD on pmg.Id = LFD.pm_groups_Id 
	where
        LFD.LinesCount Between Slab.SLAB_START And Slab.SLAB_END
) tmp group by Id

Insert InTo @DSMetrics 
Select SalesmanID, Groups, PLevel, Product_Code_view, Product_Name, sum(Target) as Target, 
sum(IsNull( Achievement.Netamount, 0 )) Achievement,
sum(IsNull( BCF2.Billscut, 0 ) + IsNull( BCF1.Billscut, 0 )) as Billscut,
sum(IsNull( LCF2.Linescut, 0 ) + IsNull( LCF1.Linescut, 0 )) as LInescut,
ValidFromDate, ValidToDate
from @PM_Groups pmg 
Left outer Join @Achievement Achievement on pmg.Id = Achievement.Id 
Left outer Join @BillsCut_Fre2 BCF2 on pmg.Id = BCF2.Id and pmg.frequency = 2
Left outer Join @BillsCut_Fre1 BCF1 on pmg.Id = BCF1.Id and pmg.frequency = 1
Left outer Join @LinesCut_Fre2 LCF2 on pmg.Id = LCF2.Id and pmg.frequency = 2
Left outer Join @LinesCut_Fre1 LCF1 on pmg.Id = LCF1.Id and pmg.frequency = 1
Group By SalesmanID, Groups, PLevel, Product_Code_view, Product_Name, ValidFromDate, ValidToDate 

Return

END
