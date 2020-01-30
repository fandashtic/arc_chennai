CREATE procedure Sp_Get_WeekDay (@nWeekDay Int) as  
SET DATEFIRST 1
If Exists(select weekdate from wcpabstract  Where (IsNull(Status,0) & 128) = 0 And datepart(dw,weekdate)=@nweekday)
Select 1
Else
Select 0



