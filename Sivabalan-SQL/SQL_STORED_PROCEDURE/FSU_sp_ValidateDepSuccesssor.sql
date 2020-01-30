CREATE Procedure FSU_sp_ValidateDepSuccesssor
(
@ClientID int,
@FSUID int )
As                
begin
select Count(*) as "RecCount" from tblInstallationDetail IND
inner join tblDependentDetail DND on IND.InstallationID = DND.InstallationID
Where
IND.ClientID = @ClientID 
and IND.Status&4 = 4
and DND.DependentFSUID = @FSUID
end
