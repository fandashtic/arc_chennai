
Create procedure spr_ser_ServiceProgressDetail(@ITEM nvarchar(255))            
AS
Begin

Declare @ParamSep nVarchar(10)                
Declare @ServiceType int                
Declare @ItemCode nvarchar(255)            
Declare @FromDate DateTime
Declare @ToDate DateTime
Declare @tempString nVarchar(510)            
Declare @ParamSepcounter int            
           
Set @tempString = @ITEM            
Set @ParamSep = char(2)
          
/* ItemCodeID */          
Set @ParamSepcounter = CHARINDEX(@ParamSep,@tempString,1)                
set @ItemCode = substring(@tempString, 1, @ParamSepcounter-1)             

/*FromDate*/               
Set @tempString = substring(@tempString, @ParamSepcounter + 1, len(@ITEM))             
Set @ParamSepcounter = CHARINDEX(@ParamSep, @tempString, 1)            
set @FromDate = substring(@tempString, 1, @ParamSepcounter-1)    

/*ToDate*/               
Set @tempString = substring(@tempString, @ParamSepcounter + 1, len(@ITEM))             
Set @ParamSepcounter = CHARINDEX(@ParamSep, @tempString, 1)            
set @ToDate = substring(@tempString, 1, @ParamSepcounter-1)    
          
/*ServiceType*/          
Set @tempString = substring(@tempString, @ParamSepcounter + 1, len(@ITEM))             
set @ServiceType = @tempString    


 
--For splitting multiple Items Selected...
Declare @Delimeter as Char(1)  
Set @Delimeter = Char(15)  

Create table #TmpItem(Item_Code varchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)  

If @ItemCode='%'   
   Insert into #TmpItem Select Product_Code From Items  
Else  
   Insert into #TmpItem Select * From dbo.sp_SplitIn2Rows(@ItemCode,@Delimeter)  



--Temperory Table
Create table #temp(Product_Code nVarchar(100) COLLATE SQL_Latin1_General_CP1_CI_AS,
	ProductName nVarchar(200) COLLATE SQL_Latin1_General_CP1_CI_AS,
	A int, B int, C int, D int, E int, F int, G int)

Declare @tempItemCode nVarChar(100)
Declare @tempItemName nVarChar(200)

Declare Item_Cursor CURSOR FOR
SELECT Product_Code, ProductName FROM Items WHERE product_Code IN (Select Item_Code COLLATE SQL_Latin1_General_CP1_CI_AS from #TmpITem) order by Product_Code

OPEN Item_Cursor
FETCH NEXT FROM Item_Cursor INTO @tempItemCode, @tempItemName

While @@FETCH_STATUS = 0
Begin
	Insert Into #temp (Product_Code, ProductName, A, B, C, D, E, F, G)
	(Select @tempItemCode, @tempItemName,
		(Select Count(*) from JCAcknowledgementAbstract
		Where (AcknowledgementDate Between @FromDate and @ToDate) and
		(JCAcknowledgementAbstract.Status & 128) <> 128 and
		(JCAcknowledgementAbstract.Status & 64) <> 64 and
		(select count(*) from JCAcknowledgementDetail where JCAcknowledgementDetail.AcknowledgementID = JCAcknowledgementAbstract.AcknowledgementID and JCAcknowledgementDetail.Product_Code Like @tempItemCode) <> 0 and 
		ServiceType = @ServiceType
		) ,
		
		(Select Count(*) from JobCardAbstract
		Where (JobCardDate Between @FromDate and @ToDate) and
		(JobCardAbstract.Status & 128) <> 128 and
		(JobCardAbstract.Status & 64) <> 64 and
		(select count(*) from JobCardDetail where JobCardDetail.JobCardID = JobcardAbstract.JobCardID and JobCardDetail.Product_Code Like @tempItemCode) <> 0 and 
		ServiceType = @ServiceType
		) ,
		
		(Select Count(*) from JobcardIntimation
		Where (IntimationDate Between @FromDate and @ToDate) and
		Status & 64 <> 64 and
		(select count(*) from JobCardDetail where JobCardDetail.JobCardID = JobcardIntimation.JobCardID and JobCardDetail.Product_Code Like @tempItemCode) <> 0 and 
		(select ApprovedStatus from JobCardAbstract where JobCardAbstract.JobCardID = JobcardIntimation.JobCardID) = 1 and
		(select ServiceType from JobCardAbstract where JobCardAbstract.JobCardID = JobcardIntimation.JobCardID) = @ServiceType
		) ,
		
		(Select Count(*) from JobcardApproval
		Where (ApprovedDate Between @FromDate and @ToDate) and
		Status & 64 <> 64 and
		(select count(*) from JobCardDetail where JobCardDetail.JobCardID = JobcardApproval.JobCardID and JobCardDetail.Product_Code Like @tempItemCode) <> 0 and 
		(select ApprovedStatus from JobCardAbstract where JobCardAbstract.JobCardID = JobcardApproval.JobCardID) = 2 and
		(select ServiceType from JobCardAbstract where JobCardAbstract.JobCardID = JobcardApproval.JobCardID) = @ServiceType
		) ,
		
		(Select Count(*) from JobCardTaskAllocation
		Where (StartDate Between @FromDate and @ToDate) and 
		TaskStatus=2 and
		Product_Code Like @tempItemCode and
		(select ServiceType from JobCardAbstract where JobCardAbstract.JobCardID = JobcardTaskAllocation.JobCardID) = @ServiceType
		) ,
		
		(Select Count(*) from ServiceInvoiceAbstract
		Where (ServiceInvoiceDate Between @FromDate and @ToDate) and
		(ServiceInvoiceAbstract.Status & 128) <> 128 and
		(ServiceInvoiceAbstract.Status & 64) <> 64 and
		(select count(*) from ServiceInvoiceDetail where ServiceInvoiceDetail.ServiceInvoiceID = ServiceInvoiceAbstract.ServiceInvoiceID and ServiceInvoiceDetail.Product_Code Like @tempItemCode) <> 0 and 
		(select ServiceType from JobCardAbstract where JobCardAbstract.JobCardID = ServiceInvoiceAbstract.JobCardID) = @ServiceType
		) ,
		
		(Select Count(*) from JobCardAbstract
		Where (JobCardDate Between @FromDate and @ToDate) and
		(JobCardAbstract.Status & 128) <> 128 and
		(JobCardAbstract.Status & 64) <> 64 and
		(Select Count(*) from (Select Distinct TaskStatus from JobCardTaskAllocation where 
			JobCardAbstract.JobCardID = JobCardTaskAllocation.JobCardID) as Task) = 1 and
		ServiceInvoiceID is Null and
		(select count(*) from JobCardDetail where JobCardDetail.JobCardID = JobcardAbstract.JobCardID and JobCardDetail.Product_Code Like @tempItemCode) <> 0 and 		
		ServiceType = @ServiceType
		)
	)
	FETCH NEXT FROM Item_Cursor INTO @tempItemCode, @tempItemName
End

CLOSE Item_Cursor
DEALLOCATE Item_Cursor

Select 'EID' = 1, Product_Code, ProductName, A 'Received', B 'Job Card Created', 
C 'Effort Intimated', D 'Effort Approved', (case sign(C - D) when 1 then (C-D) when -1 then 0 when 0 then 0 end) 'Effort Not Approved', 
E 'No of Task Closing', F 'Service Invoice', G 'Pending Delivery' from	#temp
Where A > 0 or B > 0 or C > 0 or D > 0 or E > 0 or F > 0 or G > 0


Drop table #TmpItem
Drop table #temp

End


