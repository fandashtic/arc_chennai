CREATE Function sp_ser_GetBeatDescForCus  
(@cuscode varchar(30)) Returns Varchar(510)  
as  
begin  
 declare @BeatDesc varchar(510)  
 Set @BeatDesc='No Beat'  
  
 Select @BeatDesc=Description from Beat where Beatid in  
 (Select Beatid from Beat_Salesman where Customerid=@cuscode)  
  
Return(Select @beatdesc)  
end  

