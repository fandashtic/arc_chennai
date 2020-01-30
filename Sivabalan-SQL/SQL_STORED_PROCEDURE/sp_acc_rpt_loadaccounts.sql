CREATE procedure sp_acc_rpt_loadaccounts(@mode integer,@groupid integer,@loadoption integer) 
as
if @loadoption =1
begin
 if @mode = 0
  begin
   select AccountID,AccountName from [AccountsMaster] where AccountID not in (22,23,88,89,500) order by [AccountName] -- Opening Stock, Closing Stock, Tax on Opening Stock, Tax on Closing Stock
  end
 else
 if @mode=1
  begin
   select AccountID,AccountName from [AccountsMaster] where [GroupID]=@groupid order by [AccountName]
  end
end
else
if @loadoption=2 
begin
 select GroupID,GroupName from AccountGroup where GroupID not in (21,54,55,500) order by [GroupName] --Stock in Trade, Opening Stock, Closing Stock, User Account Group Start
end

