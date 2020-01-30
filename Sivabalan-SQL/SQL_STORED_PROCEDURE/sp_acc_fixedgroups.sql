
CREATE Procedure sp_acc_fixedgroups
As
Select A.GroupID,A.GroupName,A.ParentGroup,(Select B.GroupName from accountgroup b where b.groupid=a.parentgroup) From AccountGroup a where fixed =1 order by a.GroupID



