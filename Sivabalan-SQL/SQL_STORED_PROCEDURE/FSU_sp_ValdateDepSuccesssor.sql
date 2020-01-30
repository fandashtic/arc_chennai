CREATE Procedure FSU_sp_ValdateDepSuccesssor
(
@ClientID int,
@FSUID int )
As                
begin
select Count(*) as "RecCount" from tblInstallationDetail 
where 
ClientID = @ClientID 
and Status&4 = 4
and DependentFUID = @FSUID
end
