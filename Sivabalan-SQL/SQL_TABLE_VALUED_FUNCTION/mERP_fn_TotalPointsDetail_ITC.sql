CREATE Function mERP_fn_TotalPointsDetail_ITC(@SchemeID Int, @AppOn Int, @ItemGp Int, @POutFrom Datetime, 
@POutTo Datetime, @GID Int, @UOM Int, @SStart Decimal(18, 6), @SEnd Decimal(18, 6), @Onward Decimal(18, 6), 
@Value Decimal(18, 6), @UR Decimal(18, 6), @SchFrom Datetime, @SchTo Datetime, @SKUCount Int, @Salesman nVarchar(2550),
@Beat nVarchar(2550))    
Returns @TotPoints2 Table (InvoiceID Int, CustomerID nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
CustomerName nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
ChannelType nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
DefaultBeat nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
RatePerUnit Decimal(18, 6), TPoints Decimal(18, 6), 
ItemCode nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS)
As    
Begin    
Declare @GraceDays as Int
Declare @POutToGraceDays Datetime
Declare @ActFrom Datetime
Declare @ActTo Datetime

Set @POutTo = DateAdd(ss, -1, @POutTo + 1)
Set @SchTo = DateAdd(ss, -1, @SchTo + 1)

Select @GraceDays = DateDiff(d, ActiveTo, ExpiryDate) From tbl_mERP_SchemeAbstract Where SchemeID = @SchemeID

Select @ActFrom = ActiveFrom, @ActTo = ActiveTo From tbl_mERP_SchemeAbstract Where SchemeID = @SchemeID

Set @POutToGraceDays = DateAdd(D, @GraceDays, @POutTo)

Declare @TotPoints Table (InvoiceID Int, CustomerID nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
CustomerName nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
ChannelType nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
DefaultBeat nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
RatePerUnit Decimal(18, 6), TPoints Decimal(18, 6), 
ItemCode nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, InvType Int)

Declare @SPTotPoints Table (InvoiceID Int, CustomerID nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
CustomerName nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
ChannelType nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
DefaultBeat nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
RatePerUnit Decimal(18, 6), TPoints Decimal(18, 6), 
ItemCode nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, InvType Int)

Declare @OFFTakeTotPoints Table (InvoiceID Int, CustomerID nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
CustomerName nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
ChannelType nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, 
DefaultBeat nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS,
RatePerUnit Decimal(18, 6), TPoints Decimal(18, 6), 
ItemCode nVarchar(256) COLLATE SQL_Latin1_General_CP1_CI_AS, InvType Int)

-------Salesman & Beat Filter--------
Declare @Delimeter As Char(1)
Set @Delimeter = Char(15)

Declare @Saleman Table (Salesman nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, SalesmanID Int)    

if @Salesman = N'%'     
   Insert InTo @Saleman Select Distinct Salesman_Name, SalesmanID From Salesman
Else    
   Insert InTo @Saleman Select Distinct Salesman_Name, SalesmanID From Salesman 
   Where Salesman_Name In (Select * from dbo.sp_SplitIn2Rows(@Salesman, @Delimeter))

Declare @Bt Table (Beat nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, BeatID Int)    

if @Beat = N'%'     
   Insert InTo @Bt Select Distinct Description, BeatID From Beat
Else    
   Insert InTo @Bt Select Distinct Description, BeatID From Beat 
   Where Description In (Select * from dbo.sp_SplitIn2Rows(@Beat, @Delimeter))

Declare @BSFCustID Table(CustomerID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)

Insert InTo @BSFCustID 
Select Distinct ia.CustomerID From InvoiceAbstract ia
Where ia.Status & 128 = 0 And ia.InvoiceType In (1,3, 4) And 
	ia.InvoiceDate Between @POutFrom And @POutTo And 
	ia.InvoiceDate Between @ActFrom And @ActTo And 
	ia.CreationTime Between @POutFrom And @POutToGraceDays 
	And ia.SalesmanID In (Select SalesmanID From @Saleman) And
	ia.BeatID In (Select BeatID From @bt) 

-------------------------------------


If @AppOn = 1 And @ItemGp != 2
--Item based scheme------------
Begin
	If @UOM In (1, 2, 3)
	--Item based - quantity based scheme--------
	Begin
		Insert Into @TotPoints (InvoiceID , CustomerID , CustomerName , 
		ChannelType , DefaultBeat , RatePerUnit , TPoints , ItemCode, InvType )
		Select ia.InvoiceID, ia.CustomerID, 
		c.Company_Name, 
		(Select Top 1 ChannelDesc From Customer_Channel cc Where cc.ChannelType = c.ChannelType),
		(Select Top 1 Description From Beat bt Where bt.BeatID = ia.BeatID),
		@UR, 
		Case @UOM When 1 Then Sum(idl.Quantity) 
					   When 2 Then Sum(idl.Quantity) / (Case IsNull(its.UOM1_Conversion, 0) 
									 When 0 Then 1 Else IsNull(its.UOM1_Conversion, 0) End)
					   When 3 Then Sum(idl.Quantity) / (Case IsNull(its.UOM2_Conversion, 0) 
									 When 0 Then 1 Else IsNull(its.UOM2_Conversion, 0) End)
		End, 
		idl.Product_Code, ia.InvoiceType
		From InvoiceAbstract ia, InvoiceDetail idl, Items its,  Customer c
		Where ia.CustomerID = c.CustomerID And ia.InvoiceID = idl.InvoiceID And its.Product_Code = idl.Product_Code And 
		ia.Status & 128 = 0 And ia.InvoiceType In (1,3, 4) And 
		ia.InvoiceDate Between @POutFrom And @POutTo And 
		ia.InvoiceDate Between @ActFrom And @ActTo And 
		ia.CreationTime Between @POutFrom And @POutToGraceDays And 
		ia.CustomerID In (Select CustomerID From CustList3 cl3 Where cl3.SchemeID = @SchemeID 
		And cl3.GroupID = @GID And QPS = 0) And 
		idl.Product_Code In (Select ItemCode From IPScope ips Where ips.SchemeID = @SchemeID )
		And ia.CustomerID In (Select CustomerID From @BSFCustID) 
		Group By ia.InvoiceID, ia.CustomerID, idl.Product_Code, its.UOM1_Conversion,
		its.UOM2_Conversion, c.Company_Name, c.ChannelType, c.DefaultBeatId, ia.InvoiceType, ia.BeatID

			--Item based , Off take scheme------
			Insert Into @OFFTakeTotPoints (InvoiceID , CustomerID , CustomerName , 
		    ChannelType , DefaultBeat , RatePerUnit , TPoints , ItemCode , InvType)
			Select 0, ia.CustomerID , c.Company_Name, 
			(Select Top 1 ChannelDesc From Customer_Channel cc Where cc.ChannelType = c.ChannelType),
			(Select Top 1 Description From Beat bt Where bt.BeatID = ia.BeatID),
			@UR, 
				Case @UOM When 1 Then Sum((Case ia.InvoiceType When 4 Then -1 Else 1 End) * idl.Quantity) 
					   When 2 Then Sum((Case ia.InvoiceType When 4 Then -1 Else 1 End) * idl.Quantity) / (Case IsNull(its.UOM1_Conversion, 0) 
									 When 0 Then 1 Else IsNull(its.UOM1_Conversion, 0) End)
					   When 3 Then Sum((Case ia.InvoiceType When 4 Then -1 Else 1 End) * idl.Quantity) / (Case IsNull(its.UOM2_Conversion, 0) 
									 When 0 Then 1 Else IsNull(its.UOM2_Conversion, 0) End)
			   End,
			idl.Product_Code, 0
			From InvoiceAbstract ia, InvoiceDetail idl, Items its, Customer c
			Where ia.CustomerID = c.CustomerID And ia.InvoiceID = idl.InvoiceID And its.Product_Code = idl.Product_Code And
			ia.Status & 128 = 0 And ia.InvoiceType In (1,3, 4) And 
			ia.InvoiceDate Between @POutFrom And @POutTo And 
			ia.InvoiceDate Between @ActFrom And @ActTo And 
			ia.CreationTime Between @POutFrom And @POutToGraceDays And 
			ia.CustomerID In (Select CustomerID From CustList3 cl3 Where cl3.SchemeID = @SchemeID 
			And cl3.GroupID = @GID And QPS = 1) And 
			idl.Product_Code In (Select ItemCode From IPScope ips Where ips.SchemeID = @SchemeID )
			And ia.CustomerID In (Select CustomerID From @BSFCustID) 
			Group By ia.InvoiceID, ia.CustomerID, idl.Product_Code, its.UOM1_Conversion,
			its.UOM2_Conversion, c.Company_Name, c.ChannelType, c.DefaultBeatId, ia.InvoiceType, ia.BeatID
	End
	Else If @UOM In (4)
	-- Item based - value based scheme---------
	Begin
		Insert Into @TotPoints (InvoiceID , CustomerID , CustomerName , 
		ChannelType , DefaultBeat , RatePerUnit , TPoints , ItemCode, InvType )
		Select ia.InvoiceID, ia.CustomerID, 
		c.Company_Name, 
		(Select Top 1 ChannelDesc From Customer_Channel cc Where cc.ChannelType = c.ChannelType),
		(Select Top 1 Description From Beat bt Where bt.BeatID = ia.BeatID),
		@UR, 
		Sum(idl.Amount), -- * idl.SalePrice) ,

		idl.Product_Code, ia.InvoiceType
		From InvoiceAbstract ia, InvoiceDetail idl, Items its, Customer c
		Where ia.CustomerID = c.CustomerID And ia.InvoiceID = idl.InvoiceID And its.Product_Code = idl.Product_Code And
		ia.Status & 128 = 0 And ia.InvoiceType In (1,3, 4) And 
		ia.InvoiceDate Between @POutFrom And @POutTo And 
		ia.InvoiceDate Between @ActFrom And @ActTo And 
		ia.CreationTime Between @POutFrom And @POutToGraceDays And 
		ia.CustomerID In (Select CustomerID From CustList3 cl3 Where cl3.SchemeID = @SchemeID 
		And cl3.GroupID = @GID And QPS = 0) And 
		idl.Product_Code In (Select ItemCode From IPScope ips Where ips.SchemeID = @SchemeID )
		And ia.CustomerID In (Select CustomerID From @BSFCustID) 
		Group By ia.InvoiceID, ia.CustomerID, idl.Product_Code, its.UOM1_Conversion,
		its.UOM2_Conversion, c.Company_Name, c.ChannelType, c.DefaultBeatId, ia.InvoiceType, ia.BeatID
		
			-- Item based , value based - Offtake scheme
			Insert Into @OFFTakeTotPoints (InvoiceID , CustomerID , CustomerName , 
		    ChannelType , DefaultBeat , RatePerUnit , TPoints , ItemCode, InvType)
			Select 0, ia.CustomerID, 
			c.Company_Name, 
			(Select Top 1 ChannelDesc From Customer_Channel cc Where cc.ChannelType = c.ChannelType),
			(Select Top 1 Description From Beat bt Where bt.BeatID = ia.BeatID),
			@UR, 			
			Sum(((Case ia.InvoiceType When 4 Then -1 Else 1 End) * idl.Amount)), -- * idl.SalePrice),
			idl.Product_Code, 0
			From InvoiceAbstract ia, InvoiceDetail idl, Items its, Customer c
			Where ia.CustomerID = c.CustomerID And ia.InvoiceID = idl.InvoiceID And its.Product_Code = idl.Product_Code And
			ia.Status & 128 = 0 And ia.InvoiceType In (1,3, 4) And 
			ia.InvoiceDate Between @POutFrom And @POutTo And 
			ia.InvoiceDate Between @ActFrom And @ActTo And 
			ia.CreationTime Between @POutFrom And @POutToGraceDays And 
			ia.CustomerID In (Select CustomerID From CustList3 cl3 Where cl3.SchemeID = @SchemeID 
			And cl3.GroupID = @GID And QPS = 1) And 
			idl.Product_Code In (Select ItemCode From IPScope ips Where ips.SchemeID = @SchemeID )
			And ia.CustomerID In (Select CustomerID From @BSFCustID) 
			Group By ia.InvoiceID, ia.CustomerID, idl.Product_Code, its.UOM1_Conversion,
			its.UOM2_Conversion, c.Company_Name, c.ChannelType, c.DefaultBeatId, ia.InvoiceType, ia.BeatID
	End
End

----------------------------------------------------------

Else If @AppOn = 1 And @ItemGp = 2
--Item based, special category schemes
Begin
	If @UOM In (1, 2, 3)
	--Item based, quantity based----------
	Begin
		Insert Into @SPTotPoints (InvoiceID , CustomerID , CustomerName , 
		ChannelType , DefaultBeat , RatePerUnit , TPoints , ItemCode , InvType)
		Select ia.InvoiceID, ia.CustomerID, 
		c.Company_Name, 
		(Select Top 1 ChannelDesc From Customer_Channel cc Where cc.ChannelType = c.ChannelType),
		(Select Top 1 Description From Beat bt Where bt.BeatID = ia.BeatID),
		@UR, 
		Case @UOM When 1 Then Sum(idl.Quantity) 
					   When 2 Then Sum(idl.Quantity) / (Case IsNull(its.UOM1_Conversion, 0) 
									 When 0 Then 1 Else IsNull(its.UOM1_Conversion, 0) End)
					   When 3 Then Sum(idl.Quantity) / (Case IsNull(its.UOM2_Conversion, 0) 
									 When 0 Then 1 Else IsNull(its.UOM2_Conversion, 0) End)
		End, 
		'', ia.InvoiceType
		From InvoiceAbstract ia, InvoiceDetail idl, Items its,  Customer c
		Where ia.CustomerID = c.CustomerID And ia.InvoiceID = idl.InvoiceID And its.Product_Code = idl.Product_Code And 
		ia.Status & 128 = 0 And ia.InvoiceType In (1,3, 4) And 
		ia.InvoiceDate Between @POutFrom And @POutTo And 
		ia.InvoiceDate Between @ActFrom And @ActTo And 
		ia.CreationTime Between @POutFrom And @POutToGraceDays And 
		ia.CustomerID In (Select CustomerID From CustList3 cl3 Where cl3.SchemeID = @SchemeID 
		And cl3.GroupID = @GID And QPS = 0) And 
		idl.Product_Code In (Select ItemCode From IPScope ips Where ips.SchemeID = @SchemeID )
		And ia.CustomerID In (Select CustomerID From @BSFCustID) 		
		Group By ia.InvoiceID, ia.CustomerID, its.UOM1_Conversion,
		its.UOM2_Conversion, c.Company_Name, c.ChannelType, c.DefaultBeatId, ia.InvoiceType, ia.BeatID

			--Item based - quantity based, offtake 
			Insert Into @OFFTakeTotPoints (InvoiceID , CustomerID , CustomerName , 
			ChannelType , DefaultBeat , RatePerUnit , TPoints , ItemCode , InvType)
			Select 0, ia.CustomerID , c.Company_Name, 
			(Select Top 1 ChannelDesc From Customer_Channel cc Where cc.ChannelType = c.ChannelType),
			(Select Top 1 Description From Beat bt Where bt.BeatID = ia.BeatID),
			@UR, 
			Case @UOM When 1 Then Sum((Case ia.InvoiceType When 4 Then -1 Else 1 End) * idl.Quantity) 
					   When 2 Then Sum((Case ia.InvoiceType When 4 Then -1 Else 1 End) * idl.Quantity) / (Case IsNull(its.UOM1_Conversion, 0) 
									 When 0 Then 1 Else IsNull(its.UOM1_Conversion, 0) End)
					   When 3 Then Sum((Case ia.InvoiceType When 4 Then -1 Else 1 End) * idl.Quantity) / (Case IsNull(its.UOM2_Conversion, 0) 
									 When 0 Then 1 Else IsNull(its.UOM2_Conversion, 0) End)
			End,
			'', 0
			From InvoiceAbstract ia, InvoiceDetail idl, Items its, Customer c
			Where ia.CustomerID = c.CustomerID And ia.InvoiceID = idl.InvoiceID And its.Product_Code = idl.Product_Code And
			ia.Status & 128 = 0 And ia.InvoiceType In (1,3, 4) And 
			ia.InvoiceDate Between @POutFrom And @POutTo And 
			ia.InvoiceDate Between @ActFrom And @ActTo And 
			ia.CreationTime Between @POutFrom And @POutToGraceDays And 
			ia.CustomerID In (Select CustomerID From CustList3 cl3 Where cl3.SchemeID = @SchemeID 
			And cl3.GroupID = @GID And QPS = 1) And 
			idl.Product_Code In (Select ItemCode From IPScope ips Where ips.SchemeID = @SchemeID )
			And ia.CustomerID In (Select CustomerID From @BSFCustID) 
			Group By ia.InvoiceID, ia.CustomerID, its.UOM1_Conversion,
			its.UOM2_Conversion, c.Company_Name, c.ChannelType, c.DefaultBeatId, ia.InvoiceType, ia.BeatID
	End
	Else If @UOM In (4)
	--Item based - value based----------
	Begin
		Insert Into @SPTotPoints (InvoiceID , CustomerID , CustomerName , 
		ChannelType , DefaultBeat , RatePerUnit , TPoints , ItemCode , InvType)
		Select ia.InvoiceID, ia.CustomerID, 
		c.Company_Name, 
		(Select Top 1 ChannelDesc From Customer_Channel cc Where cc.ChannelType = c.ChannelType),
		(Select Top 1 Description From Beat bt Where bt.BeatID = ia.BeatID),
		@UR, 
		Sum(idl.Amount), -- * idl.SalePrice),
		'', ia.InvoiceType
		From InvoiceAbstract ia, InvoiceDetail idl, Items its, Customer c
		Where ia.CustomerID = c.CustomerID And ia.InvoiceID = idl.InvoiceID And its.Product_Code = idl.Product_Code And
		ia.Status & 128 = 0 And ia.InvoiceType In (1,3, 4) And 
		ia.InvoiceDate Between @POutFrom And @POutTo And 
		ia.InvoiceDate Between @ActFrom And @ActTo And 
		ia.CreationTime Between @POutFrom And @POutToGraceDays And 
		ia.CustomerID In (Select CustomerID From CustList3 cl3 Where cl3.SchemeID = @SchemeID 
		And cl3.GroupID = @GID And QPS = 0) And 
		idl.Product_Code In (Select ItemCode From IPScope ips Where ips.SchemeID = @SchemeID )
		And ia.CustomerID In (Select CustomerID From @BSFCustID) 
		Group By ia.InvoiceID, ia.CustomerID, its.UOM1_Conversion,
		its.UOM2_Conversion, c.Company_Name, c.ChannelType, c.DefaultBeatId, ia.InvoiceType, ia.BeatID

			--Item based - value based, offtake --------
			Insert Into @OFFTakeTotPoints (InvoiceID , CustomerID , CustomerName , 
			ChannelType , DefaultBeat , RatePerUnit , TPoints , ItemCode , InvType)
			Select 0, ia.CustomerID, 
			c.Company_Name, 
			(Select Top 1 ChannelDesc From Customer_Channel cc Where cc.ChannelType = c.ChannelType),
			(Select Top 1 Description From Beat bt Where bt.BeatID = ia.BeatID),
			@UR, 			
			Sum(((Case ia.InvoiceType When 4 Then -1 Else 1 End) * idl.Amount)), -- * idl.SalePrice),
			'', 0
			From InvoiceAbstract ia, InvoiceDetail idl, Items its, Customer c
			Where ia.CustomerID = c.CustomerID And ia.InvoiceID = idl.InvoiceID And its.Product_Code = idl.Product_Code And
			ia.Status & 128 = 0 And ia.InvoiceType In (1,3, 4) And 
			ia.InvoiceDate Between @POutFrom And @POutTo And 
			ia.InvoiceDate Between @ActFrom And @ActTo And 
			ia.CreationTime Between @POutFrom And @POutToGraceDays And 
			ia.CustomerID In (Select CustomerID From CustList3 cl3 Where cl3.SchemeID = @SchemeID 
			And cl3.GroupID = @GID And QPS = 1) And 
			idl.Product_Code In (Select ItemCode From IPScope ips Where ips.SchemeID = @SchemeID )
			And ia.CustomerID In (Select CustomerID From @BSFCustID) 
			Group By ia.InvoiceID, ia.CustomerID, its.UOM1_Conversion,
			its.UOM2_Conversion, c.Company_Name, c.ChannelType, c.DefaultBeatId, ia.InvoiceType, ia.BeatID
	End
End

----------------------------------------------------------
Else IF @AppOn = 2
--Invoice based scheme
Begin
	Insert Into @TotPoints (InvoiceID , CustomerID , CustomerName , 
		    ChannelType , DefaultBeat , RatePerUnit , TPoints , InvType )
	Select ia.InvoiceID, ia.CustomerID, 
	c.Company_Name, 
	(Select Top 1 ChannelDesc From Customer_Channel cc Where cc.ChannelType = c.ChannelType),
	(Select Top 1 Description From Beat bt Where bt.BeatID = ia.BeatID),
	@UR, 
	ia.NetValue , ia.InvoiceType
	From InvoiceAbstract ia , Customer c
	Where ia.CustomerID = c.CustomerID And ia.Status & 128 = 0 And ia.InvoiceType In (1,3, 4) And 
	ia.InvoiceDate Between @POutFrom And @POutTo And 
	ia.InvoiceDate Between @ActFrom And @ActTo And 
	ia.CreationTime Between @POutFrom And @POutToGraceDays And 
	ia.CustomerID In (Select CustomerID From CustList3 cl3 Where cl3.SchemeID = @SchemeID 
	And cl3.GroupID = @GID And QPS = 0) And
	ia.CustomerID In (Select CustomerID From @BSFCustID) And 
	IsNull((Select Count(Distinct Product_Code) From InvoiceDetail idt 
	Where idt.InvoiceID = ia.InvoiceID), 0) >= @SKUCount

		--offtake 
		Insert Into @OFFTakeTotPoints (InvoiceID , CustomerID , CustomerName , 
	    ChannelType , DefaultBeat , RatePerUnit , TPoints, InvType )
		Select 0, ia.CustomerID, 
		c.Company_Name, 
		(Select Top 1 ChannelDesc From Customer_Channel cc Where cc.ChannelType = c.ChannelType),
		(Select Top 1 Description From Beat bt Where bt.BeatID = ia.BeatID),
		@UR, 
		(Case ia.InvoiceType When 4 Then -1 Else 1 End) * ia.NetValue , 0
		From InvoiceAbstract ia,  Customer c
		Where ia.CustomerID = c.CustomerID And ia.Status & 128 = 0 And ia.InvoiceType In (1,3, 4) And 
		ia.InvoiceDate Between @POutFrom And @POutTo And 
		ia.InvoiceDate Between @ActFrom And @ActTo And 
		ia.CreationTime Between @POutFrom And @POutToGraceDays And 
		ia.CustomerID In (Select CustomerID From CustList3 cl3 Where cl3.SchemeID = @SchemeID 
		And cl3.GroupID = @GID And QPS = 1) 
		And ia.CustomerID In (Select CustomerID From @BSFCustID) 

End

-----Beat appending-----------------------
Declare @CustID nVarchar(256), @DBeat nVarchar(256), @AdBeat nVarchar(4000)

--For table @SPTotPoints-----------------

Set @CustID = ''
Set @DBeat = ''
Set @AdBeat = ''

Declare GetCust Cursor For 
Select Distinct CustomerID From @SPTotPoints
Open GetCust 
Fetch From GetCust Into @CustID
While @@Fetch_Status = 0    
Begin    
	Declare AppBeat Cursor For 
	Select Distinct DefaultBeat From @SPTotPoints spt
	Where spt.CustomerID = @CustID
	Open AppBeat 
	Fetch From AppBeat Into @DBeat
	While @@Fetch_Status = 0    
	Begin    
		Set @AdBeat = IsNull(@AdBeat, '') + ' ' + @DBeat + ' |'
		Fetch Next From AppBeat InTo @DBeat
	End
	Close AppBeat
	DeAllocate AppBeat

	Set @AdBeat = Left(@AdBeat, Len(@AdBeat) - 1)

	Update @SPTotPoints Set DefaultBeat = @AdBeat 
	Where CustomerID = @CustID
	Set @AdBeat = ''

	Fetch Next From GetCust InTo @CustID
End
Close GetCust
DeAllocate GetCust

-------------------------------------------------

--For table @OFFTakeTotPoints-----------------

Set @CustID = ''
Set @DBeat = ''
Set @AdBeat = ''

Declare GetCust Cursor For 
Select Distinct CustomerID From @OFFTakeTotPoints
Open GetCust 
Fetch From GetCust Into @CustID
While @@Fetch_Status = 0    
Begin    
	Declare AppBeat Cursor For 
	Select Distinct DefaultBeat From @OFFTakeTotPoints spt
	Where spt.CustomerID = @CustID
	Open AppBeat 
	Fetch From AppBeat Into @DBeat
	While @@Fetch_Status = 0    
	Begin    
		Set @AdBeat = IsNull(@AdBeat, '') + ' ' + @DBeat + ' |'
		Fetch Next From AppBeat InTo @DBeat
	End
	Close AppBeat
	DeAllocate AppBeat

	Set @AdBeat = Left(@AdBeat, Len(@AdBeat) - 1)

	Update @OFFTakeTotPoints Set DefaultBeat = @AdBeat 
	Where CustomerID = @CustID
	Set @AdBeat = ''

	Fetch Next From GetCust InTo @CustID
End
Close GetCust
DeAllocate GetCust

-------------------------------------------------

--For table @TotPoints-----------------

Set @CustID = ''
Set @DBeat = ''
Set @AdBeat = ''

Declare GetCust Cursor For 
Select Distinct CustomerID From @TotPoints
Open GetCust 
Fetch From GetCust Into @CustID
While @@Fetch_Status = 0    
Begin    
	Declare AppBeat Cursor For 
	Select Distinct DefaultBeat From @TotPoints spt
	Where spt.CustomerID = @CustID
	Open AppBeat 
	Fetch From AppBeat Into @DBeat
	While @@Fetch_Status = 0    
	Begin    
		Set @AdBeat = IsNull(@AdBeat, '') + ' ' + @DBeat + ' |'
		Fetch Next From AppBeat InTo @DBeat
	End
	Close AppBeat
	DeAllocate AppBeat

	Set @AdBeat = Left(@AdBeat, Len(@AdBeat) - 1)

	Update @TotPoints Set DefaultBeat = @AdBeat 
	Where CustomerID = @CustID
	Set @AdBeat = ''

	Fetch Next From GetCust InTo @CustID
End
Close GetCust
DeAllocate GetCust

-------------------------------------------------

------------------------------------------
If @AppOn = 1 And @ItemGp = 2
Begin
	Insert InTo @TotPoints2
	Select InvoiceID , CustomerID , CustomerName , ChannelType , 
	DefaultBeat , RatePerUnit , 

	Case When Sum(IsNull(TPoints, 0)) Between @SStart And @SEnd Then 
		Case When IsNull(@Onward, 0) = 0 Then Case InvType When 4 Then 0 - IsNull(@Value, 0) Else IsNull(@Value, 0) End 
			 Else 
				Case InvType When 4 Then 0 - (Cast((Sum(IsNull(TPoints, 0)) / @Onward ) As Int) * @Value) Else Cast((Sum(IsNull(TPoints, 0)) / @Onward ) As Int)* @Value End 
		End
	End, ItemCode 
	From @SPTotPoints 
	Group By 
	InvoiceID , CustomerID , CustomerName , ChannelType , DefaultBeat , RatePerUnit ,
	ItemCode, InvType

	Insert InTo @TotPoints2
	Select InvoiceID , CustomerID , CustomerName , ChannelType , 
	DefaultBeat , RatePerUnit , 

	Case When ABS(Sum(IsNull(TPoints, 0))) Between @SStart And @SEnd Then 
		Case When IsNull(@Onward, 0) = 0 Then IsNull(@Value, 0) 
			 Else 
				Cast((Sum(IsNull(TPoints, 0)) / @Onward ) As Int)* @Value 
		End
	End,

	ItemCode 
	From @OFFTakeTotPoints
	Group By 
	InvoiceID , CustomerID , CustomerName , ChannelType , DefaultBeat , RatePerUnit ,
	ItemCode 
End
Else
Begin
	Insert InTo @TotPoints2
	Select InvoiceID , CustomerID , CustomerName , ChannelType , 
	DefaultBeat , RatePerUnit , 

	Case When Sum(IsNull(TPoints, 0)) Between @SStart And @SEnd Then 
		Case When IsNull(@Onward, 0) = 0 Then Case InvType When 4 Then 0 - IsNull(@Value, 0) Else IsNull(@Value, 0) End 
			 Else 
				Case InvType When 4 Then 0 - (Cast((Sum(IsNull(TPoints, 0)) / @Onward ) As Int) * @Value) Else Cast((Sum(IsNull(TPoints, 0)) / @Onward ) As Int)* @Value End 
		End
	End,

	ItemCode 
	From @TotPoints
	Group By 
	InvoiceID , CustomerID , CustomerName , ChannelType , DefaultBeat , RatePerUnit ,
	ItemCode , InvType


	Insert InTo @TotPoints2
	Select InvoiceID , CustomerID , CustomerName , ChannelType , 
	DefaultBeat , RatePerUnit , 

	Case When ABS(Sum(IsNull(TPoints, 0))) Between @SStart And @SEnd Then 
		Case When IsNull(@Onward, 0) = 0 Then IsNull(@Value, 0) 
			 Else 
				Cast((Sum(IsNull(TPoints, 0)) / @Onward ) As Int)* @Value 
		End
	End,

	ItemCode 
	From @OFFTakeTotPoints
	Group By 
	InvoiceID , CustomerID , CustomerName , ChannelType , DefaultBeat , RatePerUnit ,
	ItemCode 
End

Return

End
