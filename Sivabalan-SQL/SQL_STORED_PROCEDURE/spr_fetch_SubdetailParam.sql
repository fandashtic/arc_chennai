CREATE procedure spr_fetch_SubdetailParam(@repid int,@FrmDate datetime,@ToDate datetime)
As

Set Dateformat dmy  
 Select Case Substring(defaultValue,1,4)  
    When N'$All' then N'%'  
    When N'$Dat' then Case When ParameterType=7 then Convert(nvarchar,@FrmDate,106) + N' 12:00 AM'  
    When ParameterType=10 then Convert(nvarchar,@ToDate,106) + N' 11:59 PM'  
          Else Convert(nvarchar,@FrmDate,106) + N' 12:00 AM' End  
    When N'' then N'%'  
    Else defaultValue End ,  
  Case ParameterType When 10 then 7 else Parametertype end 
from parameterinfo
Where	parameterinfo.ParameterID=(Select Distinct(Parameters)
From Reportdata Where Reportdata.ID=@repid)

