

Create Procedure mERP_spr_Merchandise_Type_Definition    
(@Zone NVarChar(4000),
@Salesman NVarChar(4000),    
@Beat NVarChar(4000) ,
@Active nVarchar(25)   
)    
As
BEGIN    
	Declare @Delimeter Char(1)    
	Set @Delimeter=Char(15)    

	Declare @TOBEDEFINED nVarchar(50)

	Set @TOBEDEFINED=dbo.LookupDictionaryItem(N'To be defined', Default)
	    
	Create Table #TmpSalesman(SalesmanID Int)    
	Create Table #TmpBeat(BeatID Int)    	
	Create Table #TmpCustomer (CustomerID nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS) 
    
	If @Zone <> N'%' 
	Begin
		Insert InTo #TmpCustomer Select CustomerID From Customer 
			Where ZoneID In (Select ZoneID From tbl_mERP_Zone 
			Where ZoneName In (Select * From Dbo.sp_SplitIn2Rows(@Zone,@Delimeter)))
	End
	Else
	Begin
		Insert InTo #TmpCustomer Select CustomerID From Customer 
	End

	If @Salesman = N'%'    
	BEGIN    
		Insert InTo #TmpSalesman Values(0)    
		Insert InTo #TmpSalesman Select Distinct SalesmanID From Salesman    
	END    
	Else
	Begin    
		Insert InTo #TmpSalesman    
		Select Distinct SalesmanID From Salesman Where Salesman_Name In (Select * From Dbo.sp_SplitIn2Rows(@Salesman,@Delimeter))    
	End	    


	If @Salesman = N'%' And @Beat = N'%'
	BEGIN    
		Insert InTo #TmpBeat    
		Select Distinct BeatID From Beat    
	END
	Else If @Salesman <> N'%' And @Beat = N'%'    
	BEGIN
		Insert InTo #TmpBeat    
		Select BeatID From Beat_Salesman Where SalesmanID In (Select SalesmanID From #TmpSalesman) Group By BeatID    
	END
	Else
	BEGIN    
		Insert InTo #TmpBeat    
		Select BeatID From Beat Where Description In (Select * From Dbo.sp_SplitIn2Rows(@Beat,@Delimeter))    
	END
	    

	If @Active = N'All' Or @Active = N'%' Or @Active = ''
		Set @Active = '0'
	Else if @Active = N'Active'
		Set @Active = '1'
	Else if @Active = N'Deactive'
		Set @Active = '2'
	



	CREATE TABLE #Finaltemp    
	(    
	CustomerID nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,    
	[Customer Name] nvarchar(300) COLLATE SQL_Latin1_General_CP1_CI_AS,    
	[Customer Type] nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
	[Channel Type] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
	[Outlet Type] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
	[Loyalty Program] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
	RCSID nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS   
	)    

	-- Channel type name changed, and new channel classifications added

	CREATE TABLE #OLClassMapping (OLClassID Int, CustomerID nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
	[Channel Type] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
	[Outlet Type] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
	[Loyalty Program] nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS)  

	Insert Into #OLClassMapping 
	Select  olcm.OLClassID, olcm.CustomerId, olc.Channel_Type_Desc, olc.Outlet_Type_Desc, 
	olc.SubOutlet_Type_Desc 
	From tbl_merp_olclass olc, tbl_merp_olclassmapping olcm
	Where olc.ID = olcm.OLClassID And
	olc.Channel_Type_Active = 1 And olc.Outlet_Type_Active = 1 And olc.SubOutlet_Type_Active = 1 And 
	olcm.Active = 1 



	    
	Insert into #Finaltemp    
	Select    
	Distinct CM.CustomerID,     
	"Customer Name" = CM.Company_Name,    
	"Customer Type" = CC.Channeldesc,    

	"Channel Type" = Case IsNull(olcm.[Channel Type], '') 
					 When '' Then 
						@TOBEDEFINED
					 Else 
				 		olcm.[Channel Type]
					 End,

	"Outlet Type" = Case IsNull(olcm.[Outlet Type], '') 
					When '' Then 
						@TOBEDEFINED
					Else 
						olcm.[Outlet Type]
					End,

	"Loyalty Program" = Case IsNull(olcm.[Loyalty Program], '') 
						When '' Then 
							@TOBEDEFINED
						Else 
							olcm.[Loyalty Program] 
						End,

	"RCS ID"= IsNull(CM.RCSOutletID,'')
	From    
	Customer CM
	inner join  Beat_Salesman BS on CM.CustomerID = BS.CustomerID 
	inner join Customer_channel CC on  CC.Channeltype= CM.Channeltype  
	right outer join  #OLClassMapping olcm on  olcm.CustomerID = CM.CustomerID 
	Where 
	CM.Active = (Case Cast(@Active as Int) When 0 Then CM.Active When 1 Then 1 When 2 Then 0 End)  	   	    
	And IsNull(BS.SalesmanID,0) In (Select SalesmanID From #TmpSalesman)    
	And BS.BeatID In (Select BeatID From #TmpBeat)    
	And CM.CustomerID In (Select CustomerID From #TmpCustomer)
	
	    
	    
	Declare @BuildQry varchar(max)    
	SET @BuildQry = ''   
	Declare @Merchandise nvarchar(510)    
	Declare Merchandise CURSOR FOR Select Distinct Merchandise From Merchandise    
	OPEN Merchandise    
	FETCH From Merchandise into @Merchandise    
	While @@Fetch_Status = 0    
	BEGIN    
		SET @BuildQry = N'ALTER TABLE #Finaltemp Add [' + @Merchandise + '] nvarchar(15) Default (''No'')'    
		EXEC (@BuildQry)    
		SET @BuildQry = N''
		SET @BuildQry = N'Update #FinalTemp Set [' + @Merchandise + '] = ''No'''
		EXEC (@BuildQry)    
		FETCH From Merchandise into @Merchandise    
	END    
	close Merchandise    
	Deallocate Merchandise    
	
	Declare @CustomerID nvarchar(30)    
	Declare @MerchandiseName nvarchar(50)    

	SET @BuildQry = ''    
	SET @MerchandiseName = ''    
	    
	Declare Merchandise CURSOR FOR 	
	select cm.customerid, mm.merchandise 
	from custMerchandise cm ,Merchandise mm
	where mm.merchandiseid = cm.merchandiseid	
	OPEN Merchandise    
	FETCH From Merchandise into @CustomerID, @MerchandiseName
	While @@Fetch_Status = 0    
	BEGIN    		 
		SET @BuildQry = 'Update #FinalTemp Set [' + @MerchandiseName +'] = ''Yes'' Where CustomerID = ''' + @CustomerID + ''''
		EXEC (@BuildQry)    
		FETCH From Merchandise into @CustomerID, @MerchandiseName
	END    
	Close Merchandise    
	Deallocate Merchandise    
	Select CustomerID,* From #FinalTemp	
	Drop Table #FinalTemp
	Drop Table #TmpBeat
	Drop Table #TmpSalesman
	Drop Table #OLClassMapping 
END
