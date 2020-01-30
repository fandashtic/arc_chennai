CREATE procedure sp_ser_rpt_Open_EstimationAbstract(@Fromdate datetime,@Todate datetime)                              
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
'Doc Ref' = isnull(DocRef,''),                  
'Remarks' = isnull(Remarks,''),                               
'Task Amount'=             
case when isnull(Taskid,'') <> '' and (isnull(sparecode,'') = '' or sparecode = NULL) then IsNUll(Sum(Netvalue),0)  else 0 end, 
'Spare Amount' = case when isnull(sparecode,'')  <> ''  then IsNUll(Sum(Netvalue),0) else 0 end,                                
'Total Amount' = case when isnull(sparecode,'') = '' and isnull(Taskid,'') <> ''then IsNUll(Sum(Netvalue),0) else 0 end +                          
case when isnull(sparecode,'')  <> ''  then IsNUll(Sum(Netvalue),0) else 0 end                          
    
from Estimationabstract,EstimationDetail,Customer                              
where Estimationabstract.customerID = customer.customerID                              
and Estimationabstract.EstimationID = EstimationDetail.EstimationID                            
and (Estimationdate) between @FromDate and @ToDate                          
and(IsNull(Status,'')) = 1                         
group by Estimationabstract.EstimationID,Estimationabstract.documentID,estimationdate,                  
company_name,DocRef,Remarks,                  
TaskID,sparecode) as grp                          
Group by [ID],[EstimationID],[Estimation Date],[Customer Name],[Doc Ref],[Remarks]        





