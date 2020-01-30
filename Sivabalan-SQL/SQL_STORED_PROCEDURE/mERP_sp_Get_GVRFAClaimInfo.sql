CREATE Procedure mERP_sp_Get_GVRFAClaimInfo(@Type as Int,@FromMonth nvarchar(100),@ToMonth nvarchar(100))     
As    
Set Dateformat dmy    
    
	Declare @Prefix nVarchar(50)    
	Declare @CloseDay int    
	Declare @ProcessDate Datetime    

	Create Table #Temp (ID int Identity(1,1),
	DocID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
	DocType nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	DocIDNo nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
	FMonth nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
	LMonth nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, 
	DocDate DateTime,    
	SchemeType  Int, 
	ClaimID Int, ClaimAmount decimal(18,6), LoyaltyID nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, MName nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS    
	,GVYear nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, RFAStatus nVarchar(2000) COLLATE SQL_Latin1_General_CP1_CI_AS)    

	Create Table #TempFinal (ID int Identity(1,1),  DocID nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, DocType nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,  
	DocIDNo nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, FMonth nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS, LMonth nVarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,     
	SchemeType  Int, ClaimID Int, ClaimAmount decimal(18,6), LoyaltyID nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, MName nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS, 
	DocDate DateTime,GVYear nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS)    

	Select @Prefix = Prefix  From VoucherPrefix Where TranID = 'GIFT VOUCHER'    

	Declare @ldlm SMALLDATETIME    
	Declare @ldtm SMALLDATETIME    
	Declare @fdtm SMALLDATETIME    
	Declare @refm SMALLINT    
	Declare @thisDay TINYINT    
	Declare @refd datetime    
	Declare @today datetime    
	Declare @GVFirstDay int    
	Declare @GVFirstMonth int    
	Declare @GVFirstYear int    
	Declare @GVlastDay int    
	Declare @Firstmonth nVarchar(1000)    
	Declare @lastmonth nVarchar(1000)    

	Declare @D1 DateTime    
	Declare @D2 DateTime    
	Declare @LastDate as Int    


	Declare @Dy int    
	Declare @Mth int    
	Declare @Yr int    

	Declare @LDy int    
	Declare @LMth int    
	Declare @LYr int    
	Declare @DocID nVarchar(1000)    
	Declare @DocDate datetime    

	Declare @PrevM datetime    
	Declare @MonthName nVarchar(10)    
	Declare @Year nVarchar(10)    

	Select @PrevM = DateAdd(m, -1, GetDate())    

	Select @MonthName = CONVERT(varchar(3), @PrevM, 100)     
	Select @Year = datepart(year,@PrevM)    


	Select @CloseDay = IsNull(Flag, 0) From tbl_mERP_ConfigAbstract Where ScreenCode = 'CLSDAY01'    

	If (@CloseDay) > 0    
	Begin    
		Select @ProcessDate =  isNull(LastInventoryUpload,'') From Setup    
	End    


	--If @Type = 4 /*Gift Voucher*/    
	--BEGIN
		If @CloseDay = 1    
		Begin    
			Insert Into #Temp     
			(DocID , DocType , DocIDNo,  -- FMonth , LMonth ,     
			SchemeType, ClaimAmount, LoyaltyID, MName, GVYear    
			, RFAStatus,DocDate)     
			Select      
			Loyalty.LoyaltyName     
			,Loyalty.LoyaltyName    
			,GiftVoucherNo,    
			'10' as SchemeType    
			, Sum(NoteValue-Balance)    
			, Loyalty.LoyaltyID    
			, CONVERT(varchar(3), dbo.StripTimeFromDate(DocumentDate), 100)     
			, datepart(year,Convert(DateTime,dbo.StripTimeFromDate(DocumentDate)))    
			,Case CreditNote.LoyaltyID when 'L2' then 'First Club' When 'L3' then 'Shubh labh' end + '-' +    
			CONVERT(varchar(3), dbo.StripTimeFromDate(DocumentDate), 100) + '-' + Convert(Varchar(100), Convert(Varchar(100), datepart(year,Convert(DateTime,dbo.StripTimeFromDate(DocumentDate))))),
			DocumentDate 
			From CreditNote Inner join Loyalty On CreditNote.LoyaltyID = Loyalty.LoyaltyID    
			Where IsNull(Flag, 0) = 2    
			And Case When @Type = 4 Then DocumentDate  Else dbo.mERP_fn_getFromDate(@FromMonth) End 
			Between dbo.mERP_fn_getFromDate(@FromMonth) and dbo.mERP_fn_getToDate(@ToMonth)  
			and IsNull(ClaimRFA,0) = 0    
			and IsNull(Status,0) not in (64,128)    
			--And DateDiff(d, GetDate(), '01/' + Cast(Month(DATEADD(Month, 1, dbo.StripTimeFromDate(DocumentDate))) as nVarchar(10)) + '/' + Cast(Year(DATEADD(Month, 1, dbo.StripTimeFromDate(DocumentDate))) as nVarchar(10))) <= 0    
			--Nov 11     
			--And CONVERT(varchar(3), dbo.StripTimeFromDate(DocumentDate), 100) = CONVERT(varchar(3), dbo.StripTimeFromDate(CreationTime), 100)    
			--And dbo.striptimeFromDate(DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE())+1,0))) <= dbo.StripTimeFromDate(@ProcessDate)     
			And DateDiff(d, DateADD(d, 1, @ProcessDate), '01/' + Cast(Month(DATEADD(Month, 1, dbo.StripTimeFromDate(DocumentDate))) as nVarchar(10)) 
			+ '/' + Cast(Year(DATEADD(Month, 1, dbo.StripTimeFromDate(DocumentDate))) as nVarchar(10))) <= 0    
			--And dbo.StripTimeFromDate(DocumentDate) <= dbo.StripTimeFromDate(@ProcessDate)    
			--Nov 11    
			And CreditNote.Loyaltyid in ('L1','L2','L3')    
			Group By  CreditNote.LoyaltyID, Loyalty.LoyaltyName, GiftVoucherNo, NoteValue --, CreditID    
			, Loyalty.LoyaltyID, CreditNote.DocumentDate    
		End    
		Else    
		Begin    
			Insert Into #Temp     
			(DocID , DocType , DocIDNo,  -- FMonth , LMonth ,     
			SchemeType, ClaimAmount, LoyaltyID, MName, GVYear, RFAStatus,DocDate)     
			Select      
			Loyalty.LoyaltyName --+ '-' + @MonthName + '-' + @Year,    
			,Loyalty.LoyaltyName --+ '-' + @MonthName + '-' + @Year,    
			,GiftVoucherNo,    
			'10' as SchemeType    
			, Sum(NoteValue-Balance)
			, Loyalty.LoyaltyID    
			--, CreditID    
			, CONVERT(varchar(3), dbo.StripTimeFromDate(DocumentDate), 100)     
			, datepart(year,Convert(DateTime,dbo.StripTimeFromDate(DocumentDate)))    
			,Case CreditNote.LoyaltyID when 'L2' then 'First Club' When 'L3' then 'Shubh labh' end + '-' +    
			CONVERT(varchar(3), dbo.StripTimeFromDate(DocumentDate), 100) + '-' + Convert(Varchar(100), Convert(Varchar(100), datepart(year,Convert(DateTime,dbo.StripTimeFromDate(DocumentDate))))),
			DocumentDate    
			From CreditNote Inner join Loyalty On CreditNote.LoyaltyID = Loyalty.LoyaltyID    
			Where IsNull(Flag, 0) = 2    
			And Case When @Type = 4 Then DocumentDate  Else dbo.mERP_fn_getFromDate(@FromMonth) End 
			Between dbo.mERP_fn_getFromDate(@FromMonth) and dbo.mERP_fn_getToDate(@ToMonth)  
			and IsNull(ClaimRFA,0) = 0    
			and IsNull(Status,0) not in (64,128)    
			And DateDiff(d, GetDate(), '01/' + Cast(Month(DATEADD(Month, 1, dbo.StripTimeFromDate(DocumentDate))) as nVarchar(10)) 
			+ '/' + Cast(Year(DATEADD(Month, 1, dbo.StripTimeFromDate(DocumentDate))) as nVarchar(10))) <= 0    
			--Nov 11     
			--And CONVERT(varchar(3), dbo.StripTimeFromDate(DocumentDate), 100) = CONVERT(varchar(3), dbo.StripTimeFromDate(DocumentDate), 100)    
			--Nov 11    
			And CreditNote.Loyaltyid in ('L1','L2','L3')        
			Group By  CreditNote.LoyaltyID, Loyalty.LoyaltyName, GiftVoucherNo, NoteValue --, CreditID    
			, Loyalty.LoyaltyID,  CreditNote.DocumentDate    
		End		
		
		Declare MyCur Cursor For    
		Select DocIDNo from #Temp  Order By ID     
		Open MyCur    
		Fetch From MyCur Into @DocID    
		While @@Fetch_Status = 0    
		Begin    
			Select @DocDate = DocumentDate From creditNote where IsNull(Flag, 0) = 2    
			And GiftVoucherNO = @DocID    
			and IsNull(ClaimRFA,0) = 0    
			and IsNull(Status,0) not in (64,128)    

			Select @D1 = @DocDate    
			Select @D1 = Convert(DateTime, '01/' +  Cast(Month(@D1) as nVarchar) + '/' + Cast(Year(@D1) as nVarchar) , 103)    

			Select @D2 = DateAdd(Month, 1, @D1)    
			Set @LastDate = Day(DateAdd(Day,-1, @D2))    
			SEt @D2 = Cast(@LastDate as nVarchar) + '/' + Cast(Month(@D1) as nVarchar) + '/' + Cast(Year(@D1) as nVarchar)    

			Set @Dy = Day(@D1)    
			Set @Mth = Month(@D1)    
			Set @yr = year (@D1)    

			Set @LDy = Day(@D2)    
			Set @LMth = Month(@D2)    
			Set @LYr = year (@D2)    

			Select @Firstmonth = Cast(@Dy as nVarchar(30)) + '/' + Cast(@Mth as nVarchar(30)) + '/' +    
				Cast(@yr as nVarchar(30))     

			Select @Lastmonth  = Cast(@LDy as nVarchar(30)) + '/' + Cast(@LMth as nVarchar(30)) + '/' +    
				Cast(@LYr as nVarchar(30))     

			Update #temp Set FMonth =  @Firstmonth, LMonth= @Lastmonth Where DocIDNo = @DocID    
			  
			Fetch Next From MyCur Into @DocID    
		End    
		close  MyCur    
		Deallocate Mycur    

	--Select @MonthName = CONVERT(varchar(3), Fmonth, 100)     
	--Select @Year = datepart(year,@PrevM)    


		Insert Into #TempFinal(DocID, DocType, FMonth, LMonth, SchemeType, ClaimAmount, LoyaltyID, MName,DocDate )    
		Select Distinct DocID + '-' + MName + '-' + GVyear as ActivityCode, DocType + '-' + MName + '-' + GVyear as Description,      
		FMonth As MonthFirstDay, LMonth As MonthLastDay,     
		SchemeType, Sum(ClaimAmount), LoyaltyID, MName + '-' + GVYear,DocDate      
		from #temp where RFAStatus Not In ( Select Remarks from ClaimsNote where Claimtype = 10 and IsNull(Status,0) <> 5)    
		Group By LoyaltyID, DocID, DocType, FMonth, LMonth, SchemeType, MName, GVyear,DocDate   
		/* CLO Changes starts */  
			Insert Into #TempFinal (DocID, DocType, FMonth, LMonth, SchemeType, ClaimAmount, LoyaltyID, MName,DocDate)    
			Select CLO.ActivityCode,'CLO CreditNote',
			CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(CLO.CLODate)-1),CLO.CLODate),103) as FMonth, 
			CONVERT(VARCHAR(25),DATEADD(dd,-(DAY(DATEADD(mm,1,CLO.CLODate))),DATEADD(mm,1,CLO.CLODate)),103) as LMonth,
			'10' as SchemeType, Sum(IsNull(NoteValue,0)-IsNull(Balance,0)) as ClaimAmount,CLO.ActivityCode,
			--CONVERT(varchar(3), dbo.StripTimeFromDate(CLO.CLODate), 100)  as MName
			Convert(Varchar(3), CLO.CLODate, 100) + '-' + Convert(Varchar(4), CLO.CLODate,112) as MName,
			dbo.mERP_fn_getToDate(CLO.CLOMonth)   
			from CLOCrnote CLO,CreditNote CN
			Where CLO.CreditID=CN.CreditID	     
			And IsNull(Flag, 0) = 1    
			And Case When @Type = 4 Then dbo.mERP_fn_getFromDate(CLO.CLOMonth) Else dbo.mERP_fn_getFromDate(@FromMonth) End 
			Between dbo.mERP_fn_getFromDate(@FromMonth) and dbo.mERP_fn_getToDate(@ToMonth)  
			And DateDiff(d, DateADD(d, 1, @ProcessDate), '01/' + Cast(Month(DATEADD(Month, 1, dbo.StripTimeFromDate(CLO.CLODate))) as nVarchar(10)) 
			+ '/' + Cast(Year(DATEADD(Month, 1, dbo.StripTimeFromDate(CLO.CLODate))) as nVarchar(10))) <= 0    
			and IsNull(ClaimRFA,0) = 0    
			and IsNull(Status,0) not in (64,128)    
			And CN.Loyaltyid not in ('L1','L2','L3')  
			And CLO.ActivityCode not in (select distinct ActivityCode from CLOCrnote where isRFAClaimed=1)
			Group by CLO.ActivityCode,LoyaltyID,CLODate,CLOMonth
			
		/* CLO Changes Ends */
		--Select * from #TempFinal    
		--Select Distinct  DocID as ActivityCode, DocType as Description,  FMonth As MonthFirstDay, LMonth As MonthLastDay    
		--, SchemeType, ClaimAmount, LoyaltyID    
		--, (Case When IsNull(LoyaltyID,'') = 'L2' then 1 Else 2 end) As RFAID    
		--, MName    
		--from #TempFinal    
    
		--Consolidated     
		--For getting Expiry Month
		Declare @Expiry int
		Select @Expiry=isnull(Value,0) from tbl_merp_configdetail where Screencode='SENDRFA' and ControlName='Expiry'
		--If expiry is zero then dont consider the Expiry
	
	If @Type = 4 --Pending
	BEGIN
		Select Distinct  DocID as ActivityCode, DocType as Description,  FMonth As MonthFirstDay, LMonth As MonthLastDay    
		, SchemeType, ClaimAmount, LoyaltyID, (Case When IsNull(LoyaltyID,'') = 'L2' then 1 Else 2 end) As RFAID, MName    
		from #TempFinal  
		Where (datediff(d,dateadd(m,@Expiry,DocDate),getdate())) <= 0
	END
	Else IF @Type = 7  --Expired
	Begin
		Select Distinct  DocID as ActivityCode, DocType as Description,  FMonth As MonthFirstDay, LMonth As MonthLastDay    
		, SchemeType, ClaimAmount, LoyaltyID, (Case When IsNull(LoyaltyID,'') = 'L2' then 1 Else 2 end) As RFAID, MName    
		from #TempFinal
		Where (datediff(d,dateadd(m,@Expiry,DocDate),getdate())) > 0
	End
		
	--END
	Drop Table #Temp    
	Drop table #TempFinal 
