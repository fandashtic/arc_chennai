create Procedure mERP_SP_Rpt_BatchWsSKUWsChanlWsRates(@Channel nVarchar(2550),@ProductCode NVarChar(2550))
AS
BEGIN
	SET DATEFORMAT DMY
	Declare @Delimeter as Char(1)              
	Set @Delimeter=Char(15) 
	Create table #TempChannelPTR([Channel Name] nvarchar(255),[Registration Flag] nvarchar(30),[Batch Number] nvarchar(255),
	[Product Code] nvarchar(255),[Product Name] nvarchar(255), 
	[Division] nvarchar(255), [UOM] nvarchar(25), [OrgPTS] Decimal(18,6), [NetPTS] Decimal(18,6), PFM Decimal(18,6), [Margin] Decimal(18,6),
	[PTR] decimal(18,6), [MRPPerPack] Decimal(18,6))
	
	create table #tmpProd(product_code NVarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS)        
	create table #tmpChannel(Channel_Code NVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)        
	create table #tmpChannelName(Channel_Name NVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)        
	
	If @ProductCode = '%'        
	 Insert InTo #tmpProd Select Product_code From Items        
	Else        
	 Insert into #tmpProd select * from dbo.sp_SplitIn2Rows(@ProductCode, @Delimeter) 
	
	If @Channel = '%'        
	 Insert InTo #tmpChannel Select distinct Channel_Type_Code From tbl_mERP_OLClass        
	Else    
	Begin    
	 Insert into #tmpChannelName select * from dbo.sp_SplitIn2Rows(@Channel, @Delimeter) 
     Insert InTo #tmpChannel Select distinct Channel_Type_Code 
		From tbl_mERP_OLClass where Channel_Type_Desc in (select * from #tmpChannelName)
	End
		
	-- 1 - UnRegister / 2 - Register / 3 - All
	Insert into #TempChannelPTR ([Channel Name], [Registration Flag], [Batch Number], [Product Code], [Product Name], 
	[Division], [UOM], [OrgPTS], [NetPTS],  PFM, [Margin], [PTR], [MRPPerPack])
	Select  "Channel Name" = (Select Distinct Isnull(OL.Channel_Type_Desc,'') from tbl_mERP_OLClass OL Where Channel_Type_Code = BC.ChannelTypeCode)  ,
	"Registration Flag" = Case When Isnull(BC.RegisterStatus,0) = 1 Then 'Unregistered' When Isnull(BC.RegisterStatus,0) = 2 Then 'Registered' Else 'All' End,
	"Batch Number" = ISNULL(BP.Batch_Number,''),I.Product_Code ,I.ProductName ,
	IC2.Category_Name, U.Description, BP.OrgPTS , BP.PurchasePrice , BP.PFM , CMD.MarginPerc,  --BP.MarginPerc , 
	BC.ChannelPTR , BP.MRPPerPack 
	From BatchWiseChannelPTR BC Join Batch_Products BP On BP.Batch_Code = BC.Batch_Code 
	and BP.Quantity > 0 and ISNULL(BP.Free,0 ) = 0 and ISNULL(BP.Damage ,0) = 0
	Join Items I On I.Product_Code = BP.Product_Code 
	Join ItemCategories IC4 On IC4.CategoryID = I.CategoryID 
	Join ItemCategories IC3 On IC4.ParentID = IC3.CategoryID 
	Join ItemCategories IC2 On IC3.ParentID  = IC2.CategoryID
	Join UOM U On U.UOM = I.UOM 
	Left Join tbl_mERP_ChannelMarginDetail CMD On CMD.ID = BC.ChannelMarginID 
	Where I.Product_Code In (Select product_code from #tmpProd) 
	And BC.ChannelTypeCode In (Select Channel_Code from #tmpChannel)
	Group by BP.Batch_Code,BC.ChannelTypeCode,BC.RegisterStatus,BP.Batch_Number,BC.ChannelPTR,
	I.Product_Code ,I.ProductName,	IC2.Category_Name, U.Description, BP.OrgPTS , BP.PurchasePrice , BP.PFM ,  CMD.MarginPerc,  BC.ChannelPTR , BP.MRPPerPack 
	
	Select Distinct 0,[Channel Name],[Registration Flag],[Batch Number],[Product Code],[Product Name],Category=[Division], [UOM], [OrgPTS], [NetPTS],  PFM, [Margin], [PTR], [MRPPerPack]
	From #TempChannelPTR Order By [Channel Name],[Product Code] ,[Product Name]
	
	Drop Table #TempChannelPTR

END
