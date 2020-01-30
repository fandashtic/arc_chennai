CREATE Procedure sp_GetLatestDefinitionType(@CustomerID NVARCHAR(255))      
As      
Begin      
Declare @DocSerial as Int    
---When all customer definition is the latest then it will be selected irrespective of the    
---customer      
if (Select IsNull(Customer,0) From PointsAbstract Where DocSerial = (Select IsNull(Max(DocSerial),0) From    
PointsAbstract where active =1)) = 0    
Begin    
	Select @DocSerial=IsNull(Max(DocSerial),0) From PointsAbstract where Active=1    
End    
Else    
Begin    
	---Max(DocSerial) for a particular customer will be selected    
 	select @DocSerial=IsNull(max(PA.DocSerial),0) from PointsCustomer PC,PointsAbstract  PA        
	where CustomerID=@CustomerID And PC.Docserial=PA.DocSerial And PA.Active=1   
    
	if @DocSerial = 0   or (@DocSerial < (Select IsNull(max(DocSerial),0) From PointsAbstract Where Active=1 And Customer=0) )  
	begin    
	    --when the particular customer is not in the latest def type     
	    --then all customer def type will be chosen (@DocSerial=0 I Condition)   
	  	
		--If the definition type for the particular customer is less than the all customer definition  
	    --then all customer definition will be selected (II Condition)  
	    Select @DocSerial=Max(DocSerial) From PointsAbstract Where Active=1 and customer=0    
	end   
End      
select @DocSerial    
End    
  
  


 

