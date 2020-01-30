Create procedure sp_ser_rpt_WarrantyIssueAbstract(@Fromdate datetime,@Todate datetime,@sparename as nvarchar(255))         
As                                                    
Declare @ParamSep nVarchar(10)                              
Declare @Prefix as nvarchar(2)                              
Declare @Prefix1 as nvarchar(2)                                                
Declare @Itemspec1 nvarchar(50)                                                         
Declare @Iteminfo nvarchar(4000)                                                         
Declare @Iteminfo1 nvarchar(4000)                                                        
                            
Set @ParamSep = Char(2)                                                
select @Prefix = Prefix from VoucherPrefix where TranID = 'ISSUESPARES'                              
select @Prefix1 = Prefix from VoucherPrefix where TranID = 'JOBCARD '                                            
select @Itemspec1 = servicecaption from servicesetting where servicecode = 'Itemspec1'                                                        
                            
Create table #Warranty_Temp([_EstimationID] nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS,[_Issue Date] datetime null,[_JobCard Date] datetime null) 

set @Iteminfo = 'Alter Table #Warranty_Temp Add 
[_Item Code] nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,
[_Item Name] nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS,                            
[' + @ItemSpec1 + '] nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS null,                            
[_Spare Code] nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS null,                            
[_Spare Name] nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS null,                            
[_IssueID] nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS null,                            
[_Customer Name] nvarchar(50) null,                            
[_Doc Ref] nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS null,                            
[_JobCardID] nvarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS null'                            
  
Exec sp_executesql @Iteminfo      
  
Insert into #Warranty_Temp        
select 'EID' = cast(issuedetail.IssueID as nvarchar(10)) + @paramsep + issuedetail.product_code + @Paramsep + issuedetail.product_specification1 + @paramsep + sparecode,                                  
'Issue Date' = isnull(dbo.sp_ser_StripDateFromTime(issueabstract.issuedate),''),
'JobCard Date' = isnull(dbo.sp_ser_StripDateFromTime(jobcardabstract.jobcarddate ),''),                                       
'Item Code' = issuedetail.Product_code,             
'Item Name' = b.productName,                            
Issuedetail.product_specification1,                
'Spare Code' = sparecode,                                   
'Spare Name' = a.productName,                            
'Issue ID' =  @prefix  + cast(issueabstract.DocumentID as nvarchar(15)),                                                          
'Customer Name' = company_Name,                                          
'Doc Ref' = issueabstract.DocRef,                                          
'JobCardID' = @Prefix1 + cast(jobcardabstract.documentid as nvarchar(15))                              
from Issueabstract,issuedetail,jobcardabstract,Customer,items a,items b                             
where jobcardabstract.customerID = customer.customerID                                                      
and issueabstract.JobcardID = jobcardabstract.jobcardid                                        
and issueabstract.issueid = issuedetail.issueid                                  
--and issuedetail.sparecode Like @sparename                                  
and a.ProductName Like @sparename                                  
and issuedetail.sparecode = a.product_code                                  
and issuedetail.product_code = b.product_code                            
and warranty = 1                              
and (issuedate) between @FromDate and @ToDate                                              
and (IsNull(issueabstract.Status,0) & 192) = 0                                    

Set @Iteminfo1 = 'Select  [_EstimationID]  as "Estimation ID",
[_Item Code] as "Item Code",[_Item Name] as "Item Name",
[' + @ItemSpec1 + '],                            
[_Spare Code] as "Spare Code",                            
[_Spare Name] as "Spare Name",                            
[_IssueID] as "Issue ID",                            
[_Issue Date] as "Issue Date",
[_Customer Name] as "Customer Name",                            
[_Doc Ref] as "Doc Ref",                            
[_JobCardID] as "JobCard ID",                           
[_JobCard Date]  as "JobCard Date"
from #Warranty_Temp'

exec sp_executesql @Iteminfo1                                        

Drop Table #Warranty_Temp

