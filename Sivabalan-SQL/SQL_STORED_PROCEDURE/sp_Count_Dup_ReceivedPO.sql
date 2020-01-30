CREATE PROCEDURE sp_Count_Dup_ReceivedPO
AS
select Count(*) from poabstractreceived where
status = 0 And (Cast(poreference As nvarchar) + branchforumcode) in (SELECT Cast(poreference As nvarchar) + branchforumcode FROM POAbstractReceived 
group by poreference,branchforumcode having count(poreference)> 1 and
count(branchforumcode)>1) 


