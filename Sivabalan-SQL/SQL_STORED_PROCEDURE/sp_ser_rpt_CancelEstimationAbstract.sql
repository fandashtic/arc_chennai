CREATE procedure sp_ser_rpt_CancelEstimationAbstract(@Fromdate datetime,@Todate datetime)                              
As                              
Declare @Prefix nvarchar(15)                                        
                          
select @Prefix = Prefix from VoucherPrefix where TranID = 'JOBESTIMATION'                        
                        
Select [ID],[EstimationID],[Estimation Date],[Customer Name],[Doc Ref],[Remarks],                           
Sum([Task Amount])As [Task Amount],Sum([Spare Amount])As [Spare Amount],                    
Sum([Total Amount])As [Total Amount] FROM                            
(SELECT 'ID' = Estimationabstract.EstimationID,                        
 'EstimationID' =  @Prefix + cast(Estimationabstract.DocumentID as nvarchar(15)),                              
'Estimation Date' = EstimationDate,                              
'Customer Name' = company_Name,                  
'Doc Ref' = DocRef,                  
'Remarks' = Remarks,                               
'Task Amount'=         
Cast(case when isnull(sparecode,'') = '' and isnull(Taskid,'') <> '' then Cast(sum(Netvalue) as Decimal(18,2)) else 0 end as decimal(18,2)),             
'Spare Amount' = case when isnull(sparecode,'')  <> ''  then Cast(sum(Netvalue) as Decimal(18,2)) else 0 end,                          
'Total Amount' = case when isnull(sparecode,'') = '' and Taskid <> ''then sum(Netvalue)else 0 end +                    
case when isnull(sparecode,'')  <> ''  then sum(Netvalue) else 0 end                    
/*'Status' =             
 Case       
        
 WHEN (IsNull(Status, 0) & 128) <> 0 THEN 'Closed'            
 WHEN (IsNull(Status, 0) & 192) <> 0 THEN 'Cancelled'            
 ELSE 'Open'            
 END */           
from Estimationabstract,EstimationDetail,Customer                              
where Estimationabstract.customerID = customer.customerID                              
and Estimationabstract.EstimationID = EstimationDetail.EstimationID                            
and (Estimationdate) between @FromDate and @ToDate                          
and (IsNull(Status,0) & 64) <> 0
                   
group by Estimationabstract.EstimationID,Estimationabstract.documentID,estimationdate,                  
company_name,DocRef,Remarks,                  
TaskID,sparecode,Status) as grp                          
Group by [ID],[estimationID],[Estimation date],[Customer Name],[Doc Ref],[Remarks]      
  
  



