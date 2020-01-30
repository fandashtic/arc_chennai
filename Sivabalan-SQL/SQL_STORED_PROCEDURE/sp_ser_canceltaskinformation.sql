CREATE Procedure sp_ser_canceltaskinformation(@SerialNo int)  
as  
update jobcardtaskallocation set Taskstatus = 3   
where serialno = @serialno  

