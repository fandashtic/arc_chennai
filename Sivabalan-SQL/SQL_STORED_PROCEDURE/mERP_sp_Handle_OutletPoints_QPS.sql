
Create procedure mERP_sp_Handle_OutletPoints_QPS(@FromDate datetime,@ToDate datetime,@nSchemeID int,@FromPoints decimal(18,6) = 0,@ToPoints decimal(18,6) =0,@PayoutId int)      
as      
BEGIN  
	 SET NOCOUNT ON  

	 SET Dateformat DMY  
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

	 Create Table #tmpAbstract(OutletCode nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,UnitRate decimal(18,6),RFAClaim int,PayStatus int,points decimal(18,6))   
	 Create Table #tmpOutlet (OutletCode nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,Company_Name nvarchar(300) COLLATE SQL_Latin1_General_CP1_CI_AS,ChannelDesc nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,Points decimal(18,6), Redeemed decimal(18,6),  
	 RedeemValue decimal(18,6),AmountSpent decimal(18,6),PlannedPayout nvarchar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS)  
	 Create Table #tmpfinal (OutletCode nvarchar(30) COLLATE SQL_Latin1_General_CP1_CI_AS,Company_Name nvarchar(300) COLLATE SQL_Latin1_General_CP1_CI_AS,ChannelDesc nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,Points decimal(18,6), Redeemed decimal(18,6),  
	 RedeemValue decimal(18,6),AmountSpent decimal(18,6),PlannedPayout nvarchar(4000) COLLATE SQL_Latin1_General_CP1_CI_AS)  

	 -- If From points and To Points are NOT given  
	 if @FromPoints= 0 and @ToPoints=0  
	 BEGIN
		   
		   --FOR NON QPS  
		  insert into #tmpAbstract (Outletcode,UnitRate,RFAClaim,PayStatus,points)
		  select  distinct PA.OutletCode,@UnitRate ,@RFAClaim ,@PayStatus,sum(points)from tbl_mERP_CSOutletPointAbstract PA
		  where PA.SchemeID=@nSchemeID  
		  AND isnull(PA.QPS,0)=0
	      /* If Sales Return is made greater than sales quantity then that customer should not be shown in redeemption screen is handled by removing points checking*/
		  --AND Points > 0  
		  --And PA.PayoutID =@PayoutId  
		  And dbo.stripdatefromtime(PA.TransactionDate) between @FromDate and @ToDate 
		  group by PA.OutletCode
          having sum(points) > 0
	 
		  UNION ALL
		  --FOR QPS
		  select  distinct PA.OutletCode,@UnitRate ,@RFAClaim ,@PayStatus,sum(points) from tbl_mERP_CSOutletPointAbstract PA
		  where PA.SchemeID=@nSchemeID  
		  AND isnull(PA.QPS,0)=1
		  /* If Sales Return is made greater than sales quantity then that customer should not be shown in redeemption screen is handled by removing points checking*/
		  --AND Points > 0  
		  And PA.PayoutID =@PayoutId  
		  group by	PA.OutletCode
		  having sum(points) > 0

		  --And dbo.stripdatefromtime(PD.InvoiceDate) between @FromDate and @ToDate  
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

	END  
	ELSE  
	 -- If From points and To Points ARE given  
	BEGIN  
		  --FOR NON QPS
		  insert into #tmpAbstract (Outletcode,UnitRate,RFAClaim,PayStatus,points)
		  select distinct PA.OutletCode,@UnitRate,@RFAClaim ,@PayStatus,sum(points) from tbl_mERP_CSOutletPointAbstract PA   
		  where PA.SchemeID=@nSchemeID
		  AND isnull(PA.QPS,0)=0 
          /* If Sales Return is made greater than sales quantity then that customer should not be shown in redeemption screen is handled by removing points checking*/
		  --AND Points > 0   
		  --And PA.PayoutID =@PayoutId  	
		  And dbo.stripdatefromtime(PA.TransactionDate) between @FromDate and @ToDate  
		  And points between @FromPoints and @ToPoints 
		  group by PA.OutletCode
		  having sum(points) > 0 

		  UNION ALL
		  --FOR QPS
		  select  distinct PA.OutletCode,@UnitRate ,@RFAClaim ,@PayStatus,sum(points) from tbl_mERP_CSOutletPointAbstract PA
		  where PA.SchemeID=@nSchemeID  
		  AND PA.isnull(QPS,0)=1
          /* If Sales Return is made greater than sales quantity then that customer should not be shown in redeemption screen is handled by removing points checking*/
		  --AND Points > 0  
		  And PA.PayoutID =@PayoutId  
		  --And dbo.stripdatefromtime(PD.InvoiceDate) between @FromDate and @ToDate  
		  And points between @FromPoints and @ToPoints  
		  group by	PA.OutletCode
		  having sum(points) > 0

		  --FOR NON QPS
		  insert into #tmpOutlet (OutletCode,Company_Name,ChannelDesc,Points,Redeemed,RedeemValue,AmountSpent,PlannedPayout)  
		  select  PA.OutletCode,C.Company_Name,cc.ChannelDesc,Points,0 [Redeemed],0 [RedeemedValue],0 [AmountSpent],'' [PlannedPayout]  
		  from Customer C,Customer_Channel CC ,tbl_mERP_CSOutletPointAbstract PA 
		  Where C.ChannelType=CC.ChannelType   
		  AND isnull(PA.QPS,0)=0
		  AND PA.SchemeID=@nSchemeID  
		  --And PA.PayoutID =@PayoutId  
		  And PA.OutletCode=C.CustomerID  
		  --And PA.SchemeID = PD.schemeID
		  --AND PA.PayoutID = PD.PayoutID
		  --AND PA.OutletCode=PD.OutletCode		
		  And dbo.stripdatefromtime(PA.TransactionDate) between @FromDate and @ToDate 
          /* If Sales Return is made greater than sales quantity then that customer should not be shown in redeemption screen is handled by removing points checking*/
		  --AND Points > 0  
		  And points between @FromPoints and @ToPoints  
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
		  And points between @FromPoints and @ToPoints 
	END  
	If (@PayStatus <> 1 or @Paystatus <> 192) --RFA not claimed or not dropped      
	BEGIN   

		 insert into #tmpAbstract (Outletcode,UnitRate,RFAClaim,PayStatus)
		 select '', @UnitRate,@RFAClaim ,@PayStatus 
		  from tbl_merp_CSRedemption T, Customer C,Customer_Channel CC  
		  where C.ChannelType=CC.ChannelType   
		  And T.outletcode = C.CustomerID  
		  And SchemeId=@nSchemeID  
		  And PayoutID=@PayoutId  
		  And RFAStatus = @LastRFAStatus and RFAstatus <>2  

		  insert into #tmpOutlet (OutletCode,Company_Name,ChannelDesc,Points,Redeemed,RedeemValue,AmountSpent,PlannedPayout)  
		  select  OutletCode,C.Company_Name,cc.ChannelDesc,0,T.RedeemedPoints,T.RedeemValue,T.AmountSpent,T.PlannedPayout  
		  from tbl_merp_CSRedemption T, Customer C,Customer_Channel CC  
		  where C.ChannelType=CC.ChannelType   
		  And T.outletcode = C.CustomerID  
		  And SchemeId=@nSchemeID  
		  And PayoutID=@PayoutId  
		  And RFAStatus = @LastRFAStatus and RFAstatus <>2  
	END   
	select count(distinct Outletcode),UnitRate,RFAClaim,PayStatus from #tmpAbstract where outletcode <> ''
	group by UnitRate,RFAClaim,PayStatus 	

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

	select * from #tmpfinal order by company_name

	Drop table #tmpAbstract
	Drop table #tmpOutlet
	Drop table #tmpfinal

    SET NOCOUNT OFF
END  
