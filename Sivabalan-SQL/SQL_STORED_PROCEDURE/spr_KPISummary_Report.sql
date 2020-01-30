CREATE procedure spr_KPISummary_Report              
(
	@FromDate DateTime,
	@SalesmanCode nVarChar(255)
)                      
as               
Declare @CurSalesmanCode nVarChar(15)        
Declare @CurSalesmanCode1 nVarChar(15)        
Declare @SalesName nVarChar(255)                 
Declare @VolumeTillDate nVarChar(11)                     
Declare @SalesCode nVarChar(255)                
Declare @AssignDate nVarChar(25)                
Declare @AssignTempDate nVarChar(5)                
Declare @InsertColumn nVarChar(25)            
Declare @InsertFromDate nVarChar(25)                  
Declare @InsertSTMT nVarChar(2000)          
Declare @CampaignName nVarChar(255)          
Declare @CurCampaignID nVarChar(15)        
Declare @TotalCalls Int        
Declare @ProductCalls Int        
Declare @CallProductive Decimal(18,6)        
Declare @Delimeter as Char(1)                  

Set @InsertFromDate = '01' + '/' +  Cast(DatePart(mm, @FromDate) as nVarChar(2)) + '/' + Cast(DatePart(yyyy, @FromDate) as nVarChar(4))                
Set @Delimeter=Char(15)                  

Create table #tmpSalesMan(SalesmanCode nVarChar(15) COLLATE SQL_Latin1_General_CP1_CI_AS)                  
If @SalesmanCode = N'%'                   
 Insert Into #tmpSalesMan Select SalesmanCode From Salesman Where Active = 1                 
Else                  
 Insert Into #tmpSalesMan Select * From dbo.sp_SplitIn2Rows(@SalesmanCode,@Delimeter)           
           
Create Table #Temp 
(          
	SalesmanCode nVarChar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,
	SalesmanName nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
	[Volume Objective] Decimal(18,6),
	[Total Volume]  Decimal(18,6),
	[Call Objective] Int,[Total Calls] Int,[Productive Calls]Int,
	[Call Productivity]  Decimal(18,6),[Calls per Day] Decimal(18,6)
)          
          
Insert Into #Temp(SalesmanCode) Select SalesmanCode From #TmpSalesman          

Declare Salesman_Cursor Cursor For Select SalesmanCode From #TmpSalesman           
Open Salesman_Cursor                
 Fetch Next From Salesman_Cursor Into @CurSalesmanCode          
 While @@Fetch_Status = 0                
 Begin                    
  Update	#Temp 
		Set 
			[Volume Objective] = 
				(Select IsNull(SUM(sp.volume),0)           
	   From SalesmanScopeDetail sp           
	   Where sp.salesmancode = @CurSalesmanCode          
	   And sp.objmonth = Month(@FromDate)  And sp.objyear = Year(@FromDate)),
			[Total Volume]= 
				IsNull((Select IsNull(SUM(quantity) , 0)            
	   From invoiceabstract as ivt , invoicedetail as idt  , salesman s          
	   Where ivt.invoiceid = idt.invoiceid           
	   And ivt.salesmanid = s.salesmanid          
	   And s.salesmanCode = @CurSalesmanCode          
	   And ivt.invoicedate between CAST(@InsertFromDate as DateTime) And @FromDate           
	   And ((Ivt.Status & 128) = 0)            
	   Group By ivt.salesmanid  ), 0),          
  	[Call Objective] = 
				IsNull((Select IsNull(count(Distinct wcpdetail.customerid),0)           
	   From wcpabstract,wcpdetail           
	   Where wcpabstract.code = wcpdetail.code           
	   And wcpabstract.salesmanid = @CurSalesmanCode          
	   And wcpabstract.weekdate between @InsertFromDate And @FromDate     
	   And (isnull(wcpabstract.status,0)&128)=0           
	   And (isnull(wcpabstract.status,0)& 32)=0),0),
   [Total Calls]  = 
				IsNull((Select IsNull(count(salesman.salesman_name),0)           
	   From svabstract,svdetail , salesman          
 	  Where svabstract.salesmancode = @CurSalesmanCode          
  	 And Salesman.SalesmanCode = svabstract.SalesmanCode          
   	And svabstract.svnumber = svdetail.svnumber          
   	And svabstract.Svdate between @InsertFromDate And @FromDate),0),    
	  [Productive Calls] = 
				(Select IsNull(count(soabstract.customerid),0)           
 	  From soabstract, salesman           
  	 Where soabstract.salesmanid = salesman.salesmanid          
   	And salesman.salesmancode = @CurSalesmanCode          
   	And soabstract.Sodate between @InsertFromDate And @FromDate),          
	  SalesmanName = 
			(Select Salesman_Name From Salesman Where SalesmanCode = @CurSalesmanCode),          
		 [Calls per Day]  = 
			(Select 
					IsNull((Cast(Count(SVNUMBER) As Decimal(18,6))/Case Days When 0 Then 1 Else Days End),0)
				From 
					Svabstract SVA,SalesMan SM,SellingDays SD
				Where 	
					SVA.salesmancode = @CurSalesmanCode 
					And SM.salesmancode=SVA.salesmancode
					And	SM.salesmanid = SD.salesmanid	
				 And Month(SVA.SVdate) = Month(@FromDate) 
					And Year(SVA.SVdate) = Year(@FromDate) 
				 And MonthNo = Month(@FromDate)
					And ((IsNull(Status,0)& 32) = 0 And (IsNull(Status,0) & 64) = 0) 
				Group by 
					Days)    
 	Where #Temp.SalesmanCode = @CurSalesmanCode          
  Select 
			@TotalCalls = [Total Calls],@ProductCalls = [Productive Calls] 
		From 	
			#Temp         
  Where 
			#Temp.salesmancode = @CurSalesmanCode        
		If @ProductCalls = 0        
			Set @CallProductive = 0        
		Else         
			Set @CallProductive = (@ProductCalls / @TotalCalls)        
  Update #Temp Set [Call Productivity] = Isnull(@CallProductive,0)        
  Where #Temp.salesmancode = @CurSalesmanCode     
  Fetch Next From Salesman_Cursor Into @CurSalesmanCode          
 End          
Close Salesman_Cursor                
DeAllocate Salesman_Cursor                
Declare @CurCampaignName nVarChar(255)          
Declare @Exec_Sql as nVarChar(2000)          
          
Create Table #TmpCampaign
(
	CampaignID nVarChar(15) COLLATE SQL_Latin1_General_CP1_CI_AS,
	CampaignName nVarChar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,
 SalesmanCode nVarChar(15) COLLATE SQL_Latin1_General_CP1_CI_AS
)         
Insert Into #TmpCampaign(CampaignID,CampaignName,SalesmanCode)
Select  
	Distinct campaignMaster.campaignId,campaignMaster.campaignName,salesman.salesmancode         
From 
	campaignMaster, campaigncustomers,wcpabstract,wcpdetail,Salesman        
Where           
 wcpdetail.customerid = campaigncustomers.customerid           
 And wcpabstract.code = wcpdetail.code           
 And campaignMaster.campaignId = campaigncustomers.CampaignId And Salesman.salesmancode = wcpabstract.salesmanid        
         
Declare Salesman_Cursor Cursor For Select Distinct CampaignName From #TmpCampaign          
Open Salesman_Cursor                
 Fetch Next From Salesman_Cursor Into @CurCampaignName          
 While @@Fetch_Status = 0                
 Begin                    
 Set @Exec_Sql = 'Alter Table #Temp Add [' + @CurCampaignName + ' Objective] nVarChar(255)'         
 Exec sp_executesql @Exec_Sql           
 Set @Exec_Sql = 'Alter Table #Temp Add [' + @CurCampaignName + '] nVarChar(255)'           
 Exec sp_executesql @Exec_Sql             
 Fetch Next From Salesman_Cursor Into @CurCampaignName        
 End          
Close Salesman_Cursor                
DeAllocate Salesman_Cursor            
        
        
Declare Salesman_Cursor Cursor For Select Distinct CampaignID,CampaignName,SalesmanCode From #TmpCampaign          
Open Salesman_Cursor                
 Fetch Next From Salesman_Cursor Into @CurCampaignID,@CurCampaignName,@CurSalesmanCode1          
 While @@Fetch_Status = 0                
 Begin                    
  Set @Exec_Sql = 'Update #Temp Set [' + @CurCampaignName + '] = (Select Isnull(CampaignDrives.response,0)        
  From CampaignDrives,sVabstract,salesman Where sVabstract.salesmancode= salesman.salesmancode        
  And sVabstract.Svnumber = CampaignDrives.svnumber And CampaignDrives.CampaignID = ''' + @CurCampaignID + ''') '        
  + ' Where #temp.salesmancode = ''' + @CurSalesmanCode1 + ''''        
	 Exec sp_executesql @Exec_Sql             
	 Fetch Next From Salesman_Cursor Into @CurCampaignID,@CurCampaignName,@CurSalesmanCode1          
 End          
Close Salesman_Cursor                
DeAllocate Salesman_Cursor           
        
Declare Salesman_Cursor Cursor For Select Distinct CampaignID,CampaignName,SalesmanCode From #TmpCampaign          
Open Salesman_Cursor                
 Fetch Next From Salesman_Cursor Into @CurCampaignID,@CurCampaignName,@CurSalesmanCode1          
 While @@Fetch_Status = 0                
 Begin                    
		Set @Exec_Sql = 'Update #Temp Set  [' + @CurCampaignName + ' Objective] = (Select Distinct CampaignMaster.Objective        
		From campaignMaster, campaigncustomers,wcpabstract,wcpdetail,Salesman        
		Where wcpdetail.customerid = campaigncustomers.customerid         
		And wcpabstract.code = wcpdetail.code And campaignMaster.campaignId = campaigncustomers.CampaignId          
		And Wcpabstract.salesmanid =salesman.salesmancode  And Wcpabstract.salesmanid= ''' + @CurSalesmanCode1 + ''' And campaignMaster.CampaignID = ''' + @CurCampaignID + ''') '        
		+ ' Where #temp.salesmancode = ''' + @CurSalesmanCode1 + ''''        
	 Exec sp_executesql @Exec_Sql             
	 Fetch Next From Salesman_Cursor Into @CurCampaignID,@CurCampaignName,@CurSalesmanCode1          
 End     
Close Salesman_Cursor                
DeAllocate Salesman_Cursor         
         
Select * From #Temp          

Drop table #TmpCampaign          
Drop Table #Temp          
Drop Table #TmpSalesman 

