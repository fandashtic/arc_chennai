Create Procedure sp_update_CompanyName (@CompanyID nvarchar(50), @CompanyName_ClientDB nvarchar(4000))
as
update Setup Set OrganisationTitle = @CompanyName_ClientDB Where RegisteredOwner = @CompanyID

