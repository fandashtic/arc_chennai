
CREATE Procedure Sp_Ser_Rpt_PendingTools_JCAbstract(@ITEM nVarchar(255))
As
Begin

Declare @ParamSep nVarchar(10)                
Declare @tempString nVarchar(510)            
Declare @ParamSepcounter int            

Declare @FromDate DateTime
Declare @ToDate DateTime

Set @tempString = @ITEM 
Set @ParamSep = Char(2)                

/* FromDate */          
Set @ParamSepcounter = CHARINDEX(@ParamSep,@tempString,1)                
set @FromDate = substring(@tempString, 1, @ParamSepcounter-1)             
          
/*ToDate*/          
            
Set @tempString = substring(@tempString, @ParamSepcounter + 1, len(@Item))             
set @ToDate = @tempString    

Declare @Prefix nvarchar(15)                                        
Declare @Prefix1 nvarchar(15)                                                    
select @Prefix = Prefix from VoucherPrefix where TranID = 'JOBCARD'                        
select @Prefix1 = Prefix from VoucherPrefix where TranID = 'ACKNOWLEDGEMENT'                        
SELECT 'ID' = cast(jobcardabstract.JobCardID as nvarchar(15)),
'Job Card ID' =  @Prefix + cast(jobcardabstract.DocumentID as nvarchar(15)), 
'Job Card Date' = jobcardDate,                              
'Customer Name' = company_Name,                  
--'Doc Ref' = Isnull(jobcardabstract.DocRef,''),                  
--'Remarks' = Isnull(jobcardabstract.Remarks,''),                
'Acknowledgement ID' = @Prefix1 + cast(JCA.documentID as nvarchar(15)),
'Status' =Case  When (IsNull(jobcardabstract.ServiceInvoiceID,0)<>0) then 'Invoiced'
		When (ISNull(ApprovedStatus,0)=2) then 'Estimate Approval'
		When (ISNull(ApprovedStatus,0)=1) then 'Estimate Intimation' 		
		When (IsNull(jobcardabstract.Status,0) & 224 = 0) then 'Open JobCard'
   End
from jobcardabstract,Customer,JCAcknowledgementabstract JCA                              
where jobcardabstract.customerID = customer.customerID                              
and jobcardabstract.Acknowledgementid = JCA.Acknowledgementid              
and (jobcarddate) between @FromDate and @ToDate                      
and (IsNull(jobcardabstract.Status, 0) & 192) = 0
End
