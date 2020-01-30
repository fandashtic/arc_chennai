CREATE procedure spr_CustomerStatus_Detail (@code int,@FromDate datetime,@ToDate datetime)           
As           
Begin          
Declare @cid as nvarchar(15)          
Declare @cnam as nvarchar(150)          
Declare @bt as nvarchar(255)          
Declare @wdate as nvarchar(20)    
Declare @qry as nvarchar(2000)    
Declare @Other as nvarchar(50)      
Declare @cur_cust Cursor
Declare @Callfreqncy as Int

set dateformat dmy          
set @other = dbo.LookupDictionaryItem(N'Other',default)
    
Create Table #CustomerDet
(
	CustomerId NVarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,
 [Customer Code] nvarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,
	[Customer Name] nvarchar(150) COLLATE SQL_Latin1_General_CP1_CI_AS,
	Beat nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	[Last Purchased On] nVarchar(20) COLLATE SQL_Latin1_General_CP1_CI_AS,
	[Call Frequency] BigInt 
)          
          
-- To insert Total distinct customer detail          
if @code=1          
	begin          
	 set @cur_cust=Cursor for           
	 Select Distinct (cust.customerid), Cust.company_name From Customer cust           
	 Where CustomerCategory <>4 And CustomerCategory <>5              
	          
	 open @cur_cust          
	 fetch next from @cur_cust into @cid,@cnam          
	 while @@fetch_status=0          
	 begin     
	  set @bt=null    
	  Select @bt = bt.Description     
	  From Beat bt,Beat_Salesman bts     
	  Where bts.CustomerId = @cid And bts.beatid = bt.beatid          
	    
	  Select  @wdate = IsNull(Convert(nvarchar ,Max(invoicedate),103),'')     
	  From InvoiceAbstract Where (IsNull(Status,0)& 128)=0     
	 	And (IsNull(Status,0)& 32)=0 And Customerid=@cid     
		 And Invoicedate <= @ToDate    

			Select  @Callfreqncy=Count(SVNumber)  From SVAbstract Where  
			SVAbstract.CustomerId=@cid And 
			DatePart(month,Svdate)=Datepart(month,Dateadd(month,-1,GetDate())) And
			DatePart(Year,Svdate)=Datepart(Year,GetDate()) And  ((IsNull(Status,0)& 32) = 0 and 
  (IsNull(Status,0) & 64) = 0)
	    
	  set @qry ='insert into #CustomerDet values(N''' + @cid + ''', N''' + @cid + ''', N''' + @cnam + ''', N''' + isnull(@bt,@Other) + ''',''' + convert(varchar,isnull(@WDate,''),101)+ ''',' + Cast(@Callfreqncy As NVarChar)+ ')'          
	  fetch next from @cur_cust into @cid,@cnam          
	  exec sp_executesql @qry    
	 end          
	 close @cur_cust          
	end          
	-- To insert Active distinct customer detail          
if @code=2          
	begin          
	 set @cur_cust=Cursor for           
	 Select Distinct cust.CustomerId, cust.Company_Name From Customer cust           
	 Where cust.active=1 And cust.CustomerCategory <>4 And cust.CustomerCategory <>5              
	          
	 open @cur_cust          
	 fetch next from @cur_cust into @cid,@cnam          
	 while @@fetch_status=0          
	 begin          
	  set @bt=null    
	 
		 Select @bt=bt.Description     
		 From Beat bt,Beat_Salesman bts     
		 Where bts.CustomerId = @cid And bt.Beatid = bts.Beatid          
	  Select  @wdate = IsNull(Convert(nvarchar ,Max(invoicedate),103),'') From InvoiceAbstract Where (IsNull(Status,0)& 128)=0 And (IsNull(Status,0)& 32)=0 And Customerid=@cid And Invoicedate <= @ToDate    

			Select  @Callfreqncy=Count(SVNumber)  From SVAbstract Where  
			SVAbstract.CustomerId=@cid And 
			DatePart(month,Svdate)=Datepart(month,Dateadd(month,-1,GetDate())) And
			DatePart(Year,Svdate)=Datepart(Year,GetDate()) And  ((IsNull(Status,0)& 32) = 0 and 
  (IsNull(Status,0) & 64) = 0)

	  set @qry='insert into #CustomerDet values(N''' + @cid + ''',N'''+ @cid + ''',N''' + @cnam + ''',''' + isnull(@bt,@Other) + ''',''' + @WDate +''',' + Cast(@Callfreqncy As NVarChar)+ ')'          
	  fetch next from @cur_cust into @cid,@cnam          
	  exec sp_executesql @qry          
	 end          
	 close @cur_cust          
	end          
-- To insert Contacted distinct customer detail          
if @code=3          
	begin          
	 set @cur_cust=Cursor for     
	 Select Distinct cust.Customerid, cust.Company_Name    
	 From wcpabstract WCPAB, wcpdetail WCPDT, customer cust    
	 Where (isnull(WCPAB.status,0)& 128) =0 And (isnull(WCPAB.status,0)& 32) =0     
	 And WCPAB.code = WCPDT.code And WCPDT.wcpdate Between @FromDate And @ToDate     
	 And WCPDT.customerid = cust.customerid           
	 And cust.CustomerCategory <>4     
	 And cust.CustomerCategory <>5               
	         
	 open @cur_cust          
	 fetch next from @cur_cust into @cid,@cnam          
	 while @@fetch_status=0          
	 begin          
	  set @bt=null    
	  
			Select @bt=bt.Description     
		 From Beat bt,Beat_Salesman bts     
		 Where bts.CustomerId = @cid And bt.Beatid = bts.Beatid       
	  Select  @wdate = IsNull(Convert(nvarchar ,Max(invoicedate),103),'') From InvoiceAbstract Where (IsNull(Status,0)& 128)=0 And (IsNull(Status,0)& 32)=0 And Customerid=@cid And Invoicedate <= @ToDate    

			Select  @Callfreqncy=Count(SVNumber)  From SVAbstract Where  
			SVAbstract.CustomerId=@cid And 
			DatePart(month,Svdate)=Datepart(month,Dateadd(month,-1,GetDate())) And
			DatePart(Year,Svdate)=Datepart(Year,GetDate()) And  ((IsNull(Status,0)& 32) = 0 and 
  (IsNull(Status,0) & 64) = 0)
	    
	  set @qry='insert into #CustomerDet values(N''' + @cid + ''',N'''+ @cid + ''',N''' + @cnam + ''',''' + isnull(@bt,@Other) + ''',''' + convert(varchar,@WDate,101) +''',' + Cast(@Callfreqncy As NVarChar)+  ')'          
	  fetch next from @cur_cust into @cid,@cnam         
	  exec sp_executesql @qry          
	    
	 end          
	 close @cur_cust          
	end          
-- To insert Not Contacted distinct customer detail          
if @code=4          
	begin          
	 set @cur_cust=Cursor for           
	 Select Distinct cust.customerid, cust.company_name From customer cust  
	 Where cust.customerid Not In ( Select Distinct WCPDT.CustomerId     
	 From wcpabstract WCPAB, wcpdetail WCPDT            
	 Where (IsNull(WCPAB.status,0)& 128 )=0 And (IsNull(WCPAB.status,0)& 32 )=0     
	  And WCPAB.code = WCPDT.code And (WCPDT.wcpdate Between @FromDate And @ToDate))           
	 And cust.Active = 1  And cust.CustomerCategory <>4 And cust.CustomerCategory <>5              
	    
	 open @cur_cust          
	 fetch next from @cur_cust into @cid,@cnam          
	 while @@fetch_status=0          
	 begin          
	  set @bt=null    

	  Select @bt=bt.Description From Beat bt, Beat_Salesman bts Where bts.CustomerId = @cid And bts.beatid=bt.beatid           

	  Select  @wdate = IsNull(Convert(nvarchar ,Max(invoicedate),103),'') From InvoiceAbstract Where (IsNull(Status,0)& 128)=0 And (IsNull(Status,0)& 32)=0 And Customerid=@cid And Invoicedate <= @ToDate    

			Select  @Callfreqncy=Count(SVNumber)  From SVAbstract Where  
			SVAbstract.CustomerId=@cid And 
			DatePart(month,Svdate)=Datepart(month,Dateadd(month,-1,GetDate())) And
			DatePart(Year,Svdate)=Datepart(Year,GetDate()) And  ((IsNull(Status,0)& 32) = 0 and 
  (IsNull(Status,0) & 64) = 0)

	  set @qry='insert into #CustomerDet values(N''' + @cid + ''',N'''+ @cid + ''',N''' + @cnam + ''',''' + isnull(@bt,@Other) + ''',''' + convert(varchar,@WDate,101) +''',' + Cast(@Callfreqncy As NVarChar)+ ')'          
	  fetch next from @cur_cust into @cid,@cnam          
	  exec sp_executesql @qry          
	 end          
	 close @cur_cust          
	end          
-- To insert Productive distinct customer detail          
if @code=5          
	begin          
	 set @cur_cust=Cursor for     
	 Select Distinct cust.CustomerId, cust.Company_Name           
	 From Customer cust,SoAbstract soa           
	 Where (IsNull(soa.status,0) & 64) = 0 And (IsNull(soa.status,0) & 32) = 0     
	 And soa.sodate Between @FromDate And @ToDate And soa.customerid = cust.customerid           
	 And cust.CustomerCategory <>4 And cust.CustomerCategory <>5              
	          
	 open @cur_cust          
	 fetch next from @cur_cust into @cid,@cnam    
	 while @@fetch_status=0          
	 begin    
	  set @bt=null          
	  Select @bt=bt.Description     
		 From Beat bt,Beat_Salesman bts     
		 Where bts.CustomerId = @cid And bt.Beatid = bts.Beatid       

	  Select  @wdate = IsNull(Convert(nvarchar ,Max(invoicedate),103),'') From InvoiceAbstract Where (IsNull(Status,0)& 128)=0 And (IsNull(Status,0)& 32)=0 And Customerid=@cid And Invoicedate <= @ToDate    

			Select  @Callfreqncy=Count(SVNumber)  From SVAbstract Where  
			SVAbstract.CustomerId=@cid And 
			DatePart(month,Svdate)=Datepart(month,Dateadd(month,-1,GetDate())) And
			DatePart(Year,Svdate)=Datepart(Year,GetDate()) And  ((IsNull(Status,0)& 32) = 0 and 
  (IsNull(Status,0) & 64) = 0)

	  set @qry='insert into #CustomerDet values(N''' + @cid + ''',N'''+ @cid + ''',N''' + @cnam + ''',''' + isnull(@bt,@Other) + ''',''' + convert(varchar,@WDate,101) +''',' + Cast(@Callfreqncy As NVarChar)+ ')'          
	  fetch next from @cur_cust into @cid,@cnam    
	  exec sp_executesql @qry          
	 End          
	 Close @cur_cust          
	End          

Deallocate @cur_cust          

Select * From #CustomerDet    

Drop Table #CustomerDet          
End          
          
