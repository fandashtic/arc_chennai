



create function getbranch(@branchid nvarchar(15))
returns nvarchar(50)
as 
begin
declare @branchname nvarchar(50)
select @branchname = [BranchName] from BranchMaster 
where [BranchCode]= @branchid
return @branchname
end





