create procedure mERP_Spr_PointSchNonClaimDetail( @KeyData As nVarchar(50))
as
	 SET Dateformat DMY  
	 Declare @FromDate datetime
	 Declare @ToDate datetime
	 Declare @nSchemeID int
	 Declare @PayoutId int 

	 Declare @Delimeter as char(1)  
	 Set @Delimeter = Char(15)  

	 Declare @TmpParameters Table  
	 ([RowID] Int Identity(1,1), KeyValue nVarchar(2510) COLLATE SQL_Latin1_General_CP1_CI_AS)  
	 Insert Into @TmpParameters  
	 select * from dbo.sp_splitin2Rows(@KeyData,@Delimeter) 

	 Set @PayoutID = (Select KeyValue from @TmpParameters Where [RowID]=1)
	 Set @nSchemeID = (Select KeyValue from @TmpParameters Where [RowID]=2)
	 Select @FromDate = PayoutPeriodFrom ,@ToDate = PayoutPeriodTo From tbl_mERP_SchemePayoutPeriod SPP Where ID = @PayoutID

	  
	 Declare @RFAClaim int  
	 Declare @PayStatus int  
	 Declare @LastRFAStatus int  
	   
	 Declare @UnitRate decimal(18,6)  
	   
	 select @RFAClaim = isnull(RFAApplicable,0) from tbl_merp_schemeabstract where schemeid = @nSchemeID   
	 select @PayStatus = isnull(Status,0) from tbl_merp_schemePayOutPeriod where [id]=@PayoutID 
	 /* Since 128 status is introduced for data posting, we are checking the below condition*/
	 if (@PayStatus = 128 or @PayStatus = 129) 
		set @PayStatus  = 0
	 select @LastRFAStatus = RFAStatus from tbl_mERP_CSRedemption where schemeid=@nSchemeId and PayoutId=@Payoutid and RFAStatus <> 2      
	 and Id = (select max(ID) from tbl_mERP_CSRedemption where schemeid=@nSchemeId and PayoutId=@Payoutid and RFAStatus <> 2)      
	 Select @UnitRate= SS.UnitRate from tbl_mERP_SchemeSlabDetail SS  where schemeID=@nSchemeID  	   

	 Create Table #tmpOutlet (OutletCode nvarchar(30),Company_Name nvarchar(300),ChannelDesc nvarchar(255),Points decimal(18,6), Redeemed decimal(18,6),  
	 RedeemValue decimal(18,6),AmountSpent decimal(18,6),PlannedPayout nvarchar(4000))  
	 Create Table #tmpfinal (OutletCode nvarchar(30),Company_Name nvarchar(300),ChannelDesc nvarchar(255),Points decimal(18,6), Redeemed decimal(18,6),  
	 RedeemValue decimal(18,6),AmountSpent decimal(18,6),PlannedPayout nvarchar(4000))  

	 	   
	  --FOR NON QPS
	  insert into #tmpOutlet (OutletCode,Company_Name,ChannelDesc,Points,Redeemed,RedeemValue,AmountSpent,PlannedPayout)  
	  select  PA.OutletCode,C.Company_Name,cc.ChannelDesc,PA.Points,0 [Redeemed],0 [RedeemedValue],0 [AmountSpent],'' [PlannedPayout]  
	  from Customer C,Customer_Channel CC ,tbl_mERP_CSOutletPointAbstract PA
	  Where C.ChannelType=CC.ChannelType   
	  AND isnull(PA.QPS,0)=0
	  /* If Sales Return is made greater than sales quantity then that customer should not be shown in redeemption screen is handled by removing points checking*/
	  --AND Points > 0  
	  AND PA.SchemeID=@nSchemeID  
	  --And PA.PayoutID =@PayoutId  
	  And PA.OutletCode=C.CustomerID  
	  And dbo.stripdatefromtime(PA.TransactionDate) between @FromDate and @ToDate  
	  UNION ALL
	  --FOR QPS
	  select  PA.OutletCode,C.Company_Name,cc.ChannelDesc,PA.Points,0 [Redeemed],0 [RedeemedValue],0 [AmountSpent],'' [PlannedPayout]  
	  from Customer C,Customer_Channel CC ,tbl_mERP_CSOutletPointAbstract PA
	  Where C.ChannelType=CC.ChannelType   
	  AND isnull(PA.QPS,0)=1
	  /* If Sales Return is made greater than sales quantity then that customer should not be shown in redeemption screen is handled by removing points checking*/
	  --AND Points > 0  
	  AND PA.SchemeID=@nSchemeID  
	  And PA.PayoutID =@PayoutId  
	  And PA.OutletCode=C.CustomerID  
	  --And dbo.stripdatefromtime(PD.InvoiceDate) between @FromDate and @ToDate  
 
	If (@PayStatus <> 1 or @Paystatus <> 192) --RFA not claimed or not dropped      
	BEGIN   
		  insert into #tmpOutlet (OutletCode,Company_Name,ChannelDesc,Points,Redeemed,RedeemValue,AmountSpent,PlannedPayout)  
		  select  OutletCode,C.Company_Name,cc.ChannelDesc,0,T.RedeemedPoints,T.RedeemValue,T.AmountSpent,T.PlannedPayout  
		  from tbl_merp_CSRedemption T, Customer C,Customer_Channel CC  
		  where C.ChannelType=CC.ChannelType   
		  And T.outletcode = C.CustomerID  
		  And SchemeId=@nSchemeID  
		  And PayoutID=@PayoutId  
		  And RFAStatus = @LastRFAStatus and RFAstatus <>2  
	END   

	insert into #tmpfinal (OutletCode,Company_Name,ChannelDesc,Points,Redeemed,RedeemValue,AmountSpent)
	select distinct OutletCode,Company_Name,ChannelDesc,sum(points) as Points,sum(Redeemed) as Redeemed,sum(RedeemValue) as RedeemValue,sum(AmountSpent) as AmountSpent  from #tmpOutlet  
	group by OutletCode,Company_Name,ChannelDesc 
	having sum(points)>0  order by Company_Name

	update #tmpfinal set PlannedPayout = T1.PlannedPayout
	from
	(select T.outletcode, T.PlannedPayout from tbl_merp_CSRedemption T, Customer C,Customer_Channel CC  
		  where C.ChannelType=CC.ChannelType   
		  And T.outletcode = C.CustomerID  
		  And SchemeId=@nSchemeID  
		  And PayoutID=@PayoutId  
		  And RFAStatus = @LastRFAStatus and RFAstatus <>2) T1
	where T1.outletcode = #tmpfinal.outletcode

	select distinct OutletCode,OutletCode [Outlet Code],Company_Name [Outlet Name],Points [Total Points],AmountSpent [Total Spent],Redeemed [Redeemed Points] from #tmpfinal 
	
	order by company_name
	
Drop table #tmpOutlet
Drop table #tmpfinal
 	
