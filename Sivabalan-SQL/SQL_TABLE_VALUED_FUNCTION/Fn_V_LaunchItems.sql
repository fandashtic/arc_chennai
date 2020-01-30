CREATE FUNCTION Fn_V_LaunchItems()  	
Returns @Result Table (
--[SalesmanID] int,
[Customer_ID] nvarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Beat_ID] int,
[Item_Code] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
[UOM] nvarchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS,
[Launch_Quantity] decimal(18,6),
[Launch_Start_Date] DateTime,
[Launch_End_Date] Datetime,
[Sequence] Int,
[Is_Invoiced] nvarchar(10) COLLATE SQL_Latin1_General_CP1_CI_AS
)
AS
BEGIN	
	Declare @Currentdate Datetime
	Select @Currentdate=dbo.stripdatefromtime(getdate())

	Declare @TmpItems table(GroupID int,GroupName nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,ItemCode nvarchar(255) 
	COLLATE SQL_Latin1_General_CP1_CI_AS,Division nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)
	Declare @TmpDSType table(DSTypeID int,GroupID int)
	Declare @tmpDSDetails Table(DSTypeID int,SalesmanID int)
	Declare @HHDS Table (SalesmanID int,BeatID int,CustomerID nvarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS)

	/* For getting Divisions and corresponding Category Groups */
	If (Select isnull(Flag,0) From Tbl_merp_Configabstract Where ScreenCode = 'OCGDS' and ScreenName ='OperationalCategoryGroup')=0
	BEGIN
		insert into @TmpItems (GroupID,GroupName,ItemCode,Division)
		Select distinct PCGA.GroupID,PCGA.GroupName, I.Product_Code,IC3.Category_Name
		From ItemCategories IC1, ItemCategories IC2, ItemCategories IC3,ProductCategoryGroupAbstract PCGA, 
		Items I,tblCGDivMapping CGDIV
		Where CGDIV.Division = IC3.Category_Name
		  And IC3.CategoryID = IC2.ParentID 
		  And IC2.CategoryID = IC1.ParentID 
		  And IC1.CategoryID = I.CategoryID
		  And I.Active = 1 
		  And CGDIV.CategoryGroup = PCGA.GroupName
		  And I.Product_code in (Select distinct ItemCode from LaunchItems where isnull(active,0) = 1 and  @Currentdate between dbo.stripdatefromtime(LaunchStartDate) and dbo.stripdatefromtime(LaunchEndDate))
	END
	ELSE
	BEGIN
		insert into @TmpItems (GroupID,GroupName,ItemCode,Division)
		select distinct P.GroupID,O.GroupName,O.SystemSKU,O.Division from OCGItemMaster O,ProductCategoryGroupAbstract P, Items I
		where P.GroupName=O.GroupName And
		Isnull(OCGType,0) = 1 And 
		isnull(P.Active,0) = 1	
		And I.Product_Code = O.SystemSKU and I.Active = 1
	END

	/* For getting DStypes for Divisions and corresponding Category Groups */
	Insert into @TmpDSType(DSTypeID,GroupID)
	Select distinct DSTypeID,GroupID from tbl_mERP_DSTypeCGMapping where Active = 1 and GroupID in (select Distinct GroupID from @TmpItems)

	/* For getting DS for DStypes, Divisions and corresponding Category Groups */
	Insert into @tmpDSDetails (DSTypeID,SalesmanID)
	Select Distinct DStypeID,SalesmanID From DSType_Details where DStypeID in (select DStypeID from DSType_Master where 
	 ( Case when DSTypeName = 'DSType' then 
				(Select flag from tbl_merp_Configabstract where ScreenCode = 'OCGDS' and ScreenName ='OperationalCategoryGroup') 
			  Else IsNull(OCGtype, 0) 
			  End ) = IsNull(OCGtype, 0)
		and Active = 1 and DSTypeCtlPos=1)
	And DStypeID in (Select DSTypeID from @TmpDSType)

	/* For handheld salesmen */
	Insert into @HHDS (SalesmanID,BeatID,CustomerID)
	Select S.SalesmanID,BS.BeatID,C.CustomerID From 
	Beat_Salesman BS, Salesman S, Beat B,Customer C,DSType_Details dd, DSType_Master dm
	Where 
	DM.DSTypeCTLPos = 2 And
	DD.DSTypeCTLPos = 2 And
	isnull(B.Active,0) = 1 And
	isnull(Dm.Active,0)=1 And 
	isnull(C.Active,0) = 1 And
	DM.DSTypeValue = 'Yes' And
	DD.SalesmanID =S.SalesmanID And
	S.SalesmanId = BS.SalesmanId And 
	dd.DSTypeID = dm.DSTypeID And 
	C.CustomerID = BS.CustomerID And 
	isnull(S.Active,0) = 1 And 
	B.BeatId = BS.BeatId And 
	S.SalesmanID in (select SalesmanID from @tmpDSDetails) and
	C.CustomerID in (Select distinct OutletCode from LaunchItems where isnull(active,0) = 1 and  @Currentdate between dbo.stripdatefromtime(LaunchStartDate) and dbo.stripdatefromtime(LaunchEndDate))

	/* As below condition can take more time in big database it is changed below*/	
	/*
	Declare @MinLaunchDate Datetime
	Declare @MaxLaunchDate Datetime
	
	Select  @MinLaunchDate = Min(dbo.stripdatefromtime(LaunchStartDate)) From LaunchItems where isnull(active,0) = 1 and  @Currentdate between dbo.stripdatefromtime(LaunchStartDate) and dbo.stripdatefromtime(LaunchEndDate)
	Select  @MaxLaunchDate = Max(dbo.stripdatefromtime(LaunchEndDate)) From LaunchItems where isnull(active,0) = 1 and  @Currentdate between dbo.stripdatefromtime(LaunchStartDate) and dbo.stripdatefromtime(LaunchEndDate)
	*/

	/* To get Invoice Details */	
	Declare @InvoiceDetail table(CustomerID nvarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS, ItemCode nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,SalesmanID int, InvoiceDate Datetime)
	insert into @InvoiceDetail(CustomerID,ItemCode,SalesmanID, InvoiceDate)
	Select distinct IA.CustomerID,ID.Product_code as ItemCode,IA.SalesmanID, IA.InvoiceDate from
	InvoiceDetail ID,InvoiceAbstract IA,LaunchItems Launch
	Where isnull(IA.Status,0) &  192=0
	And IA.InvoiceType in(1, 3)
	And Ia.InvoiceID = ID.InvoiceID
	And Launch.OutletCode=IA.CustomerID
	And Launch.ItemCode= ID.Product_code
	And isnull(Launch.active,0) = 1 
	And  @Currentdate between dbo.stripdatefromtime(Launch.LaunchStartDate) and dbo.stripdatefromtime(Launch.LaunchEndDate)
	And dbo.stripdatefromtime(Ia.InvoiceDate) between dbo.stripdatefromtime(Launch.LaunchStartDate) and dbo.stripdatefromtime(Launch.LaunchEndDate)
	
	
/*	And IA.CustomerID in (Select distinct OutletCode from LaunchItems where isnull(active,0) = 1 and  @Currentdate between dbo.stripdatefromtime(LaunchStartDate) and dbo.stripdatefromtime(LaunchEndDate))
	And ID.Product_code in (Select distinct ItemCode from LaunchItems where isnull(active,0) = 1 and  @Currentdate between dbo.stripdatefromtime(LaunchStartDate) and dbo.stripdatefromtime(LaunchEndDate))
*/
/*
Select * from @HHDS HH where customerID='1015'
select * from @tmpDSDetails DSDetails where salesmanid in (1,10,11,18)
Select * from @TmpDSType DStype where DStypeID in (20,43,44,45)
Select * from	@TmpItems Div where GroupId in (2,5,6,7) and Itemcode='FA2111'
*/
Insert into @Result([Customer_ID],[Beat_ID],[Item_Code],[UOM],[Launch_Quantity],[Launch_Start_Date],[Launch_End_Date],[Sequence],[Is_Invoiced])
Select 
	--HH.SalesManID as [SalesmanID],
	HH.CustomerID as [Customer ID],
	HH.BeatID as [Beat ID],
	Div.ItemCode as [Item Code],
	Launch.UOM as [UOM],
	Launch.LaunchQuantity as [Launch Quantity],
	Launch.LaunchStartDate as [Launch Start Date],
	Launch.LaunchEndDate as [Launch End Date],
	Launch.Sequence as [Sequence],
	(Case When exists(Select ID.Itemcode from @InvoiceDetail ID where ID.CustomerID = HH.CustomerID and ID.ItemCode= Div.ItemCode and ID.SalesmanID= HH.SalesManID
	And dbo.stripdatefromtime(ID.InvoiceDate) between dbo.stripdatefromtime(Launch.LaunchStartDate) and dbo.stripdatefromtime(Launch.LaunchEndDate)) Then 'Yes' else 'No' end) as [Is Invoiced]
	from @HHDS HH,@tmpDSDetails DSDetails,@TmpDSType DStype,
	@TmpItems Div,LaunchItems Launch
	Where HH.SalesmanID=DSDetails.SalesmanID And
	DStype.DSTypeID=DSDetails.DSTypeID And
	Div.GroupID =DStype.GroupID And
	isnull(Launch.active,0) = 1 
	and  @Currentdate between dbo.stripdatefromtime(Launch.LaunchStartDate) and dbo.stripdatefromtime(Launch.LaunchEndDate)
	And Launch.OutletCode=HH.CustomerID
	And Launch.ItemCode = Div.ItemCode	

Order by HH.CustomerID,Launch.Sequence
Return
END

